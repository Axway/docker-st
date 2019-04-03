#!/bin/sh

# Variables
#
# NEED TO SET these as environment variables for the container,
# otherwise the defaults will kick in.
ADMIN_UI_URI=${ST_ADMIN_UI_URI:-st-backend:444}
HOST=${ST_HOST:-st-backend}
ADMIN_CREDENTIAL=admin:admin@
PRIVATE_KEY_PATH=id_rsa
PUBLIC_KEY_PATH="file-data=@id_rsa.pub;type=application/octet-stream"
CERT_JSON_MUT_PATH="meta-data=@certJsonMUT.json;type=application/json"
CERT_JSON_PM_PATH="meta-data=@certJsonPM.json;type=application/json"
SSH_SERVICE_PORT=${ST_SSH_SERVICE_PORT:-22}

# Initial CURL that waits for the admin ui
curl  -kvvv  --connect-timeout 5 --max-time 10 --retry 50 --retry-delay 10 --retry-max-time 120  --retry-connrefused 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}''

# Create user account on PM
echo --------------------------
echo 'Create user on PM'
echo --------------------------

curl -kvvv -X PUT -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"name" : "source1","homeFolder" : "/home.local/vusers/source1","uid" : "1001","gid" : "2001","disabled" : false,"type" : "user","unlicensed" : false,"deliveryMethod" : "Default","enrollmentTypes" : [ ],"encryptMode" : "unspecified","routingMode" : "reject","wapAppletEnabled" : false}' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/accounts/source1?idp_id=ST_IDP'

curl -kvvv -X PUT -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"name" : "source1","authExternal" : false,"lastLogin" : null,"locked" : false,"failedAuthAttempts" : null,"failedAuthMaximum" : null,"successfulAuthMaximum" : null,"successfulLogins" : 0,"lastFailedAuth" : null,"passwordCredentials" : {"username" : "source1","password" : "source","passwordDigest" : null,"forcePasswordChange" : null,"lastPasswordChange" : null,"passwordExpiryInterval" : null},"metadata" : null,"secretQuestion" : null}' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/accounts/source1/users/source1?idp_id=ST_IDP'

# Create account on MUT
echo --------------------------
echo 'Create user on MUT'
echo --------------------------

curl -kvvv -X PUT -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"name" : "target1","homeFolder" : "/home.local/vusers/target1","uid" : "1002","gid" : "2002","disabled" : false,"type" : "user","unlicensed" : false,"deliveryMethod" : "Default","enrollmentTypes" : [ ],"encryptMode" : "unspecified","routingMode" : "reject","wapAppletEnabled" : false}' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/accounts/target1?idp_id=ST_IDP'

curl -kvvv -X PUT -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"name" : "target1","authExternal" : false,"lastLogin" : null,"locked" : false,"failedAuthAttempts" : null,"failedAuthMaximum" : null,"successfulAuthMaximum" : null,"successfulLogins" : 0,"lastFailedAuth" : null,"passwordCredentials" : {"username" : "target1","password" : "target","passwordDigest" : null,"forcePasswordChange" : null,"lastPasswordChange" : null,"passwordExpiryInterval" : null},"metadata" : null,"secretQuestion" : null}' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/accounts/target1/users/target1?idp_id=ST_IDP'

# Create advanced routing application
echo ----------------------------------------
echo 'Create advanced routing application'
echo ----------------------------------------

curl -kvvv -X PUT -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"name" : "advanced_routing1","type" : "AdvancedRouting","notes" : ""}' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/applications/advanced_routing1?idp_id=ST_IDP'

# Create transfer site
echo ----------------------------------
echo 'Create ssh trnsfer site on MUT'
echo ----------------------------------

curl -kvvv -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"sites" : [ {"name" : "ssh","account" : "target1","protocol" : "ssh","transfer.mode" : "I","port" : "'${SSH_SERVICE_PORT}'","upload.folder" : "/","username" : "source1","dmz" : "none","host" : "'${HOST}'","download.pattern" : "*","download.folder" : "/","usePassword" : "true","password" : "source"} ]}' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/sites?idp_id=ST_IDP'

