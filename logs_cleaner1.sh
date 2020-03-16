# put the file in /usr/local/scripts (or whre you want) and define a crontab like as:
# 0 1 * * * /usr/local/scripts/logs_cleaner.sh /opt/tomcat/logs > /dev/null 2>&1

# if the path passed as an argument exists
if [ -d "$1" ]

then
# remove the old files but always check first that are not opened by a process
find $1 -maxdepth 1 -type f -mtime +370 | while read filename ; do fuser -s $filename || rm -f $filename ; done

# compress to xz only a file what is not a xz archive already
# xz is smart enough to do that check itself but we'd waste time
find $1 -maxdepth 1 -type f \( ! -name "*.xz" \) | while read filename ; do fuser -s $filename || xz -9fz $filename ; done

# if the path passed as an argument does not exist
else
      echo "\$1 should be an existing path"
fi
