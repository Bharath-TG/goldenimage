#!/bin/bash

username=$1

# Exit if no username is provided
if [ -z "$username" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

# Create the user with a home directory and bash shell
sudo useradd -m -s /bin/bash "$username"

# Create the .ssh directory in the new user's home
sudo mkdir -p /home/"$username"/.ssh

# Set the correct ownership and permissions
sudo chown "$username:$username" /home/"$username"/.ssh
sudo chmod 700 /home/"$username"/.ssh

# Create the authorized_keys file
sudo touch /home/"$username"/.ssh/authorized_keys
sudo chown "$username:$username" /home/"$username"/.ssh/authorized_keys
sudo chmod 600 /home/"$username"/.ssh/authorized_keys

# List directory contents to confirm
sudo ls -la /home/"$username"/.ssh
