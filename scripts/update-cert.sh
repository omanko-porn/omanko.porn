#!/bin/sh

cd $(dirname $0)/..

./bin/lego \
  --accept-tos \
  --dns godaddy \
  --domains omanko.porn \
  --domains *.omanko.porn \
  --email ykzts@desire.sh \
  --key-type rsa2048 \
  --path $(pwd)/data/lego \
  renew
