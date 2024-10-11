#!/bin/bash

# File paths
pam_password_file="/etc/pam.d/common-password"
pam_auth_file="/etc/pam.d/common-auth"

# Step 1: Set minimum password length to 8 in /etc/pam.d/common-password
echo "Checking and updating minimum password length in $pam_password_file..."

# Check if there is already a 'minlen' setting for pam_unix.so in the common-password file
if grep -q "pam_unix.so" "$pam_password_file"; then
    # Check if minlen is already set, if so update it, otherwise add minlen=8
    if grep -q "minlen=" "$pam_password_file"; then
        sudo sed -i 's/\(pam_unix\.so.*minlen=\)[0-9]*/\18/' "$pam_password_file"
        echo "Updated minimum password length to 8 in $pam_password_file."
    else
        sudo sed -i '/pam_unix\.so/ s/$/ minlen=8/' "$pam_password_file"
        echo "Added minimum password length of 8 to $pam_password_file."
    fi
else
    echo "No pam_unix.so entry found in $pam_password_file. Please check your PAM configuration."
fi

# Step 2: Check for and remove 'nullok' option in /etc/pam.d/common-auth
echo "Checking for and removing 'nullok' option in $pam_auth_file..."

# Check if 'nullok' exists in the common-auth file
if grep -q "nullok" "$pam_auth_file"; then
    # Remove the 'nullok' option
    sudo sed -i 's/\s*nullok//g' "$pam_auth_file"
    echo "'nullok' option removed from $pam_auth_file."
else
    echo "No 'nullok' option found in $pam_auth_file."
fi

# Step 3: Check if UFW is enabled, if not, enable it
echo "Checking UFW (Uncomplicated Firewall) status..."

ufw_status=$(sudo ufw status | grep -i "status:")

if [[ "$ufw_status" == *"inactive"* ]]; then
    echo "UFW is not enabled. Enabling it now..."
    # Enable and Configure UFW (Uncomplicated Firewall)
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow http
    sudo ufw allow https
    sudo ufw enable
    echo "UFW has been enabled."
else
    echo "UFW is already enabled."
fi

# Verify the changes in both files
echo "Verifying changes:"
grep "pam_unix.so" "$pam_password_file"
grep "nullok" "$pam_auth_file" || echo "nullok has been successfully removed."

# File to check
ssh_config_file="/etc/ssh/sshd_config"

# Check if root login is enabled in the SSH config
echo "Checking if SSH root login is enabled..."

if sudo grep -q "^PermitRootLogin yes" "$ssh_config_file"; then
    echo "SSH root login is enabled. Disabling it now..."

    # Disable root login by changing 'PermitRootLogin yes' to 'PermitRootLogin no'
    sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' "$ssh_config_file"

    # Restart SSH service to apply the changes
    sudo systemctl restart ssh
    echo "SSH root login has been disabled and the SSH service restarted."
else
    echo "SSH root login is already disabled."
fi

echo "Script execution complete."
