# 202011041126
# put the file in /usr/local/scripts (or whre you want) and define a crontab like as:
#                                                  FOLDER        DAYS  ARCHIVE FOLDER
# 0 1 * * * /usr/local/scripts/logs_cleaner.sh /opt/tomcat/logs  370   history        > /dev/null 2>&1

# if the path passed as an argument exists
if [ -d "$1" ]

then
# remove the 0 bytes files but always check first that are not opened by a process
find $1 -maxdepth 1 -type f -size 0 | while read filename ; do /sbin/fuser -s $filename || rm -f $filename ; done
# remove the old files but always check first that are not opened by a process
find $1 -maxdepth 1 -type f -mtime +$2 | while read filename ; do /sbin/fuser -s $filename || rm -f $filename ; done

# if the path passed as an argument does not exist
else
      echo "\$1 should be an existing path"
fi


if [ ! -z $3 ] && [ -d "$1/$3" ]

then

# compress to xz only a file what is not a xz archive already
# xz is smart enough to do that check itself but we'd waste time
find ./ -maxdepth 1 \( -type f ! -name "*.?z" \)          -a \
                    \( -type f ! -name "catalina.out*" \)    \
                    | while read filename ; do /sbin/fuser -s $filename || xz -9fz $filename ; done

mv $1/*.xz $1/$3/

else
      echo "archive folder unset or non existing"

fi
