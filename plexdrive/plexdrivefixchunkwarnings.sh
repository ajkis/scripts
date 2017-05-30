#!/bin/bash
## plexdrivefixchunkwarnings.sh (chmod a+x  plexdrivefixchunkwarnings.sh)
## This script will read from plexdrive mount log and make folders that plexdrive could not: WARNING: Could not write chunk temp file /xxxx
## To run script automatically every minute type: crontab -e and add line bellow (without ##):
## * * * * *   /path/plexdrivefixchunkwarnings.sh >/dev/null 2>&1
##
## Optionally you can run it more often eg every 15 secnds with cron by adding (do not add the above one then):
## * * * * * sleep 00; /path/plexdrivefixchunkwarnings.sh >/dev/null 2>&1
## * * * * * sleep 15; /path/plexdrivefixchunkwarnings.sh >/dev/null 2>&1
## * * * * * sleep 30; /path/plexdrivefixchunkwarnings.sh >/dev/null 2>&1
## * * * * * sleep 45; /path/plexdrivefixchunkwarnings.sh >/dev/null 2>&1
## More scripts at: https://github.com/ajkis/scripts
## If you find script useful feel free to buy me a beer at https://paypal.me/ajki
if pidof -o %PPID -x "$0"; then
   echo "$(date "+%d.%m.%Y %T") Already running, exit"
   exit 1
fi

PLEXDRIVEMOUNTLOG=/home/plex/logs/mountplexdrive.log #SET
WARNINGFOLDERPATH=$(grep -i "Could not write chunk temp file" $PLEXDRIVEMOUNTLOG | tail -1) #get last warrning in log
WARNINGFOLDERPATH=${WARNINGFOLDERPATH:89} #REMOVE 89 chars / [USR/BIN/PLEXDRIVE] [2017-05-27 18:56] WARNING: Could not write chunk temp file
if [[ ! -f $WARNINGFOLDERPATH ]];then #CHECK IF FILE EXIST
    WARNINGFOLDERPATH=$(dirname "${WARNINGFOLDERPATH}") #GET FOLDER NAME
    echo "Creating folder that plexdrive did not manage to do: $WARNINGFOLDERPATH"
    mkdir $WARNINGFOLDERPATH
fi
exit
