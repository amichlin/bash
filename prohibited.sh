#!/bin/bash

# This script checks for Wireshark or ophcrack and removes them if they are installed

# List of insecure software to check
insecure_software=("wireshark" "ophcrack")

for software in "${insecure_software[@]}"; do
  if dpkg -l | grep -q "^ii  $software"; then
    echo "$software is installed. Removing..."
    sudo apt-get remove --purge -y "$software"
    echo "$software has been removed."
  else
    echo "$software is not installed."
  fi
done

echo "Script execution complete."
