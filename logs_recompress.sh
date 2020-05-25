#!/bin/bash
cd /var/log/opensso/opensso-debug/history/
for filename in ./*.gz; do
    gzip -d $filename
    xz -9fz *.log
done
