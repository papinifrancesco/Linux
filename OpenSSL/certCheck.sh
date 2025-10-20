USERCERT=PRNCLD68S06G337C_Regione_Emilia_Romagna_CA_Cittadini_.cer
CRL=crl.crl

# Step 1: Get certificate serial number
SERIAL=$(openssl x509 -in $USERCERT -noout -serial | cut -d '=' -f 2)

# Step 2: Check CRL for the serial number
openssl crl -in $CRL -inform DER -text -noout | grep -i "$SERIAL"

# Step 3: Interpret results
if [ $? -eq 0 ]; then
  echo "Certificate is revoked! ❌"
else
  echo "Certificate not revoked. ✅"
fi
