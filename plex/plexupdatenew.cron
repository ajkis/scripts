#!/bin/bash
## PLEX UPDATE LIBRARY WITH NEWLY UPLOADED MEDIA
## Make script executable by chmod a+x plexupdatenew.cron
## Add script to crontab ( crontab -e )
## */30 * * * *   /path to script/plexupdatenew.cron >/dev/null 2>&1
if pidof -o %PPID -x "$0"; then
   echo "$(date "+%d.%m.%Y %T") Exit, already running."
   exit 1
fi

#SETTINGS
MOVIELIBRARY="/mnt/cloud/movies/"
MOVIESECTION=2
TVLIBRARY="/mnt/cloud/series/"
TVSECTION=1
LOGFILE="/home/plex/logs/plexrefreshnew.cron.log"
LASTRUNFILE="/home/plex/.cache/lastrunfile"

export LD_LIBRARY_PATH=/usr/lib/plexmediaserver
export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/var/lib/plexmediaserver/Library/Application\ Support

if [[ ! -f "$LASTRUNFILE" ]]; then
    touch $LASTRUNFILE
fi
echo "$(date "+%d.%m.%Y %T") PLEX SCAN FOLDERS MODIFIED AFTER: $(date -r $LASTRUNFILE)"
#UPDATE MOVIES
start=$(date +'%s')
startmovies=$(date +'%s')
echo "Scaning movies at: $MOVIELIBRARY"
find "$MOVIELIBRARY" -mindepth 1 -type d -cnewer $LASTRUNFILE -exec \
/usr/lib/plexmediaserver/Plex\ Media\ Scanner --scan --refresh --section "$MOVIESECTION" --directory {} \; | tee -a "$LOGFILE"
echo "$(date "+%d.%m.%Y %T") Movies scanned in $(($(date +'%s') - $startmovies)) seconds" | tee -a "$LOGFILE"
echo " " | tee -a "$LOGFILE"
#UPDATE TV SHOWS
startseries=$(date +'%s')
echo "Scaning TV at: $TVLIBRARY"
find "$TVLIBRARY" -mindepth 2 -type d -cnewer $LASTRUNFILE -exec \
/usr/lib/plexmediaserver/Plex\ Media\ Scanner --scan --refresh --section "$TVSECTION" --directory {} \; | tee -a "$LOGFILE"
echo "$(date "+%d.%m.%Y %T") Series scanned in $(($(date +'%s') - $startseries)) seconds" | tee -a "$LOGFILE"
echo "$(date "+%d.%m.%Y %T") Scan completed in $(($(date +'%s') - $start)) seconds" | tee -a "$LOGFILE"
touch $LASTRUNFILE
exit
