#!/bin/bash
if [ ! -f /etc/postfix/ssl/postfix.key ]; then
    mkdir -p /etc/postfix/ssl/ && cd /etc/postfix/ssl
    openssl genrsa -out postfix.key 2048
    openssl req -new -key postfix.key -out postfix.csr -subj "/C=XX/L=XX/O=XX/CN=domain.tld"
    openssl x509 -req -days 3650 -in postfix.csr -signkey postfix.key -out postfix.crt
fi
