#!/bin/bash

# Ensure the client_ip variable is provided
if [ -z "$1" ]; then
  echo "Error: Please provide the network range e.g 10.100.50.0/24"
  exit 1
fi

client_ip="$1"

# Ubuntu updates and installations (suppress output)
echo "Updating and upgrading packages..."
sudo apt update > /dev/null 2>&1
sudo apt upgrade -y > /dev/null 2>&1
echo ">>Done!"

# INSTALL NFS
echo "Starting the NFS installation...."
sudo apt install nfs-kernel-server -y > /dev/null 2>&1
echo ">>Done!"
echo
echo "Configuring the NFS Exports on the Host Server...."
echo "/home               $client_ip(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
echo ">>Done!"
echo
echo "Restarting the NFS server service...."
sudo systemctl restart nfs-kernel-server > /dev/null 2>&1
echo ">>Done!"
