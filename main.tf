terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

data "template_cloudinit_config" "instance_cfg" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud_init.cfg"
    content_type = "text/cloud-config"
    content = templatefile(local.scripts.cloud_init,
      {
        files = [
          {
            content = base64encode(templatefile("${abspath("${path.module}/scripts/installer.sh")}",
              {
                wp_web_dir = "frostysgarden"
            })),
            enc   = "b64",
            perms = "0700",
            path  = "/usr/local/bin/installer.sh"
          }
        ],
        cmds = [
          "chmod +x /usr/local/bin/installer.sh",
          "systemctl enable mysqld",
          "systemctl start mysqld",
          "systemctl enable httpd",
          "systemctl start httpd",
          "systemctl enable amazon-ssm-agent",
          "systemctl start amazon-ssm-agent",
          "systemctl status amazon-ssm-agent",
          "echo starting frostys garden server isntallation process",
          "/usr/local/bin/installer.sh"
        ]
    })
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.7.0"

  cidr            = "10.1.0.0/16"
  azs             = ["eu-west-2a", "eu-west-2b"]
  private_subnets = ["10.1.100.0/24"]
  public_subnets  = ["10.1.200.0/24"]

  create_egress_only_igw = false
  create_igw             = true

  enable_nat_gateway = false

  manage_default_route_table = true

  name = "frostys_garden_vpc"
}


resource "aws_instance" "server" {
  ami                  = "ami-0009a33f033d8b7b6"
  instance_type        = "t2.medium"
  availability_zone    = "eu-west-2a"
  subnet_id            = module.vpc.public_subnets[0]
  user_data_base64     = data.template_cloudinit_config.instance_cfg.rendered
  iam_instance_profile = aws_iam_instance_profile.profile.name

  tags = {
    Name = "Frostys Garden"
  }
}


