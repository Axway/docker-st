#!/bin/sh
#
# Copyright (c) Axway Software, 2019. All Rights Reserved.
# 
# 1. Check if we are running the script on a backend
# 1.1. If backend - configure Sentinel and Network zones if JSON files are provided
# 1.2. If Edge - update Private Zone if JSON file provided
#

PATH=/usr/bin:/bin:/usr/sbin:/sbin

. "${FILEDRIVEHOME}/bin/common.sh"

ADMIN_UI_URI=${ST_ADMIN_UI_URI:-127.0.0.1:444}
ADMIN_CREDENTIAL=admin:admin@

SENTINEL_CONFIG_PATH=${ST_SENTINEL_CONFIG_PATH:-"${FILEDRIVEHOME}/conf/SentinelGlobalConfig.json"}
NETWORK_ZONES_CONFIG_PATH=${ST_NETWORK_ZONES_CONFIG_PATH:-"${FILEDRIVEHOME}/conf/NetworkZonesGlobalConfig.json"}

CONFIGURE_SENTINEL="false"
CONFIGURE_NETWORK_ZONE="false"

if [ -r ${SENTINEL_CONFIG_PATH} ]; then
	CONFIGURE_SENTINEL=true	
fi

if [ -r ${NETWORK_ZONES_CONFIG_PATH} ]; then
	CONFIGURE_NETWORK_ZONE=true
fi

if [ "$CONFIGURE_SENTINEL" = "true" ] || [ "$CONFIGURE_NETWORK_ZONE" = "true" ]; then

	# Wait for the admin ui to start
        wget --retry-connrefused --waitretry=2 --read-timeout=20 --timeout=15 -t 60 --no-check-certificate https://${ADMIN_CREDENTIAL}${ADMIN_UI_URI}
else
	echo "Missing Sentinel and Network Zone JSON files - skipping configuration!"
	exit 1
fi

check_if_backend
backend=$?

if [ ${backend} == 1 ]; then

	if [ "$CONFIGURE_SENTINEL" = "true" ]; then
  		echo "#############################################"
		echo "###### Configuring Sentinel...... ###########"
  		curl -X POST -k -1 -H "Content-Type: application/json" -d@${SENTINEL_CONFIG_PATH} https://${ADMIN_CREDENTIAL}${ADMIN_UI_URI}/api/v1.4/sentinel
  		echo "###### Configuring Sentinel Done ############"
	fi

	if [ "$CONFIGURE_NETWORK_ZONE" = "true" ]; then
		echo "########################################################"
                echo "###### Configuring Network Zones on Backend...... ######"
		curl -X POST -k -1 -H "Content-Type: application/json" -d@${NETWORK_ZONES_CONFIG_PATH} https://${ADMIN_CREDENTIAL}${ADMIN_UI_URI}/api/v1.4/zones
		echo "###### Configuring Network Zones Done ##################"
	fi
else 

	if [ "$CONFIGURE_NETWORK_ZONE" = "true" ]; then
                echo "#############################################################"
                echo "###### Configuring Private Network Zone on EDGE ...... ######"
                curl -X POST -k -1 -H "Content-Type: application/json" -d@${NETWORK_ZONES_CONFIG_PATH} https://${ADMIN_CREDENTIAL}${ADMIN_UI_URI}/api/v1.4/zones/Private
                echo "###### Configuring Network Zones Done #######################"
        fi
fi
