#!/bin/bash

set -e # Exit on any errors.
set -u # Treat unset variables as an error.

MOD_PATH_RELATIVE="$1"
IGNORE_FILES="$2"
COMMIT_MESSAGE="$3"
ISAAC_APP_ID="250900"
REPO_PATH=`pwd`
MOD_PATH="$REPO_PATH/$MOD_PATH_RELATIVE"
METADATA_XML_PATH="$MOD_PATH/metadata.xml"

echo "The contents of the current directory (\"REPO_PATH\") are:"
ls -al
echo

if [ ! -d "$MOD_PATH" ]; then
  echo "Error: The specified \"mod_path\" is not a directory: $MOD_PATH"
fi

echo "The contents of the mod_path (\"MOD_PATH\") directory are:"
ls -al "$MOD_PATH"
echo

if [ ! -f "$METADATA_XML_PATH" ]; then
  echo "Error: The \"metadata.xml\" file was not found at: $METADATA_XML_PATH"
  exit 1
fi

# https://stackoverflow.com/questions/5811753/extract-the-first-number-from-a-string
METADATA_XML_ID=$(grep "<id>" "$METADATA_XML_PATH" | awk -F'[^0-9]+' '{ print $2 }')

if [ -z "$CONFIG_VDF_CONTENTS" ]; then
 echo "Error: The CONFIG_VDF_CONTENTS environment variable was blank."
 exit 1
fi

# Parse the provided "config.vdf" file for the Steam username.
CONFIG_VDF_CONTENTS_NO_WHITESPACE=$(echo $CONFIG_VDF_CONTENTS | sed 's/[[:blank:]]//g')
STEAM_USERNAME=$(echo $CONFIG_VDF_CONTENTS_NO_WHITESPACE | perl -lne 's/"Accounts"{"(.+?)"// or next; s/\s.*//; print $1')

# Blow away the existing "config.vdf" file with the one provided by the end-user.
CONFIG_VDF_PATH="/home/steam/Steam/config/config.vdf"
echo $CONFIG_VDF_CONTENTS > $CONFIG_VDF_PATH

# Parse the version from the commit message.
# https://stackoverflow.com/questions/16623835/remove-a-fixed-prefix-suffix-from-a-string-in-bash
VERSION=$(echo "$COMMIT_MESSAGE" | sed -e 's/^\s*chore: release\s*//')

# Create the temporary vdf file that steamcmd uses for the upload operation.
WORKSHOP_VDF_PATH="/tmp/workshop.vdf"
cat << EOF > "$WORKSHOP_VDF_PATH"
"workshopitem"
{
  "appid"            "$ISAAC_APP_ID"
  "publishedfileid"  "$METADATA_XML_ID"
  "contentfolder"    "$MOD_PATH"
  "changenote"       "$VERSION"
}
EOF

# Clean up files that were explicitly provided to us by the end-user.
echo "isaac-steam-workshop-upload is removing the following ignored files from the directory of \"$MOD_PATH\" before uploading:"
IGNORE_FILES_ARRAY=(${IGNORE_FILES//,/ })
for i in "${IGNORE_FILES_ARRAY[@]}"; do
  if [ ! -z "$i" ]; then
    ls -al "$MOD_PATH/$i"
    rm -rf "$MOD_PATH/$i"
  fi
done

echo "isaac-steam-workshop-upload is uploading the following files from the directory of \"$MOD_PATH\":"
ls -al "$MOD_PATH"
echo

echo "isaac-steam-workshop-upload is using the following vdf file:"
echo
echo "$(cat $WORKSHOP_VDF_PATH)"
echo

export HOME=/home/steam
cd $STEAMCMDDIR

(/home/steam/steamcmd/steamcmd.sh \
    +login $STEAM_USERNAME \
    +workshop_build_item $WORKSHOP_VDF_PATH \
    +quit \
) || (
    # https://partner.steamgames.com/doc/features/workshop/implementation#SteamCmd
    echo /home/steam/Steam/logs/stderr.txt
    echo "$(cat /home/steam/Steam/logs/stderr.txt)"
    echo
    echo /home/steam/Steam/logs/workshop_log.txt
    echo "$(cat /home/steam/Steam/logs/workshop_log.txt)"
    echo
    echo /home/steam/Steam/workshopbuilds/depot_build_$ISAAC_APP_ID.log
    echo "$(cat /home/steam/Steam/workshopbuilds/depot_build_$ISAAC_APP_ID.log)"

    exit 1
)

exit 0
