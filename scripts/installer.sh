#!/bin/bash
echo "Installer script"

mkdir /usr/local/wp_install

(
  cd /usr/local/wp_install; \
  wget https://wordpress.org/latest.tar.gz; \
  tar -xzf latest.tar.gz; \
  ls -alh;
)

cp /usr/local/wp_install/wordpress /var/www/html/${wp_web_dir}

