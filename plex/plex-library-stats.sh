#!/bin/bash
# Generate Plex Library stats
# OS: Ubuntu 16.04 ( change dbpath if using diffrent OS )
# Output:
# Media items in Libraries
# Library = Movies
#  Items = 2815

# Library = TV Shows
#  Items = 13105

# Time to watch
# Library = Movies
# Minutes = 312664
#   Hours = 5211
#    Days = 217

# Library = TV Shows
# Minutes = 525251
#   Hours = 8754
#    Days = 364

# 15921 files in library
# 0 metadata_items marked as deleted
# 0 media_parts marked as deleted
# 0 media_items marked as deleted
# 0 directories marked as deleted
# 0 files missing analyzation info
# 15491 files missing deep analyzation info.

logfile="/home/plex/logs/plexstats.log"
db="/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db"
echo "$(date "+%d.%m.%Y %T") PLEX LIBRARY STATS" | tee -a $logfile
echo "Media items in Libraries" | tee -a $logfile
query="SELECT Library, Items \
                        FROM ( SELECT name AS Library, \
                        COUNT(duration) AS Items \
                        FROM media_items m  \
                        LEFT JOIN library_sections l ON l.id = m.library_section_id  \
                        WHERE library_section_id > 0 GROUP BY name );"
sqlite3 -header -line "$db" "$query" | tee -a $logfile
echo " " | tee -a
echo "Time to watch" | tee -a $logfile
query="SELECT Library, Minutes, Hours, Days \
                        FROM ( SELECT name AS Library, \
                        SUM(duration)/1000/60 AS Minutes, \
                        SUM(duration)/1000/60/60 AS Hours, \
                        SUM(duration)/1000/60/60/24 AS Days \
                        FROM media_items m \
                        LEFT JOIN library_sections l ON l.id = m.library_section_id \
                        WHERE library_section_id > 0 GROUP BY name );"
sqlite3 -header -line "$db" "$query" | tee -a $logfile

echo " " | tee -a

query="select count(*) from media_items"
result=$(sqlite3 -header -line "$db" "$query")
echo "${result:11} files in library" | tee -a $logfile

query="select count(*) from media_items where bitrate is null"
result=$(sqlite3 -header -line "$db" "$query")
echo "${result:11} files missing analyzation info" | tee -a $logfile

query="SELECT count(*) FROM media_parts WHERE deleted_at is not null"
result=$(sqlite3 -header -line "$db" "$query")
echo "${result:11} media_parts marked as deleted" | tee -a $logfile

query="SELECT count(*) FROM metadata_items WHERE deleted_at is not null"
result=$(sqlite3 -header -line "$db" "$query")
echo "${result:11} metadata_items marked as deleted" | tee -a $logfile

query="SELECT count(*) FROM directories WHERE deleted_at is not null"
result=$(sqlite3 -header -line "$db" "$query")
echo "${result:11} directories marked as deleted" | tee -a $logfile

query="select count(*) from metadata_items meta \
                        join media_items media on media.metadata_item_id = meta.id \
                        join media_parts part on part.media_item_id = media.id \
                        where part.extra_data not like '%deepAnalysisDate%' \
                        and meta.metadata_type in (1, 4, 12) and part.file != '';"
result=$(sqlite3 -header -line "$db" "$query")
echo "${result:11} files missing deep analyzation info." | tee -a $logfile
exit
