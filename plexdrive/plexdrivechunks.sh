#!/bin/bash
## plexdrivechunks.sh (chmod a+x plexdrivechunks.sh)
## The function of this script is to manually delete plexdrive chunk files when you are about to run out of disk space.
## NOTE: plexdrive support max disk usage for chunks, eg --clear-chunk-max-size=100GB (but if disk get full with other none plexdrive related data this wont help )
## Add to plexdrive mount: --clear-chunk-age=730h
##          Note: This would keep all downloads for a month before deleting them ( do not use --clear-chunk-max-size so maximum space its always available)
##
## To run script automatically every minute type: crontab -e and andd line bellow (without ##):
## * * * * *   /path/plexdrivechunks.sh >/dev/null 2>&1
##
## More scripts at: https://github.com/ajkis/scripts
## If you find script useful feel free to buy me a beer at https://paypal.me/ajki

## EXIT IF SCRIPT IS ALREADY RUNNING
if pidof -o %PPID -x "$0"; then
   echo "$(date "+%d.%m.%Y %T") Already running, exit"
   exit 1
fi

LOG=/home/plex/logs/plexdrivechunks.log
PLEXDRIVETEMP=/home/plex/.plexdrive/temp
CURDISKSPACE=$(df -k $PLEXDRIVETEMP | tail -1 | awk '{print $4}')
MINDISKSPACE=1000000 # SET MINIMUM DISK SPACE WHEN ITS BELLOW THE SCRIPT WILL TRIGGER (1GB = 1000000kB)

while [[ $CURDISKSPACE<$MINDISKSPACE ]]
do
    CURDISKSPACE=$(df -k $PLEXDRIVETEMP | tail -1 | awk '{print $4}')
    if [[ -z "$nochunk" ]]; then
        find $PLEXDRIVETEMP -mindepth 1 -mmin +1 –atime +10 | head -n 10 |
        while read chunk; do
                if [[ -z "$chunk" ]]; then
                    echo "WARNING: Current disk size is ${CURDISKSPACE}kB and bellow ${MINDISKPACE}kB, no chunks available for deletition. EXIT" | tee -a $LOG
                    nochunk=1
                    break
                fi
                echo "Delete: $chunk" | tee -a $LOG
                rm $chunk
        done
    else
        echo "WARNING: Current disk size is ${CURDISKSPACE}kB and bellow ${MINDISKPACE}kB, no chunks available for deletition. EXIT" | tee -a $LOG
        break
    fi
done
exit
