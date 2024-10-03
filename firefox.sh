#!/bin/bash

# Add the Mozilla team's Firefox PPA
echo "Adding Mozilla Firefox PPA..."
sudo add-apt-repository ppa:mozillateam/ppa -y

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install the latest Firefox from the PPA
echo "Installing the latest version of Firefox..."
sudo apt install firefox -y

# Check the installed version of Firefox
echo "Checking the current version of Firefox..."
firefox_version=$(firefox --version)

echo "Firefox has been updated to: $firefox_version"
