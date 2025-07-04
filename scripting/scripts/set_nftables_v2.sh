#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root" >&2
  exit 1
fi

# Function to check for command success
check_success() {
  if [ $? -ne 0 ]; then
    echo "Error: $1 failed." >&2
    exit 1
  fi
}

echo "Updating package lists..."
sudo apt update > /dev/null 2>&1
check_success "apt update"

echo "Installing nftables package..."
sudo apt install -y nftables > /dev/null 2>&1
check_success "nftables installation"

# Define the nftables ruleset in a temporary file
NFT_RULES_FILE="/tmp/hn.nft"

cat << EOF > "$NFT_RULES_FILE"
#!/usr/sbin/nft -f

flush ruleset

table inet hn_table {
  chain hn_input {
    type filter hook input priority 0 ; policy drop ;

    # Allow established and related connections
    ct state related,established accept

    # Drop invalid connections
    ct state invalid drop

    # Allow loopback traffic
    iif lo accept

    # Jump to TCP/UDP chains for specific ports
    tcp dport { ssh, 2049 } jump hn_tcp_chain
    udp dport { 123 } jump hn_udp_chain

    # Reject other UDP traffic
    meta l4proto udp reject

    # Reject other TCP traffic with TCP reset
    meta l4proto tcp reject with tcp reset

    # Reject other traffic with icmpx port-unreachable
    counter reject with icmpx port-unreachable
  }

  chain hn_forward { type filter hook forward priority 0 ; policy drop ; }
  chain hn_output { type filter hook output priority 0 ; policy accept ; }

  chain hn_tcp_chain {
    tcp dport ssh accept
    tcp dport 2049 accept
  }

  chain hn_udp_chain {
    udp dport 123 accept
  }
}
EOF

echo "Applying nftables rules..."
sudo nft -f "$NFT_RULES_FILE"
check_success "nftables rules application"

# Save the rules to /etc/nftables/hn.nft for persistence
echo "Saving nftables rules to /etc/nftables/hn.nft..."
sudo mkdir -p /etc/nftables
sudo cp "$NFT_RULES_FILE" /etc/nftables/hn.nft
check_success "saving nftables rules"

# Modify /etc/nftables.conf to include hn.nft if not already included
echo "Configuring nftables service to load rules..."
if ! grep -q 'include "/etc/nftables/hn.nft"' /etc/nftables.conf; then
  sudo sed -i '/flush ruleset/a include "/etc/nftables/hn.nft"' /etc/nftables.conf
  check_success "modifying nftables.conf"
fi

# Restart and enable nftables service
echo "Restarting and enabling nftables service..."
sudo systemctl restart nftables
check_success "nftables service restart"
sudo systemctl enable nftables > /dev/null 2>&1
check_success "nftables service enable"

echo "nftables setup completed successfully!"

# Display the current ruleset
echo "\nDisplaying the current nftables ruleset:"
echo "============================================================================="
sudo nft list ruleset
echo "============================================================================="

# Clean up temporary file
rm "$NFT_RULES_FILE"