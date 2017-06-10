#!/bin/bash
## The function of this script is to show you possible wrongly maateched movies in Plex Media Server
## Copy paste URL result in broser and use Plex feature: Fix Matched
##
## Setup
## 1. chmod a+x plex-list-matched-wrong.sh
## 2. Set correct paths in variables
##
## More scripts at: https://github.com/ajkis/scripts
## If you find script useful feel free to buy me a beer at https://paypal.me/ajki

if pidof -o %PPID -x "$0"; then
   exit 1
fi
LOGFILE="/home/plex/logs/pmsmatchwrong.log"
DB="/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db"
PLEXURL="http://XXX.net/web/index.html#!/server/XXX/details?key=%2Flibrary%2Fmetadata%2F"


if [[ -f $LOGFILE ]]; then
    rm -f $LOGFILE
fi

qcase1=" \
with \
   movies_only as ( \
        select * \
        from metadata_items \
        where library_section_id = $MOVIESSECTION \
        and title <> '' \
    ), \
    duplicates as ( \
        select * \
        from movies_only \
        where title || year in ( \
            select t_y \
            from ( \
                select title || year as t_y, count(*) N \
                from movies_only \
                group by title || year \
            ) as x \
            where N >= 2 \
        ) \
    ) \
select \
    duplicates.id as metadata_items_id, \
    duplicates.title as metadata_items_title, \
    media_parts.file as media_parts_file \
from duplicates \
join media_items \
    on media_items.metadata_item_id = duplicates.id \
join media_parts \
    on media_parts.media_item_id = media_items.id \
order by duplicates.title \
"

qcase2="with \
    movies_only as ( \
        select * \
        from metadata_items \
        where library_section_id = $MOVIESSECTION \
        and title <> '' \
    ), \
    duplicates as ( \
        select * \
        from movies_only \
        where title || year in ( \
            select t_y \
            from ( \
                select title || year as t_y, count(*) N \
                from movies_only \
                group by title || year \
            ) as x \
            where N >= 1 \
        ) \
    ), \
    merged as ( \
        select \
            duplicates.id as metadata_items_id, \
            duplicates.title as metadata_items_title, \
            media_parts.file as media_parts_file \
        from duplicates \
        join media_items \
            on media_items.metadata_item_id = duplicates.id \
        join media_parts \
            on media_parts.media_item_id = media_items.id \
    ) \
select * \
from merged \
where media_parts_file not like '%' || replace(replace(replace(replace(metadata_items_title, ':', ''), '...', ''), '?', ''), '  ', ' ') || '%' \
order by metadata_items_title \
"

readarray -t case1 < <(sqlite3 "$DB" "$qcase1")
readarray -t case2 < <(sqlite3 "$DB" "$qcase2")

echo "POSSIBLY WRONLGY MATCHED MOVIES WHERE TITLE IS NOT UNIQUE" | tee -a $LOGFILE
echo "One of the results is correct, check based on file name and manually fix second one"
echo "Copy paste URL in browser and use Fix Match"
sqlite3 "$DB" "$query1" |

for result in "${case1[@]}"
do
    echo "$result" | tee -a $LOGFILE
    result=$(echo $result | cut -d "|" -f1)
    echo "URL: ${PLEXURL}$result" | tee -a $LOGFILE
    echo " " | tee -a $LOGFILE
done
echo " " | tee -a $LOGFILE

echo "POSSIBLY WRONLGY MATCHED MOVIES WHERE PLEX TITLE IS NOT PRESENT IN FOLDER OR FILE NAME"
echo "Copy paste URL in browser and use Fix Match"
for result in "${case2[@]}"
do
    echo "$result" | tee -a $LOGFILE
    result=$(echo $result | cut -d "|" -f1)
    echo "URL: ${PLEXURL}$result" | tee -a $LOGFILE
    echo " " | tee -a $LOGFILE
done
echo "Finished, all results are logged in: $LOGFILE"
exit
