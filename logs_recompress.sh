#!/bin/bash
# if the path passed as an argument exists
if [ -d "$1" ]

then
cd "$1" || exit

# remove the 0 bytes files but always check first that are not opened by a process
find "$1" -maxdepth 1 -type f -size 0 | while read -r filename ; do /sbin/fuser -s "$filename" || rm -f "$filename" ; done

for filename in ./*.gz; do
    gzip -d "$filename"
    decompressed=${filename%.gz}
    xz -9fz "$decompressed"
done
cd - || exit
fi
