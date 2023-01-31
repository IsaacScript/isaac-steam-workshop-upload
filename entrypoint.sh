#!/bin/bash

set -e # Exit on any errors
set -u # Treat unset variables as an error

ISAAC_APP_ID="250900"
REPO_PATH=`pwd`
MOD_PATH="$REPO_PATH/mod"
METADATA_XML_PATH="$MOD_PATH/metadata.xml"

# https://stackoverflow.com/questions/5811753/extract-the-first-number-from-a-string
METADATA_XML_ID=$(grep "<id>" "$METADATA_XML_PATH" | awk -F'[^0-9]+' '{ print $2 }')

WORKSHOP_VDF_PATH="/tmp/workshop.vdf"
cat << EOF > "$WORKSHOP_VDF_PATH"
"workshopitem"
{
  "appid"            "$ISAAC_APP_ID"
  "publishedfileid"  "$METADATA_XML_ID"
  "contentfolder"    "$MOD_PATH"
}
EOF

echo "isaac-steam-workshop-upload is uploading the following files from the directory of \"$MOD_PATH\":"
ls -l "$MOD_PATH"
echo

echo "isaac-steam-workshop-upload is using the following vdf file:"
echo
echo "$(cat $WORKSHOP_VDF_PATH)"
echo

export HOME=/home/steam
cd $STEAMCMDDIR

(/home/steam/steamcmd/steamcmd.sh \
    +login $STEAM_USERNAME $STEAM_PASSWORD $STEAM_GUARD_CODE \
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
