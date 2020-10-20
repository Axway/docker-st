#!/bin/bash
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Copyright (c) 2019 Axway Software SA and its affiliates. All rights reserved.
#
set -e

if [[ $# -eq 0 ]] || [ $# -ne 1 ];then
   echo "No arguments supplied or more than one argument specified!!! Exiting!"
   exit 1
fi

if [[ -n "$ST_CORE_LICENSE" ]];then
   tr -d '\r' < "$ST_CORE_LICENSE" > $ST_HOME/conf/st.license
fi

if [[ -n "$ST_FEATURE_LICENSE" ]];then
   tr -d '\r' < "$ST_FEATURE_LICENSE" > $ST_HOME/conf/filedrive.license
fi

if [[ "$1" = 'sleep' ]]; then
   exec tail -f /dev/null
else
   $ST_HOME/bin/start_post_install.sh $ST_HOME/docker/conf
   exec $ST_HOME/bin/start_$1 -trap
fi