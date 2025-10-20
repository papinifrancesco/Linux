#!/bin/bash
# use a dedicated folder
# usage: ./TSL-IT.xml_parser.sh > /dev/null 2>&1

# thanks to: https://github.com/eniocarboni/getTrustCAP7m for inspiring me

# goal: refine TSL-IT.xml to have list of not expired CAs ,
# ready to be used by httpd, with identifying distinguished name
# before each certificate

# do the cleanings
rm -f cert-* CA* expired_CA_* actual_CA_* *.jks


XML_CERTS='https://eidas.agid.gov.it/TL/TSL-IT.xml'
CA_PEM='CA.pem'

# get the eIDAS certificates list
wget --tries=2 -O CA_ALL.xml ${XML_CERTS} 


# lets remove the whole <ServiceHistory> sections
# it leads to false "IdV" later on
sed '/<ServiceHistory>/,/<\/ServiceHistory>/d' CA_ALL.xml > CA_tmp1.xml


# We want only "IdV" CAs
awk '/IdV<\/ServiceTypeIdentifier>/,/<\/X509Certificate>/' CA_tmp1.xml > CA_tmp2.xml


# We just want the certificate name exactly as reported by eIDAS
# and the certificate itself
grep -E '<Name |X509Certificate' CA_tmp2.xml > CA_tmp3.xml 


# clean the gertificate name and leave it as a comment (used later)
sed -e 's/.*<Name xml:lang="en">/# /g' -e 's/<\/Name>//g' CA_tmp3.xml > CA_tmp4.xml


# lets define BEGIN and END CERTIFICATE
sed -e 's/<X509Certificate>/-----BEGIN CERTIFICATE-----\n/g' -e 's#</X509Certificate>#\n-----END CERTIFICATE-----\n#g' CA_tmp4.xml > CA.pem


# Divide $CA_PEM into single certificate files
csplit -s -z -f cert- "$CA_PEM" "/# CN/" '{*}'


# check that the certificate hasn't expired already
# echo "These certificate have expired:"
for filename in ./cert-* ; do openssl x509 -checkend 0 -in "$filename" > /dev/null 2>&1 ; ExitCode=$?

# if expired, show which one it is and then delete it
if [ "$ExitCode" -eq 1 ]; then
  head -n1 "$filename" >> expired_CA_preliminary_list.txt
  rm -f "$filename"
else

# lets save our subject as eIDAS wrote it
comment=$(head -n1 "$filename")

# canonicalize the file and prepend its subject
openssl x509 -in "$filename" -out "$filename.pem"

# add the comment to the cert
echo "$comment"|cat - "$filename.pem" > /tmp/out && mv /tmp/out "$filename.pem"

# add a newline to the cert
echo "" >> "$filename.pem"

# import into a JKS trustore
ALIAS=$(echo $comment | sed 's/# //g')
keytool -import -file "$filename" -alias "$ALIAS" -keystore ca_abilitate.jks -storepass 123456 -noprompt

# remove the old temporary file
rm -f "$filename"

fi
done



# concatenate all the single file certificates into a one, single, big, file.
cat cert-*.pem > ca_abilitate.pem

# create a PKCS7 file (optional)
openssl crl2pkcs7 -nocrl -certfile ca_abilitate.pem -out ca_abilitate.p7b

# extract just a list of the actual, good, IdV, CAs
grep \# ca_abilitate.pem > actual_CA_list.txt


# do we really need to sort the files?
# not really but I liked it
sort expired_CA_preliminary_list.txt > expired_CA_preliminary_list_sorted.txt
sort actual_CA_list.txt > actual_CA_list_sorted.txt
sed -i 's/\r$//' ca_abilitate.pem

# check if the expired CAs have been replaced with new certificates:
# I want to see only the ones that have expired and never renewed
echo "Expired, not renewed CAs"

while IFS= read -r line; do
    grep -q "$line" actual_CA_list_sorted.txt ;
if [ $? -eq 1 ]; then
  echo "$line"
fi
done < expired_CA_preliminary_list_sorted.txt ; 
