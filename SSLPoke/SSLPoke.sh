
/var/nfsshare/java/bin/javac SSLPoke.java


OPTS="-Djavax.net.debug=all"

PORT=443

SITE=hazelcast.com

/var/nfsshare/java/bin/java $OPTS SSLPoke $SITE $PORT
