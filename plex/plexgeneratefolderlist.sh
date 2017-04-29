#!/bin/bash
## THIS SCRIPT WILL GENERATE FOLDER LIST BEFORE UPLOADING WITH RCLONE.
## THE SECOND SCRIPT PLEXREFRESHFOLDERS WILL RUN PLEX SCANNER ONLY ON GENERATED FOLDERS.
## FOLDER LIST WILL HAVE LOCAL PATH REPLACED WITH UNIONFS ONES

# EXIT IF SCRIPT IF ALREADY RUNNING
if pidof -o %PPID -x "$0"; then
   echo "$(date "+%d.%m.%Y %T") Already running, exiting."
   exit 1
fi

TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
LOGFILE="/home/plex/logs/local2acdcrypt.cron.log"
MOVIES="/storage/local/movies"
SERIES="/storage/local/series"
LOCALPATH="/storage/local/"
UNIONFSPATH="/mnt/unionfs/"
RCLONEREMOTE="acdcrypt:"
MINFOLDERAGE="15" # MINIMUM FOLDER AGE IN MINUTES. SCRIPT WILL ONLY STARTED WHEN THERE IS A MATCH


readarray -t MOVIEFOLDERS < <(find "$MOVIES" -mindepth 1  -type d -mmin +$MINFOLDERAGE -not -iname '*.partial*')
readarray -t SERIESFOLDERS < <(find "$SERIES" -mindepth 2  -type d -mmin +$MINFOLDERAGE -not -iname '*.partial*')
readarray -t UPLOAD < <(find "$LOCALPATH" -mindepth 1  -type f -mmin +$MINFOLDERAGE -not -path '*/\.*' -not -iname '*.partial*')

if [[ -n $UPLOAD ]]; then
    start=$(date +'%s')
    echo "$(date "+%d.%m.%Y %T") START" | tee -a "$LOGFILE"
    # RCLONE MOVE FILES ( CHANGE TO YOUR PATHS )
    /usr/bin/rclone move $LOCALPATH $RCLONEREMOTE -v --no-traverse --transfers=20 --checkers=20 --delete-after --min-age ${MINFOLDERAGE}m --stats 30s --log-file=$LOGFILE

    #GENERATE AND UPLOAD PLEX.LIST
    for mfolder in "${MOVIEFOLDERS[@]}"
    do
        if [[ $mfolder == *"/movies/"* ]] ; then # Change /movies/ to match your path
            MREFRESHFOLDER="${mfolder/$LOCALPATH/$UNIONFSPATH}" # Change path from /storage/local/ to /mnt/unionfs
            echo "Adding to plex.list: $MREFRESHFOLDER" | tee -a "$LOGFILE"
            echo "$MREFRESHFOLDER" >>/home/plex/.cache/$TIMESTAMP-plex.list
        fi
    done
    for sfolder in "${SERIESFOLDERS[@]}"
    do
        if [[ $sfolder == *"/series/"* ]] ; then # Change /series/ to match your path
            SREFRESHFOLDER="${sfolder/$LOCALPATH/$UNIONFSPATH}" # Change path from /storage/local/ to /mnt/unionfs
            echo "Adding to plex.list: $SREFRESHFOLDER" | tee -a "$LOGFILE"
            echo "$SREFRESHFOLDER" >>/home/plex/.cache/$TIMESTAMP-plex.list
        fi
    done
    if  [[ -f  /home/plex/.cache/$TIMESTAMP-plex.list ]]; then
        echo "Uploading: $TIMESTAMP-plex.list" | tee -a "$LOGFILE"
        /usr/bin/rclone move /home/plex/.cache/$TIMESTAMP-plex.list $RCLONEREMOTE/tmp/ -v --no-traverse --log-file=$LOGFILE #Change acdcrypt: to match your remote
    fi
    echo "$(date "+%d.%m.%Y %T") ENDED in $(($(date +'%s') - $start)) seconds" | tee -a "$LOGFILE"
fi
exit
