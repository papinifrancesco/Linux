# OpenSSL Commands to Generate a .p12 File
#
# This script will:
# 1. Generate a 2048-bit RSA private key and a self-signed X.509 certificate.
# 2. Package the private key and certificate into a PKCS#12 (.p12) file.
#
# Parameters:
# - RSA key size: 2048 bits
# - Common Name (CN): ACS-ASS
# - Organizational Unit (OU): ECM
# - Organization (O): TAI
# - Locality (L): Tuscany
# - Country (C): IT
# - Extended Key Usages (EKU): TLS Web Client Authentication, TLS Web Server Authentication
# - Subject Alternative Names (SANs): DNS:acs, DNS:ass
# - Output alias/friendly name in .p12: ACS-ASS

# --- Step 1: Generate RSA Private Key and Self-Signed Certificate ---

# This command creates a new 2048-bit RSA private key (ACS-ASS_private_key.pem)
# and a self-signed certificate (ACS-ASS_certificate.pem) valid for 3650 days (approx. 10 years).
# The -nodes option means the private key file itself will not be encrypted with a passphrase.
# The -subj option sets the distinguished name fields directly.
# The -addext options add X.509 v3 extensions for Subject Alternative Name, Extended Key Usage,
# Key Usage, and Basic Constraints.

echo "Generating RSA private key and self-signed certificate..."
openssl req -x509 \
    -newkey rsa:2048 \
    -keyout ACS-ASS_private_key.pem \
    -out ACS-ASS_certificate.pem \
    -days 3650 \
    -nodes \
    -subj "/C=IT/L=Tuscany/O=TAI/OU=ECM/CN=ACS-ASS" \
    -addext "subjectAltName = DNS:acs,DNS:ass,DNS:alfresco,DNS:solr,DNS:localhost" \
    -addext "extendedKeyUsage = serverAuth, clientAuth" \
    -addext "keyUsage = critical, digitalSignature, keyEncipherment" \
    -addext "basicConstraints = critical, CA:FALSE"

if [ $? -eq 0 ]; then
    echo "Private key (ACS-ASS_private_key.pem) and certificate (ACS-ASS_certificate.pem) generated successfully."
else
    echo "Error generating private key and certificate. Please check OpenSSL installation and command parameters."
    exit 1
fi

echo ""
echo "--- Step 2: Create the PKCS#12 (.p12) file ---"

# This command bundles the private key (ACS-ASS_private_key.pem) and
# the certificate (ACS-ASS_certificate.pem) into a single PKCS#12 file (ACS-ASS.p12).
# You will be prompted to create an export password for this .p12 file.
# This password will be required when you import the .p12 file into an application or keystore.
# The -name option sets a "friendly name" or alias for the certificate entry within the .p12 file.

openssl pkcs12 -export \
    -out ACS-ASS.p12 \
    -inkey ACS-ASS_private_key.pem \
    -in ACS-ASS_certificate.pem \
    -name "ACS-ASS"
    # You will be prompted for an export password here. Choose a strong password and remember it.

if [ $? -eq 0 ]; then
    echo "PKCS#12 file (ACS-ASS.p12) created successfully."
    echo "Make sure to remember the export password you set for ACS-ASS.p12."
else
    echo "Error creating PKCS#12 file."
    exit 1
fi

echo ""
echo "Process complete. You should now have the following files:"
echo "- ACS-ASS_private_key.pem (Unencrypted RSA private key)"
echo "- ACS-ASS_certificate.pem (Self-signed X.509 certificate)"
echo "- ACS-ASS.p12 (PKCS#12 file containing the key and certificate)"
echo ""
echo "For security, you may want to restrict permissions on ACS-ASS_private_key.pem"
echo "or delete ACS-ASS_private_key.pem and ACS-ASS_certificate.pem if you only need the .p12 file"
echo "and have securely backed up ACS-ASS.p12 and its password."

# --- Explanation of OpenSSL req parameters used in Step 1 ---
# req: PKCS#10 certificate request and certificate generating utility.
# -x509: Output a self-signed certificate instead of a certificate request.
# -newkey rsa:2048: Generate a new RSA key of 2048 bits.
# -keyout ACS-ASS_private_key.pem: File to save the newly created private key.
# -out ACS-ASS_certificate.pem: File to save the certificate.
# -days 3650: Validity of the certificate in days.
# -nodes: (No DES) Do not encrypt the output private key.
# -subj "/C=IT/L=Tuscany/O=TAI/OU=ECM/CN=ACS-ASS": Subject Name.
#   C: Country Name (2 letter code)
#   L: Locality Name (eg, city)
#   O: Organization Name (eg, company)
#   OU: Organizational Unit Name (eg, section)
#   CN: Common Name (eg, FQDN or your name)
# -addext "subjectAltName = DNS:acs,DNS:ass": Add Subject Alternative Names.
# -addext "extendedKeyUsage = serverAuth, clientAuth":
#   serverAuth: TLS WWW server authentication.
#   clientAuth: TLS WWW client authentication.
# -addext "keyUsage = critical, digitalSignature, keyEncipherment": Defines the purpose of the key.
#   critical: Marks this extension as critical.
#   digitalSignature: For verifying digital signatures.
#   keyEncipherment: For encrypting keys.
# -addext "basicConstraints = critical, CA:FALSE": Specifies if this is a CA certificate (FALSE means it's an end-entity certificate).

# --- Explanation of OpenSSL pkcs12 parameters used in Step 2 ---
# pkcs12: PKCS#12 file utility.
# -export: Output a PKCS#12 file.
# -out ACS-ASS.p12: Output file name for the PKCS#12 bundle.
# -inkey ACS-ASS_private_key.pem: Input private key file.
# -in ACS-ASS_certificate.pem: Input certificate file (can also include chain certificates).
# -name "ACS-ASS": Sets a friendly name (alias) for the certificate and key in the .p12 file.

