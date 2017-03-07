#!/bin/bash
## Fix unmatched movies that radar does not recognize and are placed it correct folders.
## Change DB value to match your radar db path

DB="/home/plex/.config/Radarr/nzbdrone.db"

while ps ax | grep -v grep | grep Radarr.exe > /dev/null
do
    echo "EXIT, Radarr.exe must be stopped"
    exit
done

query="SELECT Title from Movies WHERE MovieFileId = '0' AND id IN (SELECT MovieId FROM MovieFiles)"
result=$(sqlite3 -header -line "$DB" "$query")
echo "${result:12} Unmatched Movies"

echo "Applying SQL Update fix"
sqlite3 -header -line "$DB" "update Movies set MovieFileId = IfNull((select MovieFiles.Id from MovieFiles where MovieFiles.MovieId = Movies.id), 0) where MovieFileId = 0"
echo "Done, you may start Radarr again"
exit
