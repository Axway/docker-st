#!/bin/sh
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Copyright (c) 2019 Axway Software SA and its affiliates. All rights reserved.
#
# admin-log4j.xml
# NOTE: Assumes ST_HOME env variable is set

for i in admin-log4j.xml httpd-log4j.xml ftpd-log4j.xml sshd-log4j.xml as2d-log4j.xml pesitd-log4j.xml socks-log4j.xml tools-log4j.xml; do

   LOG4J_FILE=$ST_HOME/conf/$i
   if [[ -f $LOG4J_FILE ]];then
        echo "Uncommenting appenders for file: $LOG4J_FILE ..."
        
        perl -i -pe 'if (/<!--/) { $_ .= <> while !/-->/; s[<!--(<AppenderRef ref="console" />)-->][$1];}' "$LOG4J_FILE"
        perl -i -pe 'if (/<!--/) { $_ .= <> while !/-->/; s[<!--(<AppenderRef ref="Stdout" />)-->][$1];}' "$LOG4J_FILE"
        perl -i -pe 'if (/<!--/) { $_ .= <> while !/-->/; s[<!--(<AppenderRef ref="Stderr" />)-->][$1];}' "$LOG4J_FILE"
        perl -i -pe 'if (/<!--/) { $_ .= <> while !/-->/; s[<!--(<AppenderRef ref="RoutingStdout" />)-->][$1];}' "$LOG4J_FILE"
        perl -i -pe 'if (/<!--/) { $_ .= <> while !/-->/; s[<!--(<AppenderRef ref="RoutingStderr" />)-->][$1];}' "$LOG4J_FILE"
        echo "Commenting ServerLog and AuditLog appenders for file: $LOG4J_FILE ..."
        perl -i -pe 's/(<AppenderRef ref="ServerLog".*?\/>)/<!-- $1 -->/g' "$LOG4J_FILE"
        perl -i -pe 's/(<AppenderRef ref="AuditLogAppender".*?\/>)/<!-- $1 -->/g' "$LOG4J_FILE"
        echo "Finished"
   fi

done

exit 0