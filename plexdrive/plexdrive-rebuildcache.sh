#!/bin/bash
## plexdrive-rebuildcache.sh (chmod a+x plexdrive-rebuildcache.sh)
## The function of this script is rebuild cache in memory and then move it to default location.
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

# Specify list of commands to stop apps & unmount drives before proceeding with cache rebuild
## example: sudo service plexmediaserver stop
STOPCMDS=(
     'fusermount -uz /mnt/plexdrive'
)
# Specify list of commands to mount and start apps once cache is rebuilt
## If you mount plexdrive with systemd replace it with: sudo systemctl plexdrive.service star
## example: sudo service plexmediaserver start
STARTCMDS=(
     'echo "/home/plex/scripts/mountplexdrive"'
)


if [[ ! -f $PLEXDRIVECONF/config.json ]]; then
    echo "EXIT: plexdrive config missing at path $PLEXDRIVECONF"
    echo "NOTE: plexdrive must be configured, type: plexdrive /mnt/plexdrive and follow setup"
    exit
fi
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
        echo "$(date "+%d.%m.%Y %T") plexdrive rebuild cache started" | tee -a $LOGFILE
        echo "Unmounting drive and stopping apps" | tee -a $LOGFILE
        for stopcmd in "${STOPCMDS[@]}"
        do
            $stopcmd | tee -a $LOGFILE
        done
        echo "Copying plex drive config to /dev/shm" | tee -a $LOGFILE
        cp $PLEXDRIVECONF/config.json /dev/shm/ | tee -a $LOGFILE
        cp $PLEXDRIVECONF/token.json /dev/shm/ | tee -a $LOGFILE
        if [[ ! -f /dev/shm/cache ]]; then
            echo "Deleting existing cache file" | tee -a $LOGFILE
            rm /dev/shm/cache* | tee -a $LOGFILE
        fi
        echo "Mounting plexdrive and waiting for cache to be rebuilt" | tee -a $LOGFILE
        cachebuildstart=$(date +'%s')
        $PLEXDRIVEEXEC $PLEXDRIVEMNT --config=/dev/shm -v 2 &>>/dev/shm/plexdrive-$TIMESTAMP.log &
        while > /dev/null
        do
          finished=$(grep "First cache build process finished!" /dev/shm/plexdrive-$TIMESTAMP.log)
          if [[ ! -z $finished ]]; then
            echo "First cache build process finished in $(($(date +'%s') - $cachebuildstart)) seconds" | tee -a $LOGFILE
            echo "$(grep "Processed" /dev/shm/plexdrive-$TIMESTAMP.log | tail -1)" | tee -a $LOGFILE
            break
          fi
            echo "$(grep -i "${PLEXDRIVEEXEC:1}" /dev/shm/plexdrive-$TIMESTAMP.log | tail -1)"
            sleep 1
        done
        echo "Unmounting plexdrive" | tee -a $LOGFILE
        fusermount -uz $PLEXDRIVEMNT | tee -a $LOGFILE
        echo "/dev/shm cleanup" | tee -a $LOGFILE
        rm /dev/shm/config.json | tee -a $LOGFILE
        rm /dev/shm/token.json  | tee -a $LOGFILE
        rm /dev/shm/plexdrive-$TIMESTAMP.log | tee -a $LOGFILE
        echo "Moving plexdrive cache back to $PLEXDRIVECONF" | tee -a $LOGFILE
        mv /dev/shm/cache* $PLEXDRIVECONF | tee -a $LOGFILE

        echo "Mounting plexdrive and starting all services" | tee -a $LOGFILE
        for startmd in "${STARTCMDS[@]}"
        do
            $startcmd | tee -a $LOGFILE
        done
        ;;
    *)
        echo "Aborted"
        exit
        ;;
esac
        echo "$(date "+%d.%m.%Y %T") plexdrive rebuild cache finished" | tee -a $LOGFILE
exit
