#!/usr/bin/env python3
# analyzedeeply.cli will preform deep analyzation only on files that were not processed yet
from subprocess import call
import os
import requests
import sqlite3
import sys
import time

conn = sqlite3.connect('/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db')

c = conn.cursor()
c.execute('select meta.id from metadata_items meta \
join media_items media on media.metadata_item_id = meta.id \
join media_parts part on part.media_item_id = media.id \
where part.extra_data not like "%deepAnalysisVersion=2%" \
and meta.metadata_type in (1, 4, 12) and part.file != "";')

items = c.fetchall()
conn.close()

print("ANALYZE DEEPLY START")
print("Number of video files to process: " + str( len(items) ))
start_time = time.time()

for row in items:
    print ("Processing video id: " + str(row[0]))
    start_row = time.time()
    os.system('LD_LIBRARY_PATH=/usr/lib/plexmediaserver \
               PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/var/lib/plexmediaserver/Library/Application\ Support \
               /usr/lib/plexmediaserver/Plex\ Media\ Scanner --analyze-deeply -o ' + str(row[0]))
    end_row = time.time()
    print ("Video id:" + str(row[0]) + " took {:.2f} seconds to process".format(end_row - start_row))
end_time = time.time()
print ("Files proccessed:" + str(row[0]) + " in {:.2f} seconds".format(end_row - start_row))
