# Network Time Protocol

Install `chrony` on both your head and compute nodes

   ```bash
   sudo apt install chrony -y
   ```

1. Head Node
   * Edit the file `/etc/chrony/chrony.conf` to include the internal subnet `e.g. 10.100.50.0/24` of your cluster.

   ```bash
   echo "allow <internal_subnet>" | sudo tee -a /etc/chrony/chrony.conf
   ```
   * Start and enable the `chrony` service
   ```bash
   sudo systemctl enable chrony
   sudo systemctl restart chrony
   ```
   * Verify the NTP synchronization status
   ```bash
   sudo chronyc tracking
   ```

1. Compute Node
   * Edit the file `/etc/chrony/chrony.conf`

     Comment out (add a "#" in front of) all the `pool` and `server` declarations and add this new line to the file:
   ```bash
    server <headnode_ip>
   ```
   * Restart and enable the `chrony` service
   ```bash
   sudo systemctl enable chrony
   sudo systemctl restart chrony
   ```
   * Verify the sources of the NTP server
   ```bash
   sudo chronyc sources
   ```

1. Firewall Configure on Head Node
   * Edit `/etc/nftables/hn.nft` and accept incoming traffic on port 123 UDP
   ```conf
   chain hn_udp_chain {
           udp dport 123 accept
   }
   ```
   * Restart `nftables`

1. Restart `chrony` daemon on your compute node and recheck `chronyc sources`.

1. Verify that `chronyc clients` is now working correctly on your head node.

