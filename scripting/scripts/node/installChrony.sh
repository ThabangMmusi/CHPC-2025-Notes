#!/bin/bash
# Ensure the SERVER_IP variable is provided
if [ -z "$1" ]; then
  echo "Error: Please provide a SERVER_IP."
  exit 1
fi

SERVER_IP="$1"

# INSTALL CHRONY
echo "Starting the CHRONY installation...."
sudo apt install chrony -y > /dev/null 2>&1
echo ">>Done!"
echo
echo "Edit the file /etc/chrony/chrony.conf to include $SERVER_IP...."
echo "server $SERVER_IP" | sudo tee -a /etc/chrony/chrony.conf  > /dev/null
echo ">>Done!"
echo
echo "Comment out (add a "#" in front of) all the pool"
read -p "Press Enter to edit"
sudo nano /etc/chrony/chrony.conf

echo "Start and enable the chronyd service...."
sudo systemctl enable chrony  > /dev/null 2>&1
sudo systemctl restart chrony  > /dev/null 2>&1
echo ">>Done!"
echo

# Verify the sources of the NTP server
echo "Verifying the sources of the NTP server..."
sudo chronyc sources
echo ">>Done!"
