#!/bin/bash
if [ -z "$1" ]; then
  echo "You must specify a group"
else
  group=$1
  shift  # Remove the first argument (group) from the list

  # Check if the group exists, and create it if it does not
  if ! getent group "$group" > /dev/null 2>&1; then
    echo "Group '$group' does not exist, creating group..."
    sudo groupadd "$group"
  fi

  if [ $# -eq 0 ]; then
    echo "You must specify at least one user"
  else
    for user in "$@"; do
      sudo gpasswd -a "$user" "$group"
    done
  fi
fi

