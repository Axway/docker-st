#!/bin/sh
#

echo "$($ST_CORE_LICENSE)" > ./conf/filedrive.license
echo "$($ST_FEATURE_LICENSE)" > ./conf/st.license
./bin/start_db
./bin/start_admin

while true; do
  sleep 30
done

