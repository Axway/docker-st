#!/bin/bash
set -e

if [[ $# -eq 0 ]] || [ $# -ne 1 ];then
   echo "No arguments supplied or more than one argument specified!!! Exiting!"
   exit 1
fi

if [[ -n "$ST_CORE_LICENSE" ]];then
   echo "$($ST_CORE_LICENSE)" > ./conf/filedrive.license
fi

if [[ -n "$ST_FEATURE_LICENSE" ]];then
   echo "$($ST_FEATURE_LICENSE)" > ./conf/st.license
fi

if [[ "$1" = 'sleep' ]]; then
   exec tail -f /dev/null
else
   # Overlay2 workaround for Mysql: https://github.com/docker/for-linux/issues/72
   find $ST_HOME/var/db/mysql/ -type f -exec touch {} \;
   exec $ST_HOME/bin/start_$1 -trap
fi
