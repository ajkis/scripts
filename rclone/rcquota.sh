#!/bin/bash
## Show gdrive used quota
LogFile=/dev/shm/rcquota.log

if [ -z $1 ]; then
    echo "Use rcquota remote:"
fi
    echo "Checking gdrive quota used for $Remote"
    rclone lsd $1 -vv --dump-bodies --log-file=$LogFile >/dev/null 2>&1
    QuotaUsed=$(grep -e 'quotaBytesUsed"' $LogFile | awk -F'[^0-9]*' '{print $2}')
    QuotaUsed=$(($QuotaUsed / (1024*1024*1024)))
    echo "$QuotaUsed GB"
    rm $LogFile
exit
