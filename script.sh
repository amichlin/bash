#!/bin/bash

# Update and Upgrade the System
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Required Software
sudo apt-get install -y ufw gdm3 perl thunderbird

# Add Google Chrome repository and install Chrome
if ! command -v google-chrome &> /dev/null; then
  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
  sudo apt-get update -y
  sudo apt-get install -y google-chrome-stable
fi

# Enable and Configure UFW (Uncomplicated Firewall)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable

# Set Password Policies
# Remove pam_cracklib if it exists
sudo sed -i '/pam_cracklib.so/d' /etc/pam.d/common-password

# Set Strong Password Policy using pam_pwquality
sudo apt-get install -y libpam-pwquality
sudo sed -i '/pam_pwquality\.so/s/$/ retry=3 minlen=8 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password

# Disable Unnecessary Services
services=("telnet" "ftp" "rlogin" "rexec")
for service in "${services[@]}"; do
    sudo systemctl disable $service
    sudo systemctl stop $service
done

# Remove Unnecessary Packages
packages=("telnetd" "ftp" "rsh-client" "rsh-server")
for package in "${packages[@]}"; do
    sudo apt-get remove --purge -y $package
done

# Secure Shared Memory
if ! grep -q "/run/shm" /etc/fstab; then
    echo "tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0" | sudo tee -a /etc/fstab
    sudo mount -o remount /run/shm
fi

# Ensure Audit Logging is Enabled
sudo systemctl enable auditd
sudo systemctl start auditd

# Update File Permissions for Sensitive Files
sudo chmod 640 /etc/shadow
sudo chmod 640 /etc/gshadow
sudo chmod 644 /etc/passwd
sudo chmod 644 /etc/group

# User and Group Management
# Add candace to firesidegirls group
if ! getent group firesidegirls > /dev/null; then
    sudo groupadd firesidegirls
fi
sudo usermod -aG firesidegirls candace

# Disable guest account
if [ -f /etc/lightdm/lightdm.conf ]; then
    sudo sed -i '/\[SeatDefaults\]/a allow-guest=false' /etc/lightdm/lightdm.conf
fi

# Lock Suspicious or Unused Accounts
for user in $(awk -F: '($3 < 1000 && $3 != 0) {print $1}' /etc/passwd); do
    sudo usermod -L $user
done

# Update and Configure SSH Settings
sudo sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/#X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
sudo systemctl enable sshd
sudo systemctl restart sshd

# Run ClamAV to Scan for Viruses
sudo freshclam
sudo clamscan -r / --quiet --exclude-dir="^/sys" --exclude-dir="^/proc" --exclude-dir="^/dev"

# Run Lynis for System Auditing
sudo lynis audit system

# Authorized Administrators and Users
declare -A authorized_admins=(
  ["perry"]="M4mm@lOfAct!0n"
  ["carl"]="No#1UnP@!dInt3rn"
  ["monogram"]="Go0glyMo0gly!"
  ["pinky"]="grilledcheese"
  ["wanda"]="Adm!r@l4cr0nym"
)

authorized_users=(
  "adyson" "albert" "baljeet" "buford" "candace" "doofenshmirtz" "ferb" "ginger"
  "gretchen" "holly" "irving" "isabella" "jenny" "jeremy" "katie" "lawrence"
  "linda" "milly" "norm" "phineas" "roger" "stacy" "suzy" "vanessa"
)

# Combine both authorized administrators and users into one array
authorized_accounts=("${!authorized_admins[@]}" "${authorized_users[@]}")

# List of default system accounts to be ignored
default_accounts=("root" "daemon" "bin" "sys" "sync" "games" "man" "lp" "mail" "news" "uucp" \
"proxy" "www-data" "backup" "list" "irc" "gnats" "nobody" "systemd-network" \
"systemd-resolve" "messagebus" "systemd-timesync" "syslog" "_apt" "tss" \
"uuidd" "systemd-oom" "tcpdump" "avahi-autoipd" "usbmux" "dnsmasq" "kernoops" \
"avahi" "cups-pk-helper" "rtkit" "whoopsie" "sssd" "speech-dispatcher" \
"nm-openvpn" "saned" "colord" "geoclue" "pulse" "gnome-initial-setup" \
"hplip" "gdm" "rpc" "statd" "sshd")

# Function to delete unauthorized users
delete_user() {
  local user=$1
  echo "Deleting user: $user"
  sudo userdel -r "$user"
}

# Function to change password of valid users
change_password() {
  local user=$1
  echo "Changing password for user: $user"
  echo "$user:blUEc|r1ft" | sudo chpasswd
}

# Get a list of all users on the system
all_users=$(cut -d: -f1 /etc/passwd)

# Delete users not in the authorized list and not in default accounts
for user in $all_users; do
  if [[ ! " ${authorized_accounts[*]} " =~ " ${user} " ]] && [[ ! " ${default_accounts[*]} " =~ " ${user} " ]]; then
    delete_user "$user"
  else
    change_password "$user"
  fi
done

# Function to remove admin privileges from unauthorized users
demote_admin() {
  local user=$1
  echo "Demoting admin privileges for user: $user"
  sudo gpasswd -d "$user" sudo
}

# Check for users in the 'sudo' group (administrators)
sudo_users=$(getent group sudo | cut -d: -f4 | tr ',' ' ')

# Demote any unauthorized administrators, except for default admin accounts
for user in $sudo_users; do
  if [[ ! ${authorized_admins[$user]} ]] && [[ ! " ${default_accounts[*]} " =~ " ${user} " ]]; then
    demote_admin "$user"
  fi
done

# Ensure authorized admins have admin rights
for admin in "${!authorized_admins[@]}"; do
  if ! id -nG "$admin" | grep -qw "sudo"; then
    echo "Granting sudo privileges to authorized admin: $admin"
    sudo usermod -aG sudo "$admin"
  fi
done

echo "Script execution complete. Manual review recommended."
