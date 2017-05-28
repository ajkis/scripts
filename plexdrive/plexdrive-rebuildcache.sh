#!/bin/bash
## plexdrive-rebuildcache.sh (chmod a+x plexdrive-rebuildcache.sh)
## The function of this script is rebuild cache with paralel process in memory and then move it to default location.
## NOTE: This will speed up process significantly as building full cache on hard disk may take hours.
##
## More scripts at: https://github.com/ajkis/scripts
## If you find script useful feel free to buy me a beer at https://paypal.me/ajki

TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
LOGFILE="/home/plex/logs/plexdrive-rebuildcache.log"
PLEXDRIVEEXEC=/usr/bin/plexdrive # Set path to plexdrive executable
PLEXDRIVEMNT=/mnt/plexdrive # Set path to plexdrive mount
PLEXDRIVECONF=~/.plexdrive # Set location of your plexdrive config or leave default
PLEXDRIVEMOUNTCMD="/home/plex/scripts/mountplexdrive" # Set path to your plexdrive mount script. If you use systemd replace it with "sudo systemctl plexdrive.service start"
PLEXDRIVETMPMNT=/mnt/tmp #Make sure you have read/write permissions in /mnt

echo "$(date "+%d.%m.%Y %T") plexdrive rebuild cache started" | tee -a $LOGFILE


if [[ ! -d $PLEXDRIVETMPMNT ]]; then
    mkdir $PLEXDRIVETMPMNT
fi

## REMOVE OLD FILES IN CASE SCRIPT WAS ABORTED
rm -f /dev/shm/cache* >/dev/null
rm -f /dev/shm/config.json >/dev/null
rm -f /dev/shm/token.json  >/dev/null
rm -f /dev/shm/plexdrivetmp.log >/dev/null
rm -rf /dev/shm/chunks >/dev/null

echo "Copying plex drive config to $PLEXDRIVETMPMNT" | tee -a $LOGFILE
cp $PLEXDRIVECONF/config.json /dev/shm | tee -a $LOGFILE
cp $PLEXDRIVECONF/token.json /dev/shm | tee -a $LOGFILE

echo "Mounting TMP plexdrive and waiting for cache to be rebuilt" | tee -a $LOGFILE
cachebuildstart=$(date +'%s')
$PLEXDRIVEEXEC $PLEXDRIVETMPMNT --config=/dev/shm --temp=/dev/shm -v 2 &>>/dev/shm/plexdrivetmp.log &
while > /dev/null
do
  finished=$(grep "First cache build process finished!" /dev/shm/plexdrivetmp.log)
  if [[ ! -z $finished ]]; then
    echo "First cache build process finished in $(($(date +'%s') - $cachebuildstart)) seconds" | tee -a $LOGFILE
    echo "$(grep "Processed" /dev/shm/plexdrivetmp.log | tail -1)" | tee -a $LOGFILE
    fusermount -uz $PLEXDRIVETMPMNT
    break
  fi
    echo "$(grep -i "${PLEXDRIVEEXEC:1}" /dev/shm/plexdrivetmp.log | tail -1)"
    sleep 1
done

echo "///////////////////////////////////////////////////////////////////////////////////////////////"
echo "Your current cache will be deleted, rebuilt in memory (/dev/shm) and moved to default location"
echo "plexdrive conf path = $PLEXDRIVECONF"
echo "plexdrive exec path = $PLEXDRIVEEXEC"
echo "plexdrive mount command: $PLEXDRIVEMOUNTCMD"
echo "NOTE: You can run rebuilt automatically: /path/plexdrive-rebuildcache.sh y"
echo "///////////////////////////////////////////////////////////////////////////////////////////////"
response=$1
if [[ $response != y ]]; then
    read -r -p "Are you sure? [y/N] " response
fi
case "$response" in
    [yY][eE][sS]|[yY])
    ### LIST OF COMMAND TO RUN BEFORE REMOUNTING PLEXDRIVE
    ## eg: sudo service plexmediaserver stop
    echo "Stopping all services" | tee -a $LOGFILE
    fusermount -uz /mnt/plexdrivecrypt
    fusermount -uz $PLEXDRIVEMNT
    sudo systemctl stop radarr.service
    sudo systemctl stop sonarr.service
    rm -rf /home/plex/.plexdrive/temp/chunks
    rm -rf /home/plex/.plexdrive/cache
    mv /home/plex/scripts/cron/local2cloud.cron /home/plex/scripts/cron/local2cloud.cron2
    mv /home/plex/scripts/cron/cloudmount.cron /home/plex/scripts/cron/cloudmount.cron2

    ### MOVE NEW CACHE FILE
    echo "Moving new plexdrive cache to $PLEXDRIVECONF" | tee -a $LOGFILE
    mv /dev/shm/cache* $PLEXDRIVECONF | tee -a $LOGFILE

    ### CLEANUP
    echo "/dev/shm cleanup" | tee -a $LOGFILE
    rm /dev/shm/config.json | tee -a $LOGFILE
    rm /dev/shm/token.json  | tee -a $LOGFILE
    rm /dev/shm/plexdrivetmp.log | tee -a $LOGFILE
    rm -rf /dev/shm/chunks | tee -a $LOGFILE

    ###  LIST OF COMMANDS TO PREFORM ONCE DRIVE IS REMOUNTED
    ## Start srvices stopped before remount
    echo "Mounting plexdrive and starting all services" | tee -a $LOGFILE
    /home/plex/scripts/mountplexdrive
    echo "$(date "+%d.%m.%Y %T") plexdrive rebuild cache finished" | tee -a $LOGFILE
        ;;
    *)
        echo "Aborted"
        exit
        ;;
esac

exit
