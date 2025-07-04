#!/bin/bash

# Ensure the SERVER_IP variable is provided
if [ -z "$1" ]; then
  echo "Error: Please provide the SERVER IP (Local ip)"
  exit 1
fi

SERVER_IP="$1"

# INSTALL NFS
echo "Starting the NFS installation...."
sudo apt install nfs-common -y > /dev/null 2>&1
echo ">>Done!"
echo
echo "Mount HOME using the IP address of our host server:...."
cd /
sudo mount $SERVER_IP:/home /home
echo ">>Done!"
echo
echo "Verify that you successfully mounted /home export"
df -h

echo "Edit your /etc/fstab to make the effect persist after a restart. Add this entry to the end of your fstab...."
echo "$SERVER_IP:/home /home  nfs   defaults,timeo=1800,retrans=5,_netdev	0 0" | sudo tee -a /etc/fstab
echo ">>Done!"
echo
