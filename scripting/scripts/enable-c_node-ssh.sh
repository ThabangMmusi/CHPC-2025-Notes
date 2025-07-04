#!/bin/bash

# Prompt for NODE_IP if not provided
if [ -z "$NODE_IP" ]; then
  read -p "Please enter the NODE_IP: " NODE_IP
fi

# Validate if both NODE_IP and SERVER_IP are provided
if [ -z "$NODE_IP" ]; then
  echo "Error: NODE_IP is required."
  exit 1
fi

echo "Copy ssh public keys from you local machine... using below command"
echo "scp C:\.ssh\id_ed25519 ubuntu@154.114.57.219:~/.ssh/"
read -p "Press Enter to continue...."

echo "Set the appropriate permissions for..."
echo ".ssh directory, authorized_keys and id_ed25519 file."
chmod 700 ~/.ssh/
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh/id_ed25519
echo ">>Done!"
echo
echo "Copying the keys to compute node $NODE_IP..."
ssh-copy-id -f $NODE_IP
echo ">>Done!"
echo
