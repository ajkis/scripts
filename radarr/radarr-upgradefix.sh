#!/bin/bash
# READ ME 
# Fix for upgrading existing movies.
# In Radarr go in Settings -> Connect -> + Custom Script
# Enable On Download ( the rest disabled )
# In path set: /bin/bash
# In arrguments set: /path to script/radarr-upgradefix.sh and save
# 
# SCRIPT SETTINGS
# If is set to 0, just movie file will be deleted. 
# (personally i prefer to delete folder so I get rid of old subtitles)
DELETEFOLDER=1 
# If you use UNIONFS or other fuse overlays set it to 1 
# and change REPLACEUFSPATH and ACTUALPATH 
REPLACEPATH=1  
# Make sure you change the paths if you set REPLACEPATH=1
REPLACEUFSPATH=/mnt/unionfs/
ACTUALPATH=/mnt/acdcrypt/
# LOGFILE LOCATATION
LOGFILE="/home/plex/logs/radarr-upgradefix.log"

echo "$(date "+%d.%m.%Y %T") Radarr Event: $radarr_eventtype file: $radarr_moviefile_path" >> "$LOGFILE"
# Check if movie already exist
if [[ -f "$radarr_moviefile_path" ]] ; then
	if [[ REPLACEPATH -eq 1 ]] ; then 
		radarr_moviefile_path=${radarr_moviefile_path/$REPLACEUFSPATH/$ACTUALPATH}
	fi
	if [[ DELETEFOLDER -eq 1 ]] ; then
		echo "$(date "+%d.%m.%Y %T") Deleting existing movie folder:" $(dirname "${radarr_moviefile_path}") >> "$LOGFILE"
		rm -rf $(dirname "${radarr_moviefile_path}")
	else
		echo "$(date "+%d.%m.%Y %T") Deleting existing movie file: $radarr_moviefile_path" >> "$LOGFILE"
		rm "$radarr_moviefile_path"
	fi
fi
exit
