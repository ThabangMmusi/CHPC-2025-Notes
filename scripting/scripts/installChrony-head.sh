#!/bin/bash

# Ensure the NETWORK_RANGE variable is provided
if [ -z "$1" ]; then
  echo "Error: Please provide the network range e.g 10.100.50.0/24"
  exit 1
fi

NET_RANGE="$1"

# INSTALL CHRONY
echo "Starting the CHRONY installation on HEAD...."
sudo apt install chrony -y > /dev/null 2>&1
echo ">>Done!"
echo
echo "Edit the file /etc/chrony/chrony.conf to include...."
echo "allow $NET_RANGE" | sudo tee -a /etc/chrony/chrony.conf
echo ">>Done!"
echo
echo "Start and enable the chronyd service...."
sudo systemctl enable chrony  > /dev/null 2>&1
sudo systemctl restart chrony  > /dev/null 2>&1
echo ">>Done!"
echo

# Restart and enable nftables service
echo "Restarting and enabling nftables service..."
sudo systemctl restart nftables
sudo systemctl enable nftables
echo ">>Done!"
