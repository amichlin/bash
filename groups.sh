#!/bin/bash
if [ -z "$1" ]; then
  echo "You must specify a username"
elif [ -z "$2" ]; then
  echo "You must specify a group"
else
  sudo gpasswd -a $1 $2
fi
