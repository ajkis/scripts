#!/usr/bin/env python3
#
# This script will place movies and TV episodes on folders
# Files are not modifed or renamed only moved to folders.
#
# Usage:: ./movie&TV2folder.py /path/movies/  (Movie 1 (year) , Movie)
# Usage:: ./movie&TV2folder.py /path/tv/  ( tv folders: Tile 1, Title 2 )
# Type of files:
#
#   Movies: (scans 1 folder deep - i.e. not recursive)
#     All files bellow would be moved to folder: ./Movie Title (2017)
#     Movie Title (2017) 1080p.mkv
#     Movie Title (2017) anything else.*
#     Movie Title (2017).*
#     Movie Title.mkv  -->  **would not be moved, since missing (year)**
#
#   Series: (scans 2 folders deep)
#     All files bellow would be moved to folder: ./Season 04/
#     Farscape - S04E01.mkv
#     Farscape - S04E01-E02.mkv
#     Farscape - S04E01
#     S04E01 - Farscape - group.mkv
#     Daily Show S2014E20  - would be moved to ./Season 2014/
#
#   Additional rules:
#   On OS error: retry operation 3 times with 1 second delay between attempts.
#   If move fails it continue with other files.

import os, sys, re, time

nr_arg = len(sys.argv)
if nr_arg != 2:
    print("Usage ./movie&TV2folder.py media-files-folder")
    quit()

src_root_path = str(sys.argv[1])
dst_root_path = src_root_path

if not os.path.isdir(src_root_path):
    print("files2folders.py: source folder doesn't exist (" + src_root_path + ")")
    quit()

if not os.path.isdir(dst_root_path):
    print("files2folders.py: destination folder doesn't exist (" + dst_root_path + ")")
    quit()



def my_rename(src, dst):
    new_dst_path = os.path.dirname(dst)
    retries = 3
    for attempt in range(0, 3):
        try:
            if True:
                if not os.path.exists(new_dst_path):
                    os.makedirs(new_dst_path)
                os.rename(src, dst)
            #os.rename('/foo!', '/foo!')   # uncommet to simulate OSError
            break;
        except OSError as err:
            print("files2folders.py: OS error: {0}".format(err) + (" - retrying" if attempt < retries - 1 else " - aborting") )
            time.sleep(1)


def do_it(src_path, dst_path, depth):
    for path, dirs, files in os.walk(src_path):
        for name in files:
            pathname = os.path.join(path, name)
            dst_pathname = ""

            #seasons
            r = re.match("^.+?[-\\s]s([0-9]{2})e.*", name, re.I)
            if not r:
                r = re.match("^s([0-9]{2})e.*", name, re.I)
            if not r:
                r = re.match("^s([0-9]{4})e.*", name, re.I)
            if r:
                dst_pathname = os.path.join(os.path.join(dst_path, "Season " + str(r.group(1))), name)
                print("files2folders.py: series: " + pathname + " -> " + dst_pathname)
                my_rename(pathname, dst_pathname)
                continue

            #movies
            if depth == 0:
                r = re.match("^(.+?\\([0-9]{4}\\)).*", name, re.I)
                if r:
                    dst_pathname = os.path.join(os.path.join(dst_path, str(r.group(1))), name)
                    print("files2folders.py: movie: " + pathname + " -> " + dst_pathname)
                    my_rename(pathname, dst_pathname)
                    continue

            #others
            print("files2folders.py: skipped: " + pathname)

        if depth == 0:
            for name in dirs:
                do_it(os.path.join(src_path, name), os.path.join(dst_path, name), depth + 1)

        break; #abort recursion in os.walk()


do_it(src_root_path, dst_root_path, 0)
