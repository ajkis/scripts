#!/bin/bash
# Requirements: sudo apt install tree
if pidof -o %PPID -x "compare-acd-gdrive"; then
   echo "Already running, exit"
   exit 1
fi
scriptstart=$(date +'%s')
TSTAMP=`date +%d.%m.%Y/%H:%M`
LOGFILE="/home/plex/logs/compare-acd-gdrive.log"
ACDREMOTE="acd:"
GDRIVEREMOTE="gdrive:"
ACDMOUNT="/mnt/acdcrypt/"
GDRIVEMOUNT="/mnt/gdrivecrypt/"

echo "------------------------------------------- " | tee -a "$LOGFILE"
echo "$TSTAMP START" | tee -a "$LOGFILE"
echo "ACD FILES & SIZE (rclone size $ACDREMOTE)" | tee -a "$LOGFILE"
lastupload=`tail -n5 $LOGFILE | grep "Total size:" | cut -c 13- | cut -c -5`
acdstart=$(date +'%s')
rclone size $ACDREMOTE | tee -a "$LOGFILE"
echo "$TSTAMP ACD: It took $(($(date +'%s') - $acdstart)) seconds" | tee -a "$LOGFILE"
echo " " | tee -a "$LOGFILE"
echo "GDRIVE FILE & SIZE (rclone size $GDRIVEREMOTE)" | tee -a "$LOGFILE"
gdrivestart=$(date +'%s')
rclone size $GDRIVEREMOTE | tee -a "$LOGFILE"
echo "$TSTAMP GDRIVE: It took  $(($(date +'%s') - $gdrivestart)) seconds" | tee -a "$LOGFILE"
echo " " | tee -a "$LOGFILE"
echo "$TSTAMP ACD&GDRIVE SIZE: TOTAL TIME  $(($(date +'%s') - $scriptstart)) seconds" | tee -a "$LOGFILE"
echo " " | tee -a "$LOGFILE"
acdstart=$(date +'%s')
echo "ACD FILE/FOLDER COUNT (tree $ACDMOUNT)" | tee -a "$LOGFILE"
tree $ACDMOUNT | tail -1 | tee -a "$LOGFILE"
echo "$TSTAMP ACD COUNT: It took $(($(date +'%s') - $acdstart)) seconds" | tee -a "$LOGFILE"
echo " " | tee -a "$LOGFILE"
gdrivestart=$(date +'%s')
echo "GDRIVE FILE/FOLDER COUNT (tree $GDRIVEMOUNT) " | tee -a "$LOGFILE"
tree $GDRIVEMOUNT | tail -1 | tee -a "$LOGFILE"
echo "$TSTAMP GDRIVE COUNT: It took  $(($(date +'%s') - $gdrivestart)) seconds" | tee -a "$LOGFILE"
echo " " | tee -a "$LOGFILE"
echo "$TSTAMP ACD&GDRIVE SIZE & COUNT: TOTAL TIME  $(($(date +'%s') - $scriptstart)) seconds" | tee -a "$LOGFILE"
echo " " | tee -a "$LOGFILE"
exit
