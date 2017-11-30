#!/bin/sh

cd $(dirname $0)/..

docker run \
  --rm \
  -v $(pwd)/data/letsencrypt:/etc/letsencrypt \
  -v $(pwd)/public:/usr/share/nginx/html \
  certbot/certbot \
  certonly \
  --webroot \
  --non-interactive \
  --agree-tos \
  --renew-by-default \
  --webroot-path /usr/share/nginx/html \
  --email ykzts@desire.sh \
  --cert-name omanko.porn \
  --domains omanko.porn,files.omanko.porn,www.omanko.porn
