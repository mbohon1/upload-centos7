#!/bin/bash

# Check network connectivity
ping -c 4 google.com > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Network connectivity issue. Please check your internet connection."
    exit 1
fi

# Update DNS configuration if necessary
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf

# Disable IPv6 temporarily (if applicable)
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Install git if not already installed
if ! command -v git &> /dev/null; then
    sudo yum install git -y
fi

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
sudo yum makecache fast

# Update system packages
sudo yum update -y 

# Install wget if not already installed
sudo yum install wget -y

# Execute the remote script from the given URL
bash <(curl -s "https://raw.githubusercontent.com/ngochoaitn/multi_proxy_ipv6/main/install.sh")
