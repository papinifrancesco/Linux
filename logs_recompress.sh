#!/bin/bash
cd $1
for filename in ./*.gz; do
    gzip -d $filename
    decompressed=${filename%.gz}
    xz -9fz $decompressed
done
