#!/bin/bash
# RCLONE UPLOAD CHECK SCRIPT
# chmod a+x /home/plex/scripts/rcuploadcheck.sh
# Set rclone remote and path to LogFile
# You can add script in crontab to check every 10 minutes and log gdrive locks/unlocks
# Type crontab -e and add line below (without #) and with correct path to the script
# */10 * * * * /home/plex/scripts/rcuploadcheck.sh >/dev/null 2>&1

if pidof -o %PPID -x "$0"; then
   echo "$(date "+%d.%m.%Y %T") Already running, exiting."
   exit 1
fi

LogFile="/home/plex/logs/rcuploadcheck.log"
UploadFile="/dev/shm/upload-file"
Remote="gdajki:"

if [[ ! -f $LogFile ]]; then
    touch $LogFile
fi
LastState=$(tail -1 $LogFile)

start=$(date +'%s')
echo "INFO: Checking upload for $Remote"
dd if=/dev/zero of=$UploadFile count=1024 bs=100 >/dev/null 2>&1
/usr/bin/rclone move "$UploadFile" $Remote --delete-after --log-level ERROR
if [ $? -eq 0 ]; then
    echo "INFO: Upload successful"
    if [[ $LastState == *"upload locked"* ]]; then
        echo "$(date "+%d.%m.%Y %T") $Remote upload unlocked" | tee -a $LogFile
    fi
else
    echo "INFO: Upload error, drive locked"
    if [[ $LastState == *"upload unlocked"* ]]; then
        echo "$(date "+%d.%m.%Y %T") $Remote upload locked" | tee -a $LogFile
    fi
fi
echo "INFO: Finished in $(($(date +'%s') - $start)) seconds"
exit
