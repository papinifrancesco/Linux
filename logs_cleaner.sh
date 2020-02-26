# put the file in /usr/local/scripts (or whre you want) and define a crontab like as:
# 0 1 * * * /usr/local/scripts/logs_cleaner.sh > /dev/null 2>&1

# define the directory to work in
WDIR=/opt/tomcat/logs

# remove the old, already compressed logs
/usr/bin/find $WDIR/old/ -maxdepth 1 -type f -mtime +90 -exec rm -f {} \;

# some logs rotate daily, that's -mtime +1
/usr/bin/find $WDIR -maxdepth 1 -type f \( -mtime +1 -name "*localhost_access_log.*" \) -exec mv -f {} $WDIR/old/ \;

# some logs rotate weekly, that's -mtime +7
/usr/bin/find $WDIR -maxdepth 1 -type f \( -mtime +7 -name "*.20*" \) -exec mv -f {} $WDIR/old/ \;

# compress what is not already a .xz archive
/usr/bin/find $WDIR/old/ -maxdepth 1 -type f \( -mtime +1 ! -name "*.xz" \) -exec /usr/bin/xz -9 {} \;
