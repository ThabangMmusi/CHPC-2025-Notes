#!/bin/bash

echo "Disabling Ubuntu login banners and MOTD…"

# Disable all dynamic MOTD scripts
sudo chmod -x /etc/update-motd.d/*

# Clear any static MOTD
sudo truncate -s 0 /etc/motd

# Suppress 'last login' and 'mail' by creating .hushlogin
touch ~/.hushlogin

echo "✅ Login banners removed. Please log out and SSH back in to see the effect."