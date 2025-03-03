#!/bin/bash

if [ -e /dev/nvme1n1 ]; then

  if ! blkid /dev/nvme1n1 | grep -q "TYPE=\"xfs\""; then
    echo "The device /dev/nvme1n1 is not formatted with XFS. Formatting it now."
    sudo mkfs.xfs /dev/nvme1n1
  else
    echo "The device /dev/nvme1n1 is already formatted with XFS."
  fi

  sudo mkdir -p /twid
  sudo mount /dev/nvme1n1 /twid
  echo "/dev/nvme1n1 /twid xfs defaults,nofail 0 2" | sudo tee -a /etc/fstab

else
  echo "Device /dev/nvme1n1 does not exist."
fi

echo "Rebooting the system to apply changes..."
sudo reboot
