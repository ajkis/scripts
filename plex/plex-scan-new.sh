#!/bin/bash
## PLEX SCAN ONLY NEW/MODIFED FOLDERS SINCE LAST RUN
## OS: Linux Ubuntu 16.04
## Make script executable by chmod a+x plex-scan-new.sh
## Add script to crontab -e ( paste the line bellow without ## )
## */30 * * * *   /path to script/plex-scan-new.sh >/dev/null 2>&1
## Make sure you disable all Plex automatic & scheduled library scans.
if pidof -o %PPID -x "$0"; then
   echo "$(date "+%d.%m.%Y %T") Exit, already running."
   exit 1
fi

#SETTINGS
MOVIELIBRARY="/mnt/cloud/movies/"
MOVIESECTION=2
TVLIBRARY="/mnt/cloud/series/"
TVSECTION=1
LOGFILE="/home/plex/logs/plex-scan-new.log"
FOLDERLISTFILE="/home/plex/.cache/folderlistfile"
LASTRUNFILE="/home/plex/.cache/lastrunfile"


export LD_LIBRARY_PATH=/usr/lib/plexmediaserver
export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/var/lib/plexmediaserver/Library/Application\ Support

if [[ ! -f "$LASTRUNFILE" ]]; then
    touch $LASTRUNFILE
fi
echo "$(date "+%d.%m.%Y %T") PLEX SCAN FOR NEW/MODIFIED FILES AFTER: $(date -r $LASTRUNFILE)"

if [[ -f "$FOLDERLISTFILE" ]]; then
    echo "Removing previous folder list"
    rm $FOLDERLISTFILE
fi

start=$(date +'%s')
startmovies=$(date +'%s')
echo "Scaning for new files: $MOVIELIBRARY"
find "$MOVIELIBRARY" -mindepth 1 -type f -cnewer $LASTRUNFILE |
while read mfile; do
        echo "$(date "+%d.%m.%Y %T") New file detected: $mfile" | tee -a "$LOGFILE"
        MFOLDER=$(dirname "${mfile}")
        echo "$MFOLDER" | tee -a "$FOLDERLISTFILE"
done
echo "$(date "+%d.%m.%Y %T") Movie files scanned in $(($(date +'%s') - $startmovies)) seconds" | tee -a "$LOGFILE"

startseries=$(date +'%s')
echo "Scaning for new files: $TVLIBRARY"
find "$TVLIBRARY" -mindepth 2 -type f -cnewer $LASTRUNFILE |
while read tvfile; do
        echo "$(date "+%d.%m.%Y %T") New file detected: $tvfile" | tee -a "$LOGFILE"
        TVFOLDER=$(dirname "${tvfile}")
        echo "$TVFOLDER" | tee -a "$FOLDERLISTFILE"
done
echo "$(date "+%d.%m.%Y %T") TV folders scanned in $(($(date +'%s') - $startseries)) seconds" | tee -a "$LOGFILE"

echo "$(date "+%d.%m.%Y %T") Move & TV folders scanned in $(($(date +'%s') - $start)) seconds" | tee -a "$LOGFILE"
echo "$(date "+%d.%m.%Y %T") Setting lastrun for next folder scans" | tee -a "$LOGFILE"
touch $LASTRUNFILE
echo "$(date "+%d.%m.%Y %T") Remove duplicates" | tee -a "$LOGFILE"
sort $FOLDERLISTFILE | uniq | tee $FOLDERLISTFILE

startplexscan=$(date +'%s')
echo "$(date "+%d.%m.%Y %T") Plex scan started" | tee -a "$LOGFILE"
readarray -t FOLDERS < "$FOLDERLISTFILE"
for FOLDER in "${FOLDERS[@]}"
do
    if [[  $FOLDER == "$MOVIELIBRARY"* ]]; then
        echo "$(date "+%d.%m.%Y %T") Plex scan movie folder:: $FOLDER" | tee -a "$LOGFILE"
        $LD_LIBRARY_PATH/Plex\ Media\ Scanner --scan --refresh --section "$MOVIESECTION" --directory "$FOLDER" | tee -a "$LOGFILE"
    elif [[  $FOLDER == "$TVLIBRARY"* ]]; then
        echo "$(date "+%d.%m.%Y %T") Plex scan TV folder: $FOLDER" | tee -a "$LOGFILE"
        $LD_LIBRARY_PATH/Plex\ Media\ Scanner --scan --refresh --section "$TVSECTION" --directory "$FOLDER" | tee -a "$LOGFILE"
    fi
done
echo "$(date "+%d.%m.%Y %T") Plex scan finished in $(($(date +'%s') - $startplexscan)) seconds" | tee -a "$LOGFILE"

echo "$(date "+%d.%m.%Y %T") Scan completed in $(($(date +'%s') - $start)) seconds" | tee -a "$LOGFILE"
exit