# Create subscription
echo --------------------------
echo 'Create subscription'
echo --------------------------

curl -kvvv -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"subscriptions" : [ {"folder" : "/subscriptionFolder","account" : "target1","application" : "advanced_routing1"} ]}' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/subscriptions?idp_id=ST_IDP'

# Get subscription id- return json data 
SUBSCRIPTION_ID="$(curl -kvvv -X GET -H 'Accept: application/json' -H 'Content-Type: application/json' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/subscriptions?application=advanced_routing1&idp_id=ST_IDP&account=target1'| grep id | cut -d ':' -f 2 | tr -d '"' | tr -d ',' | tr -d ' ')" 
echo ${SUBSCRIPTION_ID}

# Create transfer configuration
echo ----------------------------------
echo 'Create transfer configuration'
echo ----------------------------------

curl -kvvv -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"transferConfigurations" : [ {"tag" : "PARTNER-IN","direction" : 0,"dataTransformations" : [ ]} ]}' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/subscriptions/'${SUBSCRIPTION_ID}'/transferConfigurations?application=advanced_routing1&idp_id=ST_IDP&account=target1'

# Create route template
echo ----------------------------------
echo 'Create route tamplate'
echo ----------------------------------

curl -kvvv -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"name" : "template1","type" : "TEMPLATE","conditionType" : "MATCH_ALL","failureEmailNotification" : false,"successEmailNotification" : false,"triggeringEmailNotification" : false,"steps" : [ ],"businessUnits" : [ ]}' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/routes?idp_id=ST_IDP'

# Get route template id
ROUTE_TEMPLATE_ID="$(curl -kvvv -X GET -H 'Accept: application/json' -H 'Content-Type: application/json' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/routes?offset=0&name=template1'| grep id | cut -d ':' -f 2 | tr -d '"' | tr -d ',' | tr -d ' ')"
echo ${ROUTE_TEMPLATE_ID}

# Create composite route 
echo ----------------------------------
echo 'Create composite route'
echo ----------------------------------
curl -kvvv -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"name" : "composite1","type" : "COMPOSITE","routeTemplate" : "'${ROUTE_TEMPLATE_ID}'","account" : "target1","conditionType" : "MATCH_ALL","failureEmailNotification" : false,"successEmailNotification" : false,"triggeringEmailNotification" : false,"steps" : [ ],"businessUnits" : [ ],"subscriptions" : [ "'${SUBSCRIPTION_ID}'" ]}' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/routes?idp_id=ST_IDP'

# Create Simple route
echo ----------------------------------
echo 'Create simple route'
echo ----------------------------------

curl -kvvv -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"name" : "simple1","type" : "SIMPLE","conditionType" : "ALWAYS","failureEmailNotification" : false,"successEmailNotification" : false,"triggeringEmailNotification" : false,"steps" : [ ],"businessUnits" : [ ]}' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/routes?idp_id=ST_IDP'

# Get simple route id
SIMPLE_ROUTE_ID="$(curl -kvvv -X GET -H 'Accept: application/json' -H 'Content-Type: application/json' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/routes?offset=0&name=simple1'| grep id | cut -d ':' -f 2 | tr -d '"' | tr -d ',' | tr -d ' ')"
echo ${SIMPLE_ROUTE_ID}

# Create send to partner steps
echo ----------------------------------
echo 'Create send to partner steps'
echo ----------------------------------

curl -kvvv -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"type" : "SendToPartner","status" : "ENABLED","autostart" : false,"targetAccountExpressionType" : "NAME","sleepBetweenRetries" : "1000","maxNumberOfRetries" : "0","fileFilterExpression" : "*","actionOnStepFailure" : "PROCEED","transferSiteExpressionType" : "LIST","transferSiteExpression" : "ssh#!#CVD#!#","fileFilterExpressionType" : "GLOB","targetAccountExpression" : "target1"}' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/routes/'${SIMPLE_ROUTE_ID}'/steps?idp_id=ST_IDP'

# Create execute route steps
echo ----------------------------------
echo 'Create execute route steps'
echo ----------------------------------

