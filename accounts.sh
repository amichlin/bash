#!/bin/bash

# List of authorized administrators
declare -A authorized_admins=(
  ["perry"]="M4mm@lOfAct!0n"
  ["carl"]="No#1UnP@!dInt3rn"
  ["monogram"]="Go0glyMo0gly!"
  ["pinky"]="grilledcheese"
  ["wanda"]="Adm!r@l4cr0nym"
)

# List of authorized users
authorized_users=(
  "adyson" "albert" "baljeet" "buford" "candace" "doofenshmirtz"
  "ferb" "ginger" "gretchen" "holly" "irving" "isabella" 
  "jenny" "jeremy" "katie" "lawrence" "linda" "milly" 
  "norm" "phineas" "roger" "stacy" "suzy" "vanessa"
)

# List of default system accounts to be ignored
default_accounts=(
  "root" "daemon" "bin" "sys" "sync" "games" "man" "lp" "mail" "news" "uucp"
  "proxy" "www-data" "backup" "list" "irc" "gnats" "nobody" "systemd-network"
  "systemd-resolve" "messagebus" "systemd-timesync" "syslog" "_apt" "tss"
  "uuidd" "systemd-oom" "tcpdump" "avahi-autoipd" "usbmux" "dnsmasq" "kernoops"
  "avahi" "cups-pk-helper" "rtkit" "whoopsie" "sssd" "speech-dispatcher"
  "nm-openvpn" "saned" "colord" "geoclue" "pulse" "gnome-initial-setup"
  "hplip" "gdm" "rpc" "statd" "sshd" "_rpc"
)

# Combine both authorized administrators and users into one array
authorized_accounts=("${!authorized_admins[@]}" "${authorized_users[@]}")

# Function to create accounts if missing and set password to M4mm@lOfAct!0n
create_account() {
  local user=$1
  if ! id -u "$user" &>/dev/null; then
    echo "Creating user: $user"
    sudo useradd -m "$user"
  fi
  echo "$user:M4mm@lOfAct!0n" | sudo chpasswd
}

# Ensure authorized users exist and set their passwords to M4mm@lOfAct!0n
for user in "${authorized_users[@]}"; do
  create_account "$user"
done

# Ensure authorized administrators exist, set their passwords to M4mm@lOfAct!0n, and grant sudo privileges
for admin in "${!authorized_admins[@]}"; do
  create_account "$admin"
  if ! id -nG "$admin" | grep -qw "sudo"; then
    echo "Granting sudo privileges to authorized admin: $admin"
    sudo usermod -aG sudo "$admin"
  fi
done

# List of all users on the system
all_users=$(cut -d: -f1 /etc/passwd)

# Function to delete unauthorized users
delete_user() {
  local user=$1
  echo "Deleting unauthorized user: $user"
  sudo userdel -r "$user"
}

# Delete users not in the authorized list and not in default accounts
for user in $all_users; do
  if [[ ! " ${authorized_accounts[*]} " =~ " ${user} " ]] && [[ ! " ${default_accounts[*]} " =~ " ${user} " ]]; then
    delete_user "$user"
  fi
done

echo "Script execution complete."
