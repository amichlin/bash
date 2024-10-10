#!/bin/bash
if [ -z "$1" ]; then
  echo "You must specify a group"
else
  group=$1
  shift  # Remove the first argument (group) from the list

  if [ $# -eq 0 ]; then
    echo "You must specify at least one user"
  else
    for user in "$@"; do
      sudo gpasswd -a "$user" "$group"
    done
  fi
fi

