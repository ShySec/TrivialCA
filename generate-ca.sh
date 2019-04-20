#!/bin/bash
set -e -u
if [ ${#@} -lt 1 ]; then
  echo "usage: $0 <name>"
  exit
fi

BITS=4096
DAYS=7300 # 20 years

CA_NAME="$1"
CA_PATH="ca/$CA_NAME"
CA_CRT="$CA_PATH/$CA_NAME.crt"
CA_KEY="$CA_PATH/$CA_NAME.key"
CA_SRL="$CA_PATH/$CA_NAME.srl"
CA_EXT="$CA_PATH/$CA_NAME.v3ext"

SUBJECTDATA="/O=$CA_NAME"

if [ ! -d "$CA_PATH" ]; then
	mkdir -p "$CA_PATH"
fi

# Generate certificate authority (CA) key
openssl genrsa -out "$CA_KEY" "$BITS"

# Generate the CA certificate signed with our key (self-signed)
openssl req -x509 -new -nodes -key "$CA_KEY" -sha256 -days "$DAYS" -out "$CA_CRT"

# Initialize the CA serial number
echo "01" > "$CA_SRL"

# Initialize the v3 extensions file
cat <<EOF > "$CA_EXT"
basicConstraints=CA:FALSE
authorityKeyIdentifier=keyid,issuer
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
EOF
