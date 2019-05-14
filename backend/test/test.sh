#!/bin/sh
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Copyright (c) 2019 Axway Software SA and its affiliates. All rights reserved.
#
sleep 120

curl -k https://$ST_FQDN:444 > /dev/null
if [[ "$?" -ne "0" ]]; then
  echo "Fail to access admin service"
  exit 1
fi
echo "Successful access to admin service"
