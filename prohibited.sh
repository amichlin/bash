#!/bin/bash

# This script checks for Wireshark or ophcrack and removes them if they are installed

# List of insecure software to check
insecure_software=("wireshark" "ophcrack" "aisleriot" "ettercap-text-only" "ettercap-graphical")

for software in "${insecure_software[@]}"; do
  if dpkg -l | grep -q "^ii  $software"; then
    echo "$software is installed. Removing..."
    sudo apt-get remove --purge -y "$software"
    echo "$software has been removed."
  else
    echo "$software is not installed."
  fi
done

# Remove Unnecessary Packages
packages=("telnetd" "ftp" "rsh-client" "rsh-server")
for package in "${packages[@]}"; do
    sudo apt-get remove --purge -y $package
done

echo "Script execution complete."
