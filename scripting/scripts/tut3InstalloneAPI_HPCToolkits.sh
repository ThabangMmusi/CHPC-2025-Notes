#!/bin/bash

echo ">>>>>>>>>>>> Starting OneAPI and HPC Toolkit Installation..."

# APT (Ubuntu)
echo ">>>>>>>>>>>> Installing necessary packages..."
sudo apt install libdrm2 libgtk-3-0 libnotify4 xdg-utils libxcb-dri3-0 libgbm1 libatspi2.0-0

echo ">>>>>>>>>>>> Go to home Directory..."
cd ~
# Download offline installers into your HOME directory
echo ">>>>>>>>>>>> Downloading Intel oneAPI Base Toolkit..."
wget https://registrationcenter-download.intel.com/akdlm/IRC_NAS/9a98af19-1c68-46ce-9fdd-e249240c7c42/l_BaseKit_p_2024.2.0.634_offline.sh

echo ">>>>>>>>>>>> Downloading Intel oneAPI HPC Toolkit..."
wget https://registrationcenter-download.intel.com/akdlm/IRC_NAS/d4e49548-1492-45c9-b678-8268cb0f1b05/l_HPCKit_p_2024.2.0.635_offline.sh

# Make the scripts executable
echo ">>>>>>>>>>>> Making installation scripts executable..."
chmod +x l_BaseKit_p_2024.2.0.634_offline.sh
chmod +x l_HPCKit_p_2024.2.0.635_offline.sh

# Run the installation scripts
echo ">>>>>>>>>>>> Running Intel oneAPI Basekit installation..."
./l_BaseKit_p_2024.2.0.634_offline.sh -a --cli --eula accept

echo ">>>>>>>>>>>> Running Intel oneAPI HPCkit installation..."
./l_HPCKit_p_2024.2.0.635_offline.sh -a --cli --eula accept

# Configure your environment
echo ">>>>>>>>>>>> Configuring environment..."

# Ensure the environment uses the correct home directory
source ~/intel/oneapi/setvars.sh
cd ~/intel/oneapi/

./modulefiles-setup.sh

cd ~
echo ">>>>>>>>>>>> Lmod is available. Proceeding with module configuration..."
cd ~
ml use ~/modulefiles
echo ">>>>>>>>>>>> Available modules:"
ml avail
echo ">>>>>>>>>>>> Installation and configuration complete!"
