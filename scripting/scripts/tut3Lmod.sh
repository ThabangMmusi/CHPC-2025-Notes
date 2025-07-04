#!/bin/bash

# Update and install necessary packages
echo "Updating packages..."
sudo apt update
echo "Upgrading packages..."
sudo apt upgrade -y
echo "Installing required packages..."
sudo apt install -y git gcc make
sudo apt install -y tcl tcl-dev lua5.3 liblua5.3-dev lua-posix bc

# Clone the Lmod repository into the user's home directory
echo "Cloning the Lmod repository into the home directory..."
cd $HOME
git clone https://github.com/TACC/Lmod.git

# Navigate into the Lmod directory
echo "Navigating into the Lmod directory..."
cd $HOME/Lmod

# Run the configuration script and install into the user's home directory
echo "Running configuration script..."
./configure --prefix=$HOME/lmod

# Build Lmod
echo "Building Lmod..."
make -j$(nproc)

# Install Lmod
echo "Installing Lmod..."
make install
