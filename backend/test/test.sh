#!/bin/sh

sleep 120

curl -k https://$ST_FQDN:444 > /dev/null
if [[ "$?" -ne "0" ]]; then
  echo "Fail to access admin service"
  exit 1
fi
echo "Successful access to admin service"
