#!/bin/bash

# Function to check network connectivity
check_network() {
    ping -c 4 google.com > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Network connectivity issue. Please check your internet connection."
        exit 1
    fi
}

# Function to update DNS configuration
update_dns() {
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
    echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf > /dev/null
}

# Function to disable IPv6 temporarily
disable_ipv6() {
    echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf > /dev/null
    echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf > /dev/null
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf > /dev/null
    sudo sysctl -p > /dev/null
}

# Function to configure yum repository manually
configure_yum_repo() {
    # Backup existing repo files
    sudo mkdir -p /etc/yum.repos.d/backup
    sudo mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/

    # Create a new CentOS-Base.repo file with working base URLs
    cat <<EOL | sudo tee /etc/yum.repos.d/CentOS-Base.repo
[base]
name=CentOS-\$releasever - Base
baseurl=http://vault.centos.org/7.9.2009/os/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-\$releasever - Updates
baseurl=http://vault.centos.org/7.9.2009/updates/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-\$releasever - Extras
baseurl=http://vault.centos.org/7.9.2009/extras/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[centosplus]
name=CentOS-\$releasever - Plus
baseurl=http://vault.centos.org/7.9.2009/centosplus/\$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[contrib]
name=CentOS-\$releasever - Contrib
baseurl=http://vault.centos.org/7.9.2009/contrib/\$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOL

    # Clean yum cache and make cache fast
    sudo yum clean all || { echo "Failed to clean yum cache"; exit 1; }
    sudo yum makecache fast || { echo "Failed to make yum cache"; exit 1; }
}

# Main script execution starts here

# Check network connectivity
check_network

# Update DNS configuration if necessary
update_dns

# Disable IPv6 temporarily (if applicable)
disable_ipv6

# Configure yum repository manually to use vault.centos.org base URLs
configure_yum_repo

# Install git if not already installed
if ! command -v git &> /dev/null; then
    sudo yum install git -y || { echo "Failed to install git"; exit 1; }
fi

# Clone the repository (if not already cloned)
if [ ! -d "/tmp/repository" ]; then
    git clone https://github.com/mbohon1/CentOS-Base.repo.git /tmp/repository || { echo "Failed to clone repository"; exit 1; }
else
    cd /tmp/repository && git pull origin main || { echo "Failed to update repository"; exit 1; }
fi

# Copy the CentOS-Base.repo to the correct location (this step may be redundant now)
sudo cp /tmp/repository/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo || { echo "Failed to copy CentOS-Base.repo"; exit 1; }

# Clean yum cache and update packages (redundant step but kept for completeness)
sudo yum clean all || { echo "Failed to clean yum cache"; exit 1; }
sudo yum makecache fast || { echo "Failed to make yum cache"; exit 1; }

# Update system packages and install wget if not already installed
sudo yum update -y || { echo "Failed to update system packages"; exit 1; }
sudo yum install wget -y || { echo "Failed to install wget"; exit 1; }

# Execute the remote script from the given URL
bash <(curl -s "https://raw.githubusercontent.com/ngochoaitn/multi_proxy_ipv6/main/install.sh") || { echo "Failed to execute remote script"; exit 1; }
