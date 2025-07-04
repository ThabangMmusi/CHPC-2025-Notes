# Network File System

Network File System (NFS) allows you to share directories and files with other systems over a network. This is particularly useful in a cluster environment for sharing user home directories or common datasets. This section will guide you through configuring an NFS mount for your `/home` directory.

## NFS Server Configuration (Head Node)

1. Install the NFS server package on your head node:
    ```bash
    sudo apt install nfs-kernel-server
    ```

1. Edit `/etc/exports` on the head node to export `/home` to your internal network:

    ```conf
    /home    <internal_network>(rw,async,no_subtree_check,no_root_squash)
    ```

1. Export the shares and restart the NFS service:

    ```bash
    sudo systemctl restart nfs-kernel-server
    ```

## NFS Client Installation (Compute Node)

On your compute node, you need to install the NFS client utilities:


*   **Ubuntu, Debian**:
    ```bash
    sudo apt install nfs-common
    ```


## Mounting the NFS Share

Before mounting, it's good practice to ensure the mount point exists and is empty. If `/home` already contains data, consider backing it up or mounting the NFS share to a different directory.

To temporarily mount the `/home` directory from your head node to your compute node:

```bash
sudo mount -t nfs <head_node_internal_ip>:/home /home
```

Replace `<head_node_internal_ip>` with the actual internal IP address of your head node.

To make the mount persistent across reboots, add an entry to `/etc/fstab` on your compute node:

```fstab
<head_node_internal_ip>:/home /home nfs defaults,_netdev 0 0
```

The `_netdev` option ensures that the system waits for network connectivity before attempting to mount the NFS share.

## Firewall Configuration for NFS

For NFS to function correctly through your `nftables` firewall, you need to allow the necessary ports. NFS typically uses TCP/UDP ports 111 (rpcbind) and 2049 (nfs). You might also need to allow ports for `mountd` and `statd` (which can vary, but often use dynamic ports or can be fixed in `/etc/nfs.conf`).

Example `nftables` rules to allow NFS traffic:

```nftables
# On Head Node (NFS Server) - allow incoming NFS traffic from compute nodes
table ip filter {
  chain input {
    # ... existing rules ...
    tcp dport { 111, 2049 } accept
    udp dport { 111, 2049 } accept
    # If using dynamic ports for mountd/statd, you might need to allow more broadly or fix ports
    # For example, if mountd uses a fixed port (e.g., 32803) and statd (e.g., 32769)
    # tcp dport { 111, 2049, 32803 } accept
    # udp dport { 111, 2049, 32769 } accept
  }
}

# On Compute Node (NFS Client) - allow outgoing NFS traffic to head node
table ip filter {
  chain output {
    # ... existing rules ...
    tcp dport { 111, 2049 } accept
    udp dport { 111, 2049 } accept
  }
}
```

Remember to apply and persist these rules as described in the `3_Configuring_Firewall_nftables` tutorial.

## Generating an SSH Key for your NFS `/home`

When your `/home` directory is mounted via NFS, your SSH keys will reside on the NFS server (head node). This means that when you SSH into your compute node, your SSH client on the compute node will look for your keys in the NFS-mounted `/home` directory. This is generally seamless, but it's important to understand the interaction.

If you need to generate new SSH keys while your `/home` is NFS mounted, the process is the same as usual:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_chpc
```

Ensure that the permissions on your `.ssh` directory and key files are correct (`chmod 700 ~/.ssh/` and `chmod 600 ~/.ssh/id_ed25519_chpc`). Incorrect permissions will prevent SSH from using the keys.

This setup ensures that your user environment, including SSH keys, is consistent across all nodes in your cluster.