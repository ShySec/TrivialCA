#!/bin/bash
set -e -u
if [ ${#@} -lt 2 ]; then
  echo "usage: $0 <ca> <domain> [<subdomains>]"
  exit
fi

BITS=4096
DAYS=3650 # 10 years

DOMAIN="$2"
CA_NAME="$1"
SERVER_NAME="$2"
DATED=$(date "+%Y%m%d")

CA_PATH="ca/$CA_NAME"
CA_CRT="$CA_PATH/$CA_NAME.crt"
CA_KEY="$CA_PATH/$CA_NAME.key"
CA_SRL="$CA_PATH/$CA_NAME.srl"
CA_EXT="$CA_PATH/$CA_NAME.v3ext"

SERVER_PATH="servers/$SERVER_NAME/$DATED"
SERVER_KEY="$SERVER_PATH/$SERVER_NAME.key"
SERVER_CRT="$SERVER_PATH/$SERVER_NAME.crt"
SERVER_CSR="$SERVER_PATH/$SERVER_NAME.csr"

if [ ! -d "$SERVER_PATH" ]; then
	mkdir -p "$SERVER_PATH"
fi

# Generate server key
openssl genrsa -out "$SERVER_KEY" "$BITS"

# Copy the DNS entries to v3 extensions
SERVER_EXT="$SERVER_PATH/$SERVER_NAME.v3ext"
cp "$CA_EXT" "$SERVER_EXT"

# Generate the Subject Alternative Names
function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }
SERVER_SAN="DNS:$(join_by ",DNS:" "${@:2}")"
echo "subjectAltName=$SERVER_SAN" >> "$SERVER_EXT"

# Generate certificate signing request (CSR) for that key using the server's name as FQDN
openssl req -new -sha256 -days "$DAYS" -key "$SERVER_KEY" -out "$SERVER_CSR" -subj "/CN=$DOMAIN"

# Sign the server key with the certificate authority
openssl x509 -req -in "$SERVER_CSR" -extfile "$SERVER_EXT" -CA "$CA_CRT" -CAkey "$CA_KEY" -CAserial "$CA_SRL" -days "$DAYS" -out "$SERVER_CRT"

echo "server credentials stored in $SERVER_PATH"
