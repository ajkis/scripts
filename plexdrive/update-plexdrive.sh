#!/bin/bash
## update-plexdrive.sh (chmod a+x /path/update-plexdrive.sh)
## Dependencies curl ( sudo apt install curl )
## Script function:
## 1. Stop Plex Media Server and unmount plexdrive
## 2. Download latest plexdrive and replace existing version
## 3. Mount plexdrive (will exit if mount was not successful )
## 4. Start Plex Media Server
##
## More scripts at: https://github.com/ajkis/scripts
## If you find script useful feel free to buy me a beer at https://paypal.me/ajki

PLEXDRIVEMOUNTCMD="/home/plex/scripts/mountplexdrive" # Set path to your plexdrive mount script. If you use systemd replace it with "sudo systemctl plexdrive.service start"
PLEXDRIVEEXEC=/usr/bin/plexdrive # Set path to plexdrive executable
PLEXDRIVEMNT=/mnt/plexdrive # Set path to plexdrive mount

echo "plexdrive updater started, current version"
plexdrive --version

wget $(curl -s https://api.github.com/repos/dweidenfeld/plexdrive/releases/latest | grep 'browser_' | cut -d\" -f4 | grep plexdrive-linux-amd64) -O /dev/shm/plexdrive-linux-amd64
if [ "$?" != "0" ]; then
   echo "EXIT: Unable to download latest plexdrive version"
   exit
fi

# STOP PLEX MEDIA SERVER
while ps ax | grep -v grep | grep /usr/lib/plexmediaserver/Plex\ Media\ Server > /dev/null
do
    echo "stopping plex media server"
    sudo service plexmediaserver stop
    sleep 3
done

# UNMOUNT PLEX DRIVE
while mount | grep "on $PLEXDRIVEMNT type" > /dev/null
do
      echo "($wi) Unmounting $mount"
      fusermount -uz $PLEXDRIVEMNT
      sleep 1
done

echo "killing all plexdrive processes"
while ps ax | grep -v grep | grep /usr/lib/plexdrive > /dev/null
do
     killall -9 plexdrive
     sleep 1
done

# REPLACE EXISTING WITH NEW VERSION
sudo chmod a+x /dev/shm/plexdrive-linux-amd64
sudo mv /dev/shm/plexdrive-linux-amd64 $PLEXDRIVEEXEC

# MOUNT PLEXDRIVE
$PLEXDRIVEMOUNT

# WAIT FOR PLEXDRIVE TO BE MOUNTED
while ! mount | grep "on $PLEXDRIVEMNT type" > /dev/null
do
      echo "($wi) Waiting for $PLEXDRIVEMNT mount"
      wi=$(($wi + 1))
      if [ "$wi" -ge 12 ];then
        echo "EXIT: Unable to mount $PLEXDRIVEMNT, check plexdrive logs"
        exit
      fi
      sleep 1
done

# START PLEX MEDIA SERVER
sudo service plexmediaserver start
sleep 2

echo "plexdrive new version installed"
plexdrive --version
exit
