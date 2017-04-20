#!/usr/bin/env python3

# Plex analayze all files that are missing analyzation info
# OS: Ubunti 16.04 ( in case of other OS's make sure to change paths )
# Usage: python3 plex-analyze-cli.py

import subprocess
import sqlite3

# Define some variables
DBPath = '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db' # This is the default path.
concurrentCount = 100 # This is how many files will be analyzed in 1 command. Plex handles them one at a time but this reduces the number of calls to the scanner and speeds things up.
analyzeScript = "/scripts/plex/reanalyzeItem.sh" # Path to your refreshMetadataItem script.

conn = sqlite3.connect(DBPath)

c = conn.cursor()
c.execute('''Select media_items.metadata_item_id As id, metadata_items.title As title
			 From media_items Inner Join metadata_items On media_items.metadata_item_id = metadata_items.id
			 Where media_items.bitrate Is Null And Not metadata_items.metadata_type = "12"''')

items = c.fetchall()
conn.close()

def analyzeThese(ids):
    ids = ids[:-1]
    print("Going to analyze the following ID's: {0}".format(ids))
    subprocess.check_call([analyzeScript, ids])

print("There are {0} files that need to be analyzed.".format(str(len(items))))

itemString = ''
itemCount = len(items)
count = 0
for row in items:
    itemString = itemString + str(row[0]) + ',' # This adds the current item to the ongoing string.
    count = count + 1
    itemCount = itemCount - 1 # Keep an up to date number of remaining items.
    if itemCount >= concurrentCount:
        if count >= concurrentCount:
            # Analyze these files.
            analyzeThese(itemString)
            itemString = '' # Reset the itemString.
    else:
        if itemCount <= 0 and itemString != '':
            analyzeThese(itemString)
            itemString = '' # Reset the itemString.

print("Finished analyzing all items.")