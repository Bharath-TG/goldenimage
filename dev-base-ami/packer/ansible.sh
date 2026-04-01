#!/bin/bash 
# Install Ansible

sudo dnf update -y
sudo dnf install epel-release -y
sudo dnf install ansible -y

sudo mkdir -p /root/scripts