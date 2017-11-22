#!/bin/bash
## plexdrive mount (chmod a+x mountplexdrive.sh)
## To mount the drive at reboot & to remount in case of failure type crontab -e and add 2 lines bellow (without ##):
## @reboot /path/mountplexdrive.sh
## 0 5 * * *   /path/mountplexdrive.sh >/dev/null 2>&1
##
## To unmount plexdrive use
## /path/mountplexdrive unmount
## More scripts at: https://github.com/ajkis/scripts
## If you find script useful feel free to buy me a beer at https://paypal.me/ajki

## EXIT IF ALREADY RUNNING
if pidof -o %PPID -x "$0"; then
   echo "EXIT: Already running"
   exit 1
fi

## GLOBAL VARS
LOGFILE="/home/plex/logs/mountplexdrive.log"
MPOINT="/mnt/plexdrive/"

## UNMOUNT IF SCRIPT WAS RUN WITH unmount PARAMETER
if [[ $1 = "unmount" ]]; then
    echo "Unmounting $MPOINT"
    fusermount -uz $MPOINT
    exit
fi

## CHECK IF MOUNT ALREADY EXIST AND MOUNT IF NOT
if mountpoint -q $MPOINT ; then
    echo "$MPOINT already mounted"
else
    echo "Mounting $MPOINT"
    ## Adjust chunk-check/load threads to match maximum concurrent streams
    ## Do not use losd-ahead bigger then 10.
    ## Keep in mind that 1080p stream will need 20Mbit while some scenes can spike to 50/60Mbit.
    /usr/bin/plexdrive mount $MPOINT \
                   -o allow_other \
                   --chunk-check-threads=20 \
                   --chunk-load-ahead=4 \
                   --chunk-load-threads=20 \
                   --chunk-size=5M \
                   --max-chunks=2000 \
                   --refresh-interval=1m \
                   -v 3 &>>"$LOGFILE" &
fi
exit
