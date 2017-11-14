#!/bin/bash
# RCLONE UPLOAD CRON TAB SCRIPT 
# Type crontab -e and add line below (without #) and with correct path to the script
# * * * * * /home/plex/scripts/rclone-upload.cron >/dev/null 2>&1
# if you use custom config path add in line 20 after --log-file=$LOGFILE --config=/path/rclone.conf (config file location)

if pidof -o %PPID -x "$0"; then
   exit 1
fi

LOGFILE="/home/plex/logs/rclone-upload.cron"
FROM="/storage/local/"
TO="gdrivecrypt:/"

# CHECK FOR FILES IN FROM FOLDER THAT ARE OLDER THAN 15 MINUTES
if find $FROM* -type f -mmin +15 | read
  then
  echo "$(date "+%d.%m.%Y %T") RCLONE UPLOAD STARTED" | tee -a $LOGFILE
  # MOVE FILES OLDER THAN 15 MINUTES 
  rclone move "$FROM" "$TO" --transfers=20 --checkers=20 --delete-after --min-age 15m --log-file=$LOGFILE
  echo "$(date "+%d.%m.%Y %T") RCLONE UPLOAD ENDED" | tee -a $LOGFILE
fi
exit
