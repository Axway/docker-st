
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Copyright (c) 2019 Axway Software SA and its affiliates. All rights reserved.
#
# admin-log4j.xml
# NOTE: Assumes ST_HOME env variable is set

for i in admin-log4j.xml httpd-log4j.xml ftpd-log4j.xml sshd-log4j.xml as2d-log4j.xml pesitd-log4j.xml tm-log4j.xml tools-log4j.xml; do

   LOG4J_FILE=$ST_HOME/conf/$i
   if [[ -f $LOG4J_FILE ]];then
      echo "Uncommenting appenders for file: $LOG4J_FILE ..."
      
      sed -i 's/<!--<AppenderRef ref="console"\/>-->/<AppenderRef ref="console"\/>/g' $LOG4J_FILE
      sed -i 's/<!--<AppenderRef ref="Stdout" \/>-->/<AppenderRef ref="Stdout" \/>/g' $LOG4J_FILE
      sed -i 's/<!--<AppenderRef ref="Stderr" \/>-->/<AppenderRef ref="Stderr" \/>/g' $LOG4J_FILE
      sed -i 's/<!--<AppenderRef ref="RoutingStdout" \/>-->/<AppenderRef ref="RoutingStdout" \/>/g' $LOG4J_FILE
      sed -i 's/<!--<AppenderRef ref="RoutingStderr" \/>-->/<AppenderRef ref="RoutingStderr" \/>/g' $LOG4J_FILE
      echo "Finished"
   fi

done

exit 0