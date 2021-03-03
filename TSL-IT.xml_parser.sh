#!/bin/bash
# usage: ./TSL-IT.xml_parser.sh > /dev/null 2>&1

# thanks to: https://github.com/eniocarboni/getTrustCAP7m
# for inspiring me

# goal: refine TSL-IT.xml to have list of not expired CAs ,
# ready to be used by httpd, with identifying distinguished name
# before each certificate, example:

# certificate subject
# -----BEGIN CERTIFICATE-----
# [data]
# -----END CERTIFICATE-----BEGIN


XML_CERTS='https://eidas.agid.gov.it/TL/TSL-IT.xml'
CA_XML='CA.xml'
CA_PEM='CA.pem'

wget --tries=2 -O CA.xml ${XML_CERTS}
# TSL-IT.xml now is only one line long so we add e return value before start tag and after tag (X509Certificate)
for i in $(sed -e 's/<X509Certificate/\n<X509Certificate/g' -e s'#</X509Certificate>#</X509Certificate>\n#g' "$CA_XML" | grep '<X509Certificate'); do
  echo -e "-----BEGIN CERTIFICATE-----"
  echo "$i"| sed -e 's/<\/*X509Certificate>//g'| openssl base64 -d -A| openssl base64
  echo -e "-----END CERTIFICATE-----"
done > "$CA_PEM"
rm -f "$CA.xml"


# Divide $CA_PEM into single certificate files
csplit -s -z -f cert- "$CA_PEM" '/-----BEGIN CERTIFICATE-----/' '{*}'


# check that each certificate won't expire in one second
# another way to say: check that the certificate isn't expire already
for filename in ./cert-* ; do openssl x509 -checkend 1 -in "$filename"

# if expired, delete it
if [ $? -eq 1 ]; then
  rm -f "$filename"
fi

done

# check that each certificate has 1.3.159.6.5.1 policy
for filename in ./cert-* ; do openssl x509 -noout -text -ext certificatePolicies -in "$filename" | grep -m1 -F '1.3.159.6.5.1'

if [ $? -eq 1 ]; then
  rm -f "$filename"
else

# canonicalize the file and prepend its subject
openssl x509 -subject -in "$filename" -out "$filename.pem"

fi

# remove the old temporary file
rm -f "$filename"

done

# concatenate all the single file certificates into a one, single, big, file.
cat cert-*.pem > ca_abilitate.pem

# substitute "subject" with a newline a # and a space
# I like to clearly delimit one certificate from the next one
sed -i 's/subject=/\n# /g' ca_abilitate.pem

# do the cleanings
rm -f cert-*.pem CA.pem CA.xml
