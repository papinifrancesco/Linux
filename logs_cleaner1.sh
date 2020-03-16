# put the file in /usr/local/scripts (or whre you want) and define a crontab like as:
# 0 1 * * * /usr/local/scripts/logs_cleaner.sh /opt/tomcat/logs > /dev/null 2>&1

if [ -d "$1" ]
then
      echo "\$1 exists"

# if you want to override ARG1 then
# ARG1=/opt/tomcat/logs

# remove the old, already compressed logs
find $1 -maxdepth 1 -type f -mtime +370 | while read filename ; do fuser -s $filename || rm -f $filename ; done

# compress to xz 
find $1 -maxdepth 1 -type f \( ! -name "*.xz" \) | while read filename ; do fuser -s $filename || xz -9fz $filename ; done

else
      echo "\$1 should be an existing path"
fi