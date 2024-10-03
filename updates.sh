#!/bin/bash
sudo apt update -y && sudo apt dist-upgrade -y

# Path to APT periodic configuration file
apt_periodic_file="/etc/apt/apt.conf.d/10periodic"

echo "Configuring daily update checks using APT..."

# Create or modify the APT periodic configuration file
sudo tee "$apt_periodic_file" > /dev/null <<EOL
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "0";  # Set to 0 to disable automatic installation
EOL

# Notify the user of the settings
echo "Daily update checks are now configured."
echo "The system will check for updates daily, but not install them automatically."
