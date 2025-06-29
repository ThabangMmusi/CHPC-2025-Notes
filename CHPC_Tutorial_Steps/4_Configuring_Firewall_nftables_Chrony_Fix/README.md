# Network Time Protocol

Accurate time synchronization is crucial for distributed systems, logging, and security. This section will guide you through configuring Network Time Protocol (NTP) on your compute node using `chrony`.

`chrony` is a modern, more accurate, and efficient alternative to `ntpd` for synchronizing the system clock.

## Installation

To install `chrony` on your system, use the appropriate package manager:


*   **Ubuntu, Debian**:
    ```bash
    sudo apt install chrony
    ```


## Configuration

The main configuration file for `chrony` is typically located at `/etc/chrony.conf` or `/etc/chrony/chrony.conf`.

Open the file with a text editor:

```bash
sudo nano /etc/chrony.conf
```

Ensure that you have appropriate NTP server entries. You can use public NTP pools or your own internal NTP servers. For example:

```conf
# Use public NTP servers from the NTP Pool Project
pool 0.pool.ntp.org iburst
pool 1.pool.ntp.org iburst
pool 2.pool.ntp.org iburst
pool 3.pool.ntp.org iburst

# Allow NTP clients from your internal network (replace with your actual network)
allow 10.100.0.0/16

# Enable NTP server functionality (if you want this node to serve time)
local stratum 10
```

## Starting and Enabling Chrony

After configuring, start and enable the `chrony` service:

```bash
sudo systemctl enable chronyd
sudo systemctl start chronyd
```

## Verifying Synchronization

To check the synchronization status and sources, use the `chronyc` command:

```bash
chronyc tracking
chronyc sources
```

## Firewall Configuration for NTP

If you have a firewall configured (e.g., `nftables`), ensure that UDP port 123 (NTP) is open for both incoming and outgoing traffic, especially if this node will act as an NTP server or needs to reach external NTP servers.

Example `nftables` rule to allow NTP:

```nftables
# Allow incoming NTP (UDP port 123)
udp dport 123 accept
```

Accurate time synchronization is vital for the correct operation and security of your cluster. Ensure `chrony` is properly configured and running.