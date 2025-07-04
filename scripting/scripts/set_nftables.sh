#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Install nftables with suppressed output
echo "Installing nftables package..."
sudo apt install -y nftables > /dev/null 2>&1
echo "Installed nftables package successfully!!!"
echo

# Update and upgrade packages with suppressed output
echo "Updating and upgrading packages..."
sudo apt update > /dev/null 2>&1
sudo apt upgrade -y > /dev/null 2>&1
echo "Succecfully updated and upgraded packages!!!"
echo

echo "Removing existing ruleset...."
sudo nft flush ruleset
echo "Done removing...."
echo 

# Step 2: Create inet table
echo "Creating inet table 'hn_table'..."
sudo nft add table inet hn_table

# Step 3: Add chains with initial policy set to accept
echo "Creating chains hn_input, hn_forward, and hn_output with policy accept..."
sudo nft add chain inet hn_table hn_input '{ type filter hook input priority 0 ; policy accept ; }'
sudo nft add chain inet hn_table hn_forward '{ type filter hook forward priority 0 ; policy accept ; }'
sudo nft add chain inet hn_table hn_output '{ type filter hook output priority 0 ; policy accept ; }'

# Step 4: Create TCP and UDP chains
echo "Creating hn_tcp_chain and hn_udp_chain..."
sudo nft add chain inet hn_table hn_tcp_chain
sudo nft add chain inet hn_table hn_udp_chain

# Step 5: Add rules to hn_input chain, including SSH access
echo "Adding rules to hn_input chain to allow SSH (port 22)..."
sudo nft add rule inet hn_table hn_input tcp dport ssh accept

# Add rules to allow other necessary traffic before applying strict policies
echo "Add rules to allow other necessary traffic before applying strict policies"
sudo nft add rule inet hn_table hn_input ct state related,established accept
sudo nft add rule inet hn_table hn_input ct state invalid drop
sudo nft add rule inet hn_table hn_input iif lo accept
sudo nft add rule inet hn_table hn_input meta l4proto icmp accept
sudo nft add rule inet hn_table hn_input ip protocol igmp accept
sudo nft add rule inet hn_table hn_input meta l4proto udp reject
sudo nft add rule inet hn_table hn_input meta l4proto tcp reject with tcp reset
sudo nft add rule inet hn_table hn_input counter reject with icmpx port-unreachable

# Add rules to hn_tcp_chain and hn_udp_chain
echo "Adding rules to hn_tcp_chain and hn_udp_chain..."
sudo nft add rule inet hn_table hn_tcp_chain tcp dport 22 accept
sudo nft add rule inet hn_table hn_tcp_chain tcp dport 2049 accept
sudo nft add rule inet hn_table hn_udp_chain udp dport 123 accept
echo

# Step 6: Save the rules to /etc/nftables/hn.nft
echo "Saving current nftables rules to /etc/nftables/hn.nft..."
sudo mkdir -p /etc/nftables
sudo nft -s list ruleset | sudo tee /etc/nftables/hn.nft > /dev/null
echo "Rules saved."
echo

# Step 7: Modify /etc/nftables/hn.nft to change the policy of hn_forward to drop if not already done
echo "Checking if /etc/nftables/hn.nft contains the correct forward chain policy..."
if grep -q 'type filter hook forward priority filter; policy drop;' /etc/nftables/hn.nft; then
  echo "Policy already set to drop. Skipping step."
else
  echo "Modifying forward chain policy to drop..."
  sudo sed -i '/type filter hook forward priority filter;/s/policy accept;/policy drop;/' /etc/nftables/hn.nft
  echo "Policy updated to drop."
fi
echo

# Step 8: Modify /etc/nftables/hn.nft to change the policy of hn_input to drop if not already done
echo "Checking if /etc/nftables/hn.nft contains the correct input chain policy..."
if grep -q 'type filter hook input priority filter; policy drop;' /etc/nftables/hn.nft; then
  echo "Policy already set to drop. Skipping step."
else
  echo "Modifying input chain policy to drop..."
  sudo sed -i '/type filter hook input priority filter;/s/policy accept;/policy drop;/' /etc/nftables/hn.nft
  echo "Policy updated to drop."
fi
echo

# Step 9: Modify /etc/nftables.conf to include hn.nft if not already included
echo "Checking if /etc/nftables.conf already includes /etc/nftables/hn.nft..."
if grep -q 'include "/etc/nftables/hn.nft"' /etc/nftables.conf; then
  echo "Include statement already present. Skipping step."
else
  echo "Adding include statement to /etc/nftables.conf..."
  sudo sed -i '/flush ruleset/a include "/etc/nftables/hn.nft"' /etc/nftables.conf
  echo "Include statement added."
fi
echo

# Restart and enable nftables service
echo
echo "Restarting and enabling nftables service..."
sudo systemctl restart nftables
sudo systemctl enable nftables
echo "nftables setup completed successfully!"
echo

# Step 10: Display the current ruleset before restarting nftables service
echo
echo "Displaying the current nftables ruleset..."
echo "============================================================================="
sudo nft list ruleset
echo "============================================================================="