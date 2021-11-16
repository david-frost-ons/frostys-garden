resource "aws_iam_role" "frostys_garden" {
  name = "frostysgarden_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach-ssm" {
  role       = aws_iam_role.frostys_garden.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "profile" {
  name_prefix = "frostysgarden-"
  role        = aws_iam_role.frostys_garden.name
}