curl -kvvv -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"type" : "ExecuteRoute","status" : "ENABLED","autostart" : false,"executeRoute" : "'${SIMPLE_ROUTE_ID}'"}' 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/routes/'${ROUTE_TEMPLATE_ID}'/steps?idp_id=ST_IDP'

# Import login certificate
echo ----------------------------------
echo 'Import login certificate'
echo ----------------------------------

echo ----------------------------------
echo 'Import login certificate on MUT'
echo ----------------------------------

curl -kvvv -X POST -H 'Accept: application/json' -H 'Content-Type: multipart/mixed' -F ${CERT_JSON_MUT_PATH} -F ${PUBLIC_KEY_PATH} 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/certificates/import?idp_id=ST_IDP'

echo ----------------------------------
echo 'Import login certificate on PM'
echo ----------------------------------

curl -kvvv -X POST -H 'Accept: application/json' -H 'Content-Type: multipart/mixed' -F ${CERT_JSON_PM_PATH} -F ${PUBLIC_KEY_PATH} 'https://'${ADMIN_CREDENTIAL}''${ADMIN_UI_URI}'/api/v1.4/certificates/import?idp_id=ST_IDP'

echo ----------------------------------
echo 'Create file'
echo ----------------------------------
SOURCE_FILE_NAME="testFile.tmp"
TARGET_FILE_NAME="testFileDownloaded.tmp"
rm ${SOURCE_FILE_NAME} ${TARGET_FILE_NAME}
cp /etc/passwd ${SOURCE_FILE_NAME}

# Upload file
echo ----------------------------------
echo 'Upload file'
echo ----------------------------------

UPLOAD_RETRIES=10

while [ $UPLOAD_RETRIES != 0 ];do

/usr/bin/expect <<EOD
spawn scp -oStrictHostKeyChecking=no -P $SSH_SERVICE_PORT  ${SOURCE_FILE_NAME} target1@${HOST}:/subscriptionFolder/${SOURCE_FILE_NAME}
set timeout 40
expect "Password:"
send "target\n"
expect eof
catch wait reason
exit [lindex \$reason 3]
EOD
STATUS=$?
echo "=== Upload Status: $STATUS ============"
 if [ $STATUS != 0 ];then
    UPLOAD_RETRIES=$((UPLOAD_RETRIES-1))
    echo "Retrying....[$UPLOAD_RETRIES]"
    sleep 5
 else
    break
 fi
done

if [ $STATUS != 0 ];then
   echo "Could not upload file....Exiting"
   exit 1
fi

# Download the Routed file
echo ----------------------------------
echo 'Download file'
echo ----------------------------------

DOWNLOAD_RETRIES=10

while [ $DOWNLOAD_RETRIES != 0 ];do

/usr/bin/expect <<EOD
set timeout 40
spawn scp -oStrictHostKeyChecking=no -P $SSH_SERVICE_PORT source1@${HOST}:/${SOURCE_FILE_NAME} ${TARGET_FILE_NAME}
expect "Password:"
send "source\n"
expect eof
catch wait result
exit [lindex \$result 3]
EOD
STATUS=$?
echo "=== Download Status: $STATUS ============"
  if [ $STATUS != 0 ];then
     DOWNLOAD_RETRIES=$((DOWNLOAD_RETRIES-1))
     echo "Retrying....[$DOWNLOAD_RETRIES]"
     sleep 5
  else
     if [ -s ${TARGET_FILE_NAME} ];then
        break
     else
        echo "Downloaded file is 0 bytes...Retrying [$DOWNLOAD_RETRIES]"
     fi
  fi
done

# Compare the two files
cmp -s ${SOURCE_FILE_NAME} ${TARGET_FILE_NAME}
CMP_STATUS=$?

if [ ${CMP_STATUS} = 0 ]
then
	echo ----------------------------------
	echo "PASSED"
	echo ----------------------------------
	exit 0
else
	echo ----------------------------------
	echo "FAILED"
	echo ----------------------------------
	exit $CMP_STATUS
fi
