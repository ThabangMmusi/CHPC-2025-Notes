#!/bin/bash

# Ensure the TEAM_NAME variable is provided
if [ -z "$1" ]; then
  echo "Error: Please provide a TEAM_NAME."
  exit 1
fi

TEAM_NAME="$1"

echo "Starting the installation and setup process for team: $TEAM_NAME"
echo
# Ubuntu updates and installations (suppress output)
echo "Updating and upgrading packages..."
sudo apt update > /dev/null 2>&1
sudo apt upgrade -y > /dev/null 2>&1
echo ">>Done!"
echo
echo "Installing required packages..."
sudo apt install -y build-essential openmpi-bin libopenmpi-dev libatlas-base-dev wget nano > /dev/null 2>&1
echo ">>Done!"
echo
# Download the source files
echo "Downloading HPL source files..."
cd ~
wget -q http://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz
echo ">>Done!"
echo
# Extract the files from the tarball
echo "Extracting the HPL tarball..."
tar -xzf hpl-2.3.tar.gz > /dev/null 2>&1
echo ">>Done!"
echo
# Move and enter the newly extracted folder
echo "Moving to the extracted HPL folder..."
mv hpl-2.3 ~/hpl
cd ~/hpl
echo ">>Done!"
echo
# remove the downloaded file
echo "Removing dowloaded hpl tar file"
rm ~/hpl-2.3.tar.gz > /dev/null 2>&1
echo ">>Done!"
echo
# Copy the Makefile and edit it for the TEAM_NAME
echo "Copying Makefile for team: $TEAM_NAME"
cp setup/Make.Linux_PII_CBLAS_gm Make.$TEAM_NAME
echo ">>Done!"
echo
echo "Please edit the Make.$TEAM_NAME file:"
echo " - Set ARCH = $TEAM_NAME"
echo " - Set MPdir = /usr/lib/x86_64-linux-gnu/openmpi"
echo " - Set LAdir = /usr/lib/x86_64-linux-gnu/atlas/"
echo " - Set LAlib = \$(LAdir)/libblas.so \$(LAdir)/liblapack.so"
echo " - Set CC = mpicc"
echo " - Set LINKER = mpicc"

# Prompt user to continue before editing Make.<TEAM_NAME>
read -p "Press Enter to continue and edit Make.$TEAM_NAME..."
nano Make.$TEAM_NAME
echo ">>Done!"
echo
# Confirm mpicc is available
echo "Checking if mpicc is available..."
if ! which mpicc > /dev/null 2>&1; then
  echo "mpicc not found. Adding OpenMPI binary path to PATH..."
  export PATH=/usr/lib64/openmpi/bin:$PATH
fi

# Verify mpicc again
if which mpicc > /dev/null 2>&1; then
  echo "mpicc is available."
else
  echo "Error: mpicc still not found. Please check OpenMPI installation."
  exit 1
fi
echo ">>Done!"
echo
# Run the make command
echo "Running make for team: $TEAM_NAME..."
make arch=$TEAM_NAME > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error during make. Please check Make.$TEAM_NAME."
  exit 1
fi

# Verify the xhpl binary has been built
if [ -f "bin/$TEAM_NAME/xhpl" ]; then
  echo "xhpl binary successfully built."
  echo
else
  echo "Error: xhpl binary not found."
  exit 1
fi

# Edit the HPL.dat file
echo "Editing HPL.dat file..."
cd bin/$TEAM_NAME
echo
echo "Make these changes in HPL.dat:"
echo "1  # of process grids (P x Q)"
echo "1  Ps"
echo "1  Qs"

# Prompt user to continue before editing HPL.dat
read -p "Press Enter to continue and edit HPL.dat..."

nano HPL.dat
echo ">>Done!"
echo
# Run the HPL benchmark
echo "Running the HPL benchmark..."
./xhpl
