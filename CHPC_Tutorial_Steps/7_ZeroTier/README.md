# ZeroTier for Secure Network Overlay

ZeroTier creates a virtual Ethernet network among distributed devices, enabling secure, direct, and low-latency connections between your head node and compute nodes, regardless of their physical location. This is particularly useful for creating a private network overlay for your cluster.

## Installation

Install ZeroTier on both your head node and all compute nodes. The recommended method is to use the official ZeroTier installation script:

```bash
curl -s https://install.zerotier.com | sudo bash
```

This script detects your operating system and installs the appropriate ZeroTier package.

## Joining a Network

After installation, you need to join your devices to a ZeroTier network. You will need a Network ID, which you can create and obtain from your ZeroTier Central account (<mcurl name="my.zerotier.com" url="https://my.zerotier.com"></mcurl>).

On each node (head and compute), execute the following command, replacing `<network_id>` with your actual ZeroTier network ID:

```bash
sudo zerotier-cli join <network_id>
```

## Authorization

After a device joins your network, it will appear in your ZeroTier Central account as a new member. You must explicitly authorize each new device to allow it to communicate on the network. Log in to <mcurl name="my.zerotier.com" url="https://my.zerotier.com"></mcurl>, navigate to your network, and check the 'Auth' box next to your new device's entry.

## Verifying Connection

Once authorized, your devices should be able to communicate over the ZeroTier network. Each device will be assigned a virtual IP address within your ZeroTier network. You can find these IP addresses in ZeroTier Central or by running `zerotier-cli listnetworks` on the device.

To verify connectivity, ping one device from another using its ZeroTier assigned IP address:

```bash
ping <zerotier_ip_address>
```

## Firewall Considerations

ZeroTier typically uses UDP port 9993 for its communication. Ensure your `nftables` firewall (or any other firewall you are using) allows this traffic, especially if you have strict outbound or inbound rules.

Example `nftables` rules to allow ZeroTier traffic:

```nftables
table ip filter {
  chain input {
    # Allow incoming ZeroTier traffic
    udp dport 9993 accept
  }
  chain output {
    # Allow outgoing ZeroTier traffic
    udp dport 9993 accept
  }
}
```

Remember to apply and persist these rules as described in the `3_Configuring_Firewall_nftables` tutorial.

## Use Cases in a CHPC Environment

ZeroTier can be highly beneficial for CHPC setups:

*   **Remote Access**: Securely access your head node and compute nodes from anywhere without complex VPN configurations.
*   **Distributed Clusters**: Connect compute nodes located in different physical locations as if they were on the same local network.
*   **Simplified Networking**: Abstract away underlying physical network complexities, making it easier to manage your cluster's network topology.
*   **Hybrid Cloud**: Seamlessly integrate on-premise compute resources with cloud-based resources.