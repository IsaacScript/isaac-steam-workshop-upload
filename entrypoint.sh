#!/bin/bash

set -e # Exit on any errors
set -u # Treat unset variables as an error

REPO=`pwd`
MOD_PATH="$REPO/$2"

export HOME=/home/steam
cd $STEAMCMDDIR

ls -l # Debug
echo "isaac-steam-workshop-upload is uploading the following files from the directory of \"$MOD_PATH\":"
ls -l "$MOD_PATH"
echo

cat << EOF > ./workshop.vdf
"workshopitem"
{
  "appid"            "250900"
  "publishedfileid"  "$1"
  "contentfolder"    "$MOD_PATH"
}
EOF

echo "isaac-steam-workshop-upload is using the following vdf file:"
echo
echo "$(cat ./workshop.vdf)"
echo

(/home/steam/steamcmd/steamcmd.sh \
    +login $STEAM_USERNAME $STEAM_PASSWORD $STEAM_GUARD_CODE \
    +workshop_build_item `pwd -P`/workshop.vdf \
    +quit \
) || (
    # https://partner.steamgames.com/doc/features/workshop/implementation#SteamCmd
    echo /home/steam/Steam/logs/stderr.txt
    echo "$(cat /home/steam/Steam/logs/stderr.txt)"
    echo
    echo /home/steam/Steam/logs/workshop_log.txt
    echo "$(cat /home/steam/Steam/logs/workshop_log.txt)"
    echo
    echo /home/steam/Steam/workshopbuilds/depot_build_$1.log
    echo "$(cat /home/steam/Steam/workshopbuilds/depot_build_$1.log)"

    exit 1
)

exit 0
