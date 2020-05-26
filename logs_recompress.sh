#!/bin/bash
# if the path passed as an argument exists
if [ -d "$1" ]
then
cd $1
for filename in ./*.gz; do
    gzip -d $filename
    decompressed=${filename%.gz}
    xz -9fz $decompressed
done
cd -
