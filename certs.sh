#!/usr/bin/env bash
set -euo pipefail

PWD="$(pwd)"
STORE="$PWD/ca-trust.p12"
PASS="changeit"

# cleanup old
rm -f "$STORE" cert-*.pem

# split the bundle into cert-00.pem, cert-01.pem, .
csplit -z -f cert- -b "%02d.pem" /etc/ssl/certs/ca-certificates.crt '/-----BEGIN CERTIFICATE-----/' '{*}'

# create empty PKCS12
openssl pkcs12 -export \
    -in cert-00.pem \
    -nokeys \
    -certfile cert-00.pem \
    -out "$STORE" \
    -name "sys-ca-00" \
    -passout pass:"$PASS"

# import the rest
for cert in cert-*.pem; do
    idx="${cert#cert-}"
    idx="${idx%.pem}"
    alias="sys-ca-$idx"
    keytool -importcert \
        -trustcacerts \
        -noprompt \
        -alias "$alias" \
        -file "$cert" \
        -keystore "$STORE" \
        -storetype PKCS12 \
        -storepass "$PASS"
done

# list first 20 entries
keytool -list \
    -keystore "$STORE" \
    -storetype PKCS12 \
    -storepass "$PASS" |
    head -n20
