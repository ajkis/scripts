#!/bin/bash
## The function of this script is to check rclone mount against plexdrive mount and list all missing files
##
## Requirements:
## plexdrive mount and rclone mount
##
## Setup
## 1. chmod a+x plexdrive-scan-missing.sh
## 2. Set correct paths in variables and array
##
## More scripts at: https://github.com/ajkis/scripts
## If you find script useful feel free to buy me a beer at https://paypal.me/ajki

## EXIT IF SCRIPT IS ALREADY RUNNING
if pidof -o %PPID -x "$0"; then
   echo "$(date "+%d.%m.%Y %T") Already running, exit"
   exit 1
fi

TS=`date +%Y-%m-%d_%H-%M-%S`
LOGFILE="/home/plex/logs/plexdrivemissing-$TS.log"
RCLONEMOUNT=/mnt/gdrivecrypt # Set path to rclone mount
PLEXDRIVEMOUNT=/mnt/cloud # set path to plexdrive mount

# set path to rclone mount movies, series etc...
PATHS=(
        '/mnt/gdrivecrypt/movies/'
        '/mnt/gdrivecrypt/series/'
 )
elapsed=$(date +'%s')
countermissing=0
clear
echo "$(date "+%d.%m.%Y %T") Scan plexdrive for missing files" | tee -a $LOGFILE
for path in "${PATHS[@]}"
do
    find $path -type f |
    while read filepath
    do
        counterall=$(($counterall + 1))
        filepath=${filepath/$RCLONEMOUNT/$PLEXDRIVEMOUNT}
        tput cup 1 0
        tput el
        echo "Progress: $counterall files in $(($(date +'%s') - $elapsed)) seconds | Missing: $countermissing"
        tput cup 2 0
        tput el
        echo -ne "Checking: $filepath"
        if [[ ! -f "$filepath" ]]; then
            tput cup $(($countermissing + 4)) 0
            countermissing=$(($countermissing + 1))
            echo "Missing on plexdrive: $filepath" | tee -a $LOGFILE
        fi
    done
done
    echo "Scan finished in $(($(date +'%s') - $elapsed)) seconds. Missing $countermissing files" | tee -a $LOGFILE
exit
