#!/bin/bash
# https://eidas.agid.gov.it/TL/TSL-IT.xml
# thanks to: https://github.com/eniocarboni/getTrustCAP7m
# goal: to have list of not expired CAs , ready to be used by httpd,
# with comments before each certificate, example:

# certificate subject
# -----BEGIN CERTIFICATE-----
# [data]
# -----END CERTIFICATE-----BEGIN

XML_CERTS='https://eidas.agid.gov.it/TL/TSL-IT.xml'
CA_XML='CA.xml'
CA_PEM='CA.pem'

wget --tries=2 -O CA.xml ${XML_CERTS}
# TSL-IT.xml now is only one line long so we add e return value before start tag and after tag (X509Certificate)
for i in `sed -e 's/<X509Certificate/\n<X509Certificate/g' -e s'#</X509Certificate>#</X509Certificate>\n#g' "$CA_XML" | grep '<X509Certificate'`; do
  echo -e "-----BEGIN CERTIFICATE-----"
  echo $i| sed -e 's/<\/*X509Certificate>//g'| openssl base64 -d -A| openssl base64
  echo -e "-----END CERTIFICATE-----"
done > "$CA_PEM"
rm -f "$CA.xml"


csplit -s -z -f cert- "$CA_PEM" '/-----BEGIN CERTIFICATE-----/' '{*}'

for filename in ./cert-* ; do openssl x509 -checkend 1 -in "$filename"

if [ $? -eq 1 ]; then
  rm -f "$filename"
fi

openssl x509 -subject -in "$filename" -out "$filename.pem"

rm -f "$filename"

done

cat cert-*.pem > ca_abilitate.pem

sed -i 's/subject=/\n# /g' ca_abilitate.pem

rm -f cert-*.pem CA.pem CA.xml
