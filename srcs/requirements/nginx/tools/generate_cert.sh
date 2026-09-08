#!/bin/bash
set -e

mkdir -p /etc/nginx/ssl

echo "genarate ssl..."

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out    /etc/nginx/ssl/inception.crt \
    -subj "/C=MA/ST=RabatSale/L=Sale/O=42/OU=42/CN=${DOMAIN_NAME}"

nginx -t

echo "run nginx ..."

exec nginx -g "daemon off;"