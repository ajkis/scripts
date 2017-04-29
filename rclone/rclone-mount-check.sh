#!/bin/bash
# 1. Change paths
# 2. for mount and log file & create mountchek file.
# 3. Add to crontab -e (paste the line bellow, without # in front)
# * * * * *  /home/plex/scripts/rclone-mount-check.sh >/dev/null 2>&1
# Make script executable with: chmod a+x /home/plex/scripts/rclone-mount-check.sh

LOGFILE="/home/plex/logs/rclone-mount-check.log"
RCLONEREMOTE="acdcrypt:"
MPOINT="/home/plex/acdcrypt"
CHECKFILEPATH="mountcheck"

if pidof -o %PPID -x "$0"; then
    echo "$(date "+%d.%m.%Y %T") EXIT: Already running." | tee -a "$LOGFILE"
    exit 1
fi

if [[ -f "$MPOINT/$CHECKFILE" ]]; then
    echo "$(date "+%d.%m.%Y %T") INFO: Check successful, $MPOINT mounted." | tee -a "$LOGFILE"
    exit
else
    echo "$(date "+%d.%m.%Y %T") ERROR: $MPOINT not mounted, remount in progress." | tee -a "$LOGFILE"
    # Unmount before remounting
    while mount | grep "on ${MPOINT} type" > /dev/null
    do
        echo "($wi) Unmounting $mount"
        fusermount -uz $MPOINT | tee -a "$LOGFILE"
        cu=$(($cu + 1))
        if [ "$cu" -ge 5 ];then
            echo "$(date "+%d.%m.%Y %T") ERROR: Folder could not be unmounted exit" | tee -a "$LOGFILE"
            exit 1
            break
        fi
        sleep 1
    done
    rclone mount \
        --read-only \
        --allow-non-empty \
        --allow-other \
        --max-read-ahead 14G \
        --acd-templink-threshold 0 \
        --checkers 16 \
        --quiet \
        --stats 0 \
        $RCLONEREMOTE $MPOINT &

    while ! mount | grep "on ${MPOINT} type" > /dev/null
    do
        echo "($wi) Waiting for mount $mount"
        c=$(($c + 1))
        if [ "$wi" -ge 4 ] ; then break ; fi
        sleep 1
    done
    if [[ -f "$MPOINT/$CHECKFILE" ]]; then
        echo "$(date "+%d.%m.%Y %T") INFO: Remount successful." | tee -a "$LOGFILE"
    else
      echo "$(date "+%d.%m.%Y %T") CRITICAL: Remount failed." | tee -a "$LOGFILE"
    fi
fi
exit
