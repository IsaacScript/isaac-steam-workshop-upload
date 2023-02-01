#!/bin/bash

set -e # Exit on any errors

echo Enter your Steam username:
read STEAM_USERNAME

if [ -z "$STEAM_USERNAME" ]; then
  echo "Your Steam username cannot be blank. Exiting."
  exit 1
fi

steamcmd \
  +login $STEAM_USERNAME \
  +quit \

CONFIG_VDF_PATH=~/Steam/config/config.vdf

echo "Authentication successful. Your encrypted credentials have been stored in this file: $CONFIG_VDF_PATH"
echo "Now, copy everything in between the hyphen lines, which will be pasted into a GitHub secret."
echo
echo "------------------------------------------------------------------------"
echo
cat $CONFIG_VDF_PATH
echo
echo "------------------------------------------------------------------------"
