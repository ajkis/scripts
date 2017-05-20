#!/bin/bash
## plexdrive mount (chmod a+x mountplexdrive.sh)
## To mount the drive at reboot type crontab -e and add line bellow (without ##):
## @reboot /path/mountplexdrive.sh
##
## To unmount the drive use
## /path/mountplexdrive unmount

LOGFILE="/home/plex/logs/mountplexdrive.log"
MPOINT="/mnt/plexdrive/"

if [[ $1 = "unmount" ]]; then
    echo "Unmounting $MPOINT"
    fusermount -uz $MPOINT
    exit
fi

if mountpoint -q $MPOINT ; then
    echo "$MPOINT already mounted"
else
    echo "Mounting $MPOINT"
    /usr/bin/plexdrive $MPOINT \
                       -o allow_other \
                       --config=$PLEXDRIVECONF
                       -v 2 &>>$LOGFILE &
fi
exit

## Aditional options (copy paste them above line: -v 2 &>>$LOGFILE & :
##  --chunk-size 5M \
##        The size of each chunk that is downloaded (units: B, K, M, G) (default "5M")
##  --clear-chunk-age 30m0s \
##        The maximum age of a cached chunk file (default 30m0s)
##  --clear-chunk-interval 1m0s \
##        The time to wait till clearing the chunk directory (default 1m0s)
##  --clear-chunk-max-size 100G \
##        The maximum size of the temporary chunk directory (units: B, K, M, G)
##  -c, --config=/home/plex/.plexdrive \
##        The path to the configuration directory (default "/home/plex/.plexdrive")
##  -o allow_other \
##        Fuse mount options (e.g. -fuse-options allow_other,...)
##  --gid 1000 \
##        Set the mounts GID (-1 = default permissions) (default -1)
##  --refresh-interval 5m0s \
##        The time to wait till checking for changes (default 5m0s)
##  --speed-limit 1G \
##        This value limits the download speed, e.g. 5M = 5MB/s per chunk (units: B, K, M, G)
##  -t, --temp=/tmp \
##        Path to a temporary directory to store temporary data (default "/tmp")
##  --uid 1000 \
##        Set the mounts UID (-1 = default permissions) (default -1)
##  --umask value
##        Override the default file permissions
##  -v, --verbosity 2 \
##        Set the log level (0 = error, 1 = warn, 2 = info, 3 = debug, 4 = trace)
