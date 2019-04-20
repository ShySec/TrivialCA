#!/bin/bash
set -e -u
if [ ${#@} -lt 1 ]; then
  echo "usage: $0 <ca> <server>"
  exit
fi

BITS=4096
DAYS=3650 # 10 years

CA_NAME="$1"
SERVER_NAME="$2"
DATED=$(date "+%Y%m%d")

CA_PATH="ca/$CA_NAME"
CA_CRT="$CA_PATH/$CA_NAME.crt"
CA_KEY="$CA_PATH/$CA_NAME.key"
CA_SRL="$CA_PATH/$CA_NAME.srl"

SERVER_PATH="servers/$SERVER_NAME/$DATED"
SERVER_KEY="$SERVER_PATH/$SERVER_NAME.key"
SERVER_CRT="$SERVER_PATH/$SERVER_NAME.crt"
SERVER_CSR="$SERVER_PATH/$SERVER_NAME.csr"

if [ ! -d "$SERVER_PATH" ]; then
	mkdir -p "$SERVER_PATH"
fi

# Generate server key
openssl genrsa -out "$SERVER_KEY" "$BITS"

# Generate certificate signing request (CSR) for that key using the server's name as FQDN
openssl req -new -days "$DAYS" -key "$SERVER_KEY" -out "$SERVER_CSR"

# Sign the server key with the certificate authority
openssl x509 -req -in "$SERVER_CSR" -CA "$CA_CRT" -CAkey "$CA_KEY" -CAserial "$CA_SRL" -days "$DAYS" -out "$SERVER_CRT"

echo "server credentials stored in $SERVER_PATH"
