#!/bin/bash
## This script reads from file stored on drive and only refreshes those folders that are in list.
## NOTE: This script wont work without my other script that generate folder list 
## Work in progress....

if pidof -o %PPID -x "$0"; then
   echo "$(date "+%d.%m.%Y %T") Exit, already running."
   exit 1
fi
export LD_LIBRARY_PATH=/usr/lib/plexmediaserver
export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/var/lib/plexmediaserver/Library/Application\ Support
LOGFILE="/home/plex/logs/plexrefresh.cron.log"
PATHTOLISTS="acdcrypt:/tmp/"
CMDLSL="rclone lsl $PATHTOLISTS --include *.list"
CMDCUT="rclone cat -q $PATHTOLISTS"
## STORE ALL .LIST FILES IN ARRAY 
readarray -t FILES < <($CMDLSL | sort -k2,3 ) 

for PLEXLIST in "${FILES[@]}"
do
	## REMOVE SIZE AND MODIFICATION TIME
	PLEXLIST="${PLEXLIST: -29}"
	## STORE FOLDERS IN ARRAY
	readarray -t REFRESHFOLDERS < <($CMDCUT$PLEXLIST)
	## DELETE LIST
	rclone delete $PATHTOLISTS$PLEXLIST
	## RUN PLEX CLI TO REFRESH FOLDERS BASED ON LIBRARY
	for FOLDER in "${REFRESHFOLDERS[@]}"
	do
		if [[  $FOLDER == *"/movies/"* ]] ; then
		    echo "$(date "+%d.%m.%Y %T") Refreshing movie folder: $FOLDER" | tee -a "$LOGFILE"
			/usr/lib/plexmediaserver/Plex\ Media\ Scanner --scan --refresh --section 2 --directory "${FOLDER}" | tee -a "$LOGFILE"
		fi
		if [[  $FOLDER == *"/series/"* ]] ; then
		    echo "$(date "+%d.%m.%Y %T") Refreshing serie folder: $FOLDER" | tee -a "$LOGFILE"
			/usr/lib/plexmediaserver/Plex\ Media\ Scanner --scan --refresh --section 1 --directory "${FOLDER}" | tee -a "$LOGFILE"
		fi
	done
done
exit
