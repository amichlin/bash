#!/bin/bash

# This script checks for Wireshark, Ophcrack, and other specified software, and removes them if they are installed.
# If nginx is found, it will first stop the service before removing it.

# List of insecure software to check
insecure_software=("wireshark" "ophcrack" "aisleriot" "ettercap-text-only" "ettercap-graphical" "nginx")

for software in "${insecure_software[@]}"; do
  if dpkg -l | grep -q "^ii  $software"; then
    echo "$software is installed."
    
    # Special handling for nginx
    if [ "$software" == "nginx" ]; then
      echo "Stopping nginx service..."
      sudo systemctl stop nginx
    fi
    
    echo "Removing $software..."
    sudo apt-get remove --purge -y "$software"
    echo "$software has been removed."
  else
    echo "$software is not installed."
  fi
done

sudo apt autoremove
echo "Script execution complete."
