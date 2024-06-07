# We're given a P12 file and we need to update our Apache httpd, extracting:
# private key , certificate chain, server certificate

# let's define a base name
FILE=arpasupport.tix.it

# I know but I'm lazy
PASS=123456

# extract private key , certificate chain, server certificate
openssl pkcs12 -in "$FILE".p12 -nocerts -nodes  -out "$FILE".key       -passin pass:$PASS

# extract certificate chain
openssl pkcs12 -in "$FILE".p12 -nokeys          -out "$FILE"-chain.pem -passin pass:$PASS

# extract server certificate
openssl pkcs12 -in "$FILE".p12 -clcerts -nokeys -out "$FILE".crt       -passin pass:$PASS





