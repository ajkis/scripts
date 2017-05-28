#!/bin/bash
# RCLONE UPLOAD CRON TAB SCRIPT 
# Type crontab -e and add line below (without #)
# * * * * * /home/plex/scripts/rclone-upload.cron >/dev/null 2>&1
# modify line 20 config file location

if pidof -o %PPID -x "rclone-upload.cron"; then
   exit 1
fi

LOGFILE="/home/plex/logs/rclone-upload.cron"
FROM="/storage/local/"
TO="acdcrypt:/"

# CHECK FOR FILES IN FROM FOLDER THAT ARE OLDER THAN 15 MINUTES
if find $FROM* -type f -mmin +15 | read
  then
  echo "$(date "+%d.%m.%Y %T") RCLONE UPLOAD STARTED" | tee -a $LOGFILE
  # MOVE FILES OLDER THAN 15 MINUTES 
  rclone move --config=/path/rclone.conf $FROM $TO -c --no-traverse --transfers=300 --checkers=300 --delete-after --min-age 15m --log-file=$LOGFILE
  echo "$(date "+%d.%m.%Y %T") RCLONE UPLOAD ENDED" | tee -a $LOGFILE
fi
exit
