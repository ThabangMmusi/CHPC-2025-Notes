#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Install nftables if not already installed
if ! command -v nft &> /dev/null
then
    echo "nftables not found, installing..."
    sudo apt update
    sudo apt install -y nftables
else
    echo "nftables is already installed."
fi

echo "Creating nftables table and chains..."
sudo nft add table inet hn_table
sudo nft add chain inet hn_table hn_input '{ type filter hook input priority 0 ; policy accept ; }'
sudo nft add chain inet hn_table hn_forward '{ type filter hook forward priority 0 ; policy accept ; }'
sudo nft add chain inet hn_table hn_output '{ type filter hook output priority 0 ; policy accept ; }'
sudo nft add chain inet hn_table hn_tcp_chain
sudo nft add chain inet hn_table hn_udp_chain

echo "Adding nftables rules..."
sudo nft add rule inet hn_table hn_input ct state related,established accept
sudo nft add rule inet hn_table hn_input ct state invalid drop
sudo nft add rule inet hn_table hn_input iif lo accept
sudo nft add rule inet hn_table hn_input meta l4proto icmp accept
sudo nft add rule inet hn_table hn_input ip protocol igmp accept
sudo nft add rule inet hn_table hn_input meta l4proto udp ct state new jump hn_udp_chain
sudo nft add rule inet hn_table hn_input 'meta l4proto tcp tcp flags & (fin|syn|rst|ack) == syn ct state new jump hn_tcp_chain'
sudo nft add rule inet hn_table hn_input meta l4proto udp reject
sudo nft add rule inet hn_table hn_input meta l4proto tcp reject with tcp reset
sudo nft add rule inet hn_table hn_input counter reject with icmpx port-unreachable
sudo nft add rule inet hn_table hn_tcp_chain tcp dport 22 accept

echo "Saving current nftables rules to /etc/nftables/hn.nft..."
sudo mkdir -p /etc/nftables
sudo nft -s list ruleset | sudo tee /etc/nftables/hn.nft > /dev/null

echo "Modifying /etc/nftables/hn.nft to set input and forward policies to drop..."
sudo sed -i '/type filter hook input priority 0 ; policy accept ;/s/policy accept ;/policy drop ;/' /etc/nftables/hn.nft
sudo sed -i '/type filter hook forward priority 0 ; policy accept ;/s/policy accept ;/policy drop ;/' /etc/nftables/hn.nft

echo "Configuring /etc/sysconfig/nftables.conf..."
if ! grep -q "include \"/etc/nftables/hn.nft\"" /etc/sysconfig/nftables.conf; then
  sudo sed -i '/flush ruleset/a include "/etc/nftables/hn.nft"' /etc/sysconfig/nftables.conf
else
  echo "Include statement already present in /etc/sysconfig/nftables.conf. Skipping."
fi

echo "Restarting and enabling nftables service..."
sudo systemctl restart nftables
sudo systemctl enable nftables

echo "nftables configuration complete."