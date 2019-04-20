#!/bin/bash
set -e -u
if [ ${#@} -lt 2 ]; then
  echo "usage: $0 <ca> <csr> [<server>]"
  exit
fi

DAYS=3650 # 10 years

CA_NAME="$1"
CSR_NAME="$2"
DATED=$(date "+%Y%m%d")

if [ ${#@} -gt 2 ]; then
	SERVER_NAME="$3"
elif [ "${CSR_NAME: -4}" == ".csr" ] || [ "${CSR_NAME: -4}" == ".req" ]; then
	SERVER_NAME="${CSR_NAME:0:-4}"
else
	echo "usage: $0 <ca> <csr> [<server>]"
	exit
fi

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

echo
echo "double-check CSR canonical names and Subject Alternative Names"
openssl req -noout -text -in "$SERVER_CSR" | grep --color=never "Subject:"
echo

# copy the SCR to our output directory for easy reference
cp "$CSR_NAME" "$SERVER_CSR"

# Sign the server key with the certificate authority
openssl x509 -req -in "$SERVER_CSR" -CA "$CA_CRT" -CAkey "$CA_KEY" -CAserial "$CA_SRL" -days "$DAYS" -out "$SERVER_CRT"

echo "server credentials stored in $SERVER_PATH"
