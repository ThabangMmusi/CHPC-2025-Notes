# Configuring a Simple Stateful Firewall Using nftables

This section will guide you through configuring a simple stateful firewall using `nftables`.

`nftables` is a powerful and flexible packet filtering framework that replaces `iptables`. It offers a more modern syntax and improved performance.

## Basic `nftables` Configuration
1. Install the userspace utilities package
   
   ```bash
   sudo apt install nftables
   ```
1. Check and clear the existing firewall configuration
   ```bash
   sudo nft list ruleset
   sudo nft flush ruleset
   ```
1. Create a new `table` to house the rules for your head node
   ```bash
   sudo nft add table inet hn_table
   ```
1. Add the `input`, `forward`, and `output` base chains.
   The policy for `input` and `forward` will be initially set to `accept`, and then `drop` thereafter. The policy for `output` will be to `accept`.
   ```bash
   # If you set this to drop now, you will not be able to access your head node via ssh
   sudo nft add chain inet hn_table hn_input '{ type filter hook input priority 0 ; policy accept ; }'
   sudo nft add chain inet hn_table hn_forward '{ type filter hook forward priority 0 ; policy accept ; }'
   sudo nft add chain inet hn_table hn_output '{ type filter hook output priority 0 ; policy accept ; }'
   ```

1. Specific rules for TCP and UDP will be managed by additional chains
   ```bash
   sudo nft add chain inet hn_table hn_tcp_chain
   sudo nft add chain inet hn_table hn_udp_chain
   ```
1. Accept `related` and `established` traffic while dropping all `invalid` traffic
   ```bash
   sudo nft add rule inet hn_table hn_input ct state related,established accept
   sudo nft add rule inet hn_table hn_input ct state invalid drop
   ```
1. Accept all traffic on the loopback (lo) interface
   ```bash
   sudo nft add rule inet hn_table hn_input iif lo accept
   ```
1. Accept ICMP and IGMP traffic
   ```bash
   sudo nft add rule inet hn_table hn_input meta l4proto icmp accept
   sudo nft add rule inet hn_table hn_input ip protocol igmp accept
   ```
1. `new` udp and tcp is configured to `jump` to there respective chains
   ```bash
   sudo nft add rule inet hn_table hn_input meta l4proto udp ct state new jump hn_udp_chain

   sudo nft add rule inet hn_table hn_input 'meta l4proto tcp tcp flags & (fin|syn|rst|ack) == syn ct state new jump hn_tcp_chain'
   ```
1. All traffic that failed to be processed by any other rules is `rejected`
   ```bash
   sudo nft add rule inet hn_table hn_input meta l4proto udp reject

   sudo nft add rule inet hn_table hn_input meta l4proto tcp reject with tcp reset
   sudo nft add rule inet hn_table hn_input counter reject with icmpx port-unreachable
   ```
1. Finally, add a rule to accept SSH traffic
   ```bash
   sudo nft add rule inet hn_table hn_tcp_chain tcp dport 22 accept
   ```
1. You can now save your configuration to an output file
   ```bash
   sudo mkdir -p /etc/nftables
   sudo nft -s list ruleset | sudo tee /etc/nftables/hn.nft
   ```
1. Edit your head node's nft file and modify the policy for `input` and `forward ` to be `drop`
   ```bash
   sudo nano /etc/nftables/hn.nft
   ```
1. Amend the configuration file to include your changes when the service is restarted
   * Edit `nftables.conf`
   ```bash
   sudo nano /etc/nftables.conf
   ```
   * Add the following:
   ```conf
   flush ruleset
   include "/etc/nftables/hn.nft"
   ```
Restart and enable the `nftables` service.