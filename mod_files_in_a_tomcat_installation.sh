# the idea is: I have a /opt/tomcat/ and , since nobody documented nothing, I need to find which
# files have been modified from the vanilla installation. BEWARE, work in progress
# what about diff -qr ? Well provided you get the original package (tar.gz or else) and you have enough
# free space then that is ok as well

# work-flow: get all the file dates and list the occurrencies TO BE DONE

cd /opt/tomcat/
rm -f /tmp/temp1.txt

# find all the files that we think are newer than the ones extracted from the vanilla tar.gz archive
# filter out the obvious ones (logs for example)
find . -type f -newermt "2013-10-18 12:22:09" ! -name "*.log" ! -name "localhost_access_log*" -exec ls -gGo --full-time {} +  >> /tmp/temp1.txt

# show me what have been changed
cat /tmp/temp1.txt |  awk 'BEGIN { FS = " " } ; { print $4 " " $5 " " $7 }' | sort
