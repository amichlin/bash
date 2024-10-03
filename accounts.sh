#!/bin/bash

# List of authorized administrators
declare -A authorized_admins=(
  ["perry"]="M4mm@lOfAct!0n"
  ["carlos"]="MagicFore$t4"
  ["kan"]="uCanD0It!!"
  ["alice"]="alice"
  ["josefina"]="RocketShip@27"
)

# List of authorized users
authorized_users=(
  "jaimie"
  "adalbern"
  "amayas"
  "fabienne"
  "mariya"
  "cornelius"
  "harold"
  "taran"
  "felix"
  "angela"
  "rais"
  "miriam"
  "aldo"
  "timothy"
  "leilani"
  "viktor"
  "linda"
  "jeanne"
  "martin"
  "josef"
  "roger"
  "stacy"
  "suzy"
  "liz"
)

# List of default system accounts to be ignored
default_accounts=(
  "root" "daemon" "bin" "sys" "sync" "games" "man" "lp" "mail" "news" "uucp" 
  "proxy" "www-data" "backup" "list" "irc" "gnats" "nobody" "systemd-network"
  "systemd-resolve" "messagebus" "systemd-timesync" "syslog" "_apt" "tss"
  "uuidd" "systemd-oom" "tcpdump" "avahi-autoipd" "usbmux" "dnsmasq" "kernoops"
  "avahi" "cups-pk-helper" "rtkit" "whoopsie" "sssd" "speech-dispatcher"
  "nm-openvpn" "saned" "colord" "geoclue" "pulse" "gnome-initial-setup" 
  "hplip" "gdm" "rpc" "statd" "sshd"
)

# Combine both authorized administrators and users into one array
authorized_accounts=("${!authorized_admins[@]}" "${authorized_users[@]}")

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
  echo "$user:M4mm@lOfAct!0n" | sudo chpasswd
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

echo "Script execution complete."
