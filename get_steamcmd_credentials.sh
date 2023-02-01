#!/bin/bash

set -e # Exit on any errors

# Install steamcmd
sudo apt install software-properties-common
sudo add-apt-repository multiverse
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install steamcmd

echo Enter your Steam username:
read STEAM_USERNAME

if [ -z "$STEAM_USERNAME" ]; then
  echo "Your Steam username cannot be blank. Exiting."
  exit 1
fi

steamcmd \
  +login $STEAM_USERNAME \
  +quit \

CONFIG_VDF_PATH="~/Steam/config/config.vdf"

echo "Authentication successful. Your encrypted credentials have been stored in this file: $CONFIG_VDF_PATH"
echo "Now, copy everything in between the hyphens, which will be pasted into a GitHub secret."
echo
echo "------------------------------------------------------------------------"
echo
cat "~/Steam/config/config.vdf"
echo
echo "------------------------------------------------------------------------"
