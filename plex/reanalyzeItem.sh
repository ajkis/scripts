#!/bin/bash

# Re-analyze an item or items.
# Usage: bash reanalyzeItem.sh {itemID}
#        bash reanalyzeItem.sh {itemID,itemID}
#        bash reanalyzeItem.sh 12345
#        bash reanalyzeItem.sh 12345,67788,23425

echo "Input items are: ${1}"

PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR='/var/lib/plexmediaserver/Library/Application Support' LD_LIBRARY_PATH='/usr/lib/plexmediaserver' /usr/lib/plexmediaserver/Plex\ Media\ Scanner \
        --verbose \
        --analyze \
        --item ${1}

exit 0
