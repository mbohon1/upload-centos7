#!/bin/bash

# Clone the repository (if not already cloned)
if [ ! -d "/tmp/repository" ]; then
    git clone https://github.com/mbohon1/CentOS-Base.repo.git /tmp/repository
else
    cd /tmp/repository && git pull origin main
fi

# Copy the CentOS-Base.repo to the correct location
sudo cp /tmp/repository/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo

# Clean yum cache and update packages
sudo yum clean all
sudo yum -y update

# Chạy lệnh cụ thể của bạn ở đây, ví dụ: khởi động lại dịch vụ httpd
sudo systemctl restart httpd

# Chạy lệnh cụ thể của bạn ở đây,
yum update -y 
sudo yum install wget -y
bash <(curl -s "https://raw.githubusercontent.com/ngochoaitn/multi_proxy_ipv6/main/install.sh")
