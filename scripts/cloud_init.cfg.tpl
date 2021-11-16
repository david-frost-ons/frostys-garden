#cloud-config
users:
  - default
  - web
write_files:
%{ for file in files ~}
  - path: ${file.path}
    encoding: ${file.enc}
    content: ${file.content}
    owner: root:root
    permissions: "${file.perms}"
%{ endfor ~}
package_update: true
packages:
  - httpd
  - httpd-tools
  - mod_ssl
runcmd:
  - amazon-linux-extras enable php7.4
  - yum clean metadata
  - yum install php php-common php-pear 
  - yum install php-{cgi,curl,mbstring,gd,mysqlnd,gettext,json,xml,fpm,intl,zip}  
  - rpm -Uvh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm 
  - yum install mysql-community-server 
  - yum install -y https://s3.eu-west-2.amazonaws.com/amazon-ssm-eu-west-2/latest/linux_amd64/amazon-ssm-agent.rpm
%{ for cmd in cmds ~}
  - ${cmd}
%{ endfor ~}
final_message: Frostys Garden server build completed
