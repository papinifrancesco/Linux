#!/bin/bash

# usage:
# diffa.sh path1/to1/file1 path2/to2/file2
# doesn't work for XML files
# the logic here is to compare files that have an ATTRIBUTE=VALUE structure

# remove the lines beginning with "#" because are just comments
sed '/^#/ d' < "$1" > /tmp/temp1.txt
sed '/^#/ d' < "$2" > /tmp/temp2.txt


# sort duplicates , investigate the file in case of duplicates!!
sort /tmp/temp1.txt > /tmp/temp3.txt
sort /tmp/temp2.txt > /tmp/temp4.txt

# compare
diff -y -W220 /tmp/temp3.txt /tmp/temp4.txt

rm -f /tmp/temp3.txt /tmp/temp4.txt
