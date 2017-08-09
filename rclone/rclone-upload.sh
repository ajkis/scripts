#!/bin/bash
# RCLONE UPLOAD CRON TAB SCRIPT 
# Type crontab -e and add line below (without #)
# * * * * * /home/plex/scripts/rclone-upload.cron >/dev/null 2>&1
# modify line 20 config file location

#!/bin/bash

PIDFILE=/tmp/rclone-upload.pid
if [ -f $PIDFILE ]
then
  PID=$(cat $PIDFILE)
  ps -p $PID > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    echo "Job is already running"
    exit 1
  else
    ## Process not found assume not running
    echo $$ > $PIDFILE
    if [ $? -ne 0 ]
    then
      echo "Could not create PID file"
      exit 1
    fi
  fi
else
  echo $$ > $PIDFILE
  if [ $? -ne 0 ]
  then
    echo "Could not create PID file"
    exit 1
  fi
fi

LOGFILE="/home/plex/logs/rclone-upload.cron"
FROM="/storage/local/"
TO="acdcrypt:/"

# CHECK FOR FILES IN FROM FOLDER THAT ARE OLDER THAN 15 MINUTES
if find $FROM* -type f -mmin +15 | read
  then
  echo "$(date "+%d.%m.%Y %T") RCLONE UPLOAD STARTED" | tee -a $LOGFILE
  # MOVE FILES OLDER THAN 15 MINUTES 
  rclone move --config=/path/rclone.conf $FROM $TO -c --no-traverse --transfers=30 --checkers=30 --delete-after --min-age 15m --log-file=$LOGFILE
  echo "$(date "+%d.%m.%Y %T") RCLONE UPLOAD ENDED" | tee -a $LOGFILE
fi
rm $PIDFILE
exit
