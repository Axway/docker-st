# Itroduction

The repository contains the Docker files and configuration files needed for SecureTransport docker images to be built and deployed in docker-compose/Kubernetes.\

#### Contents

The structure of the repository is:\
SecureTransport Server files:\
  [server](server)/\
    [Dockerfile](server/Dockerfile) - The Dockerfile of the SecureTransport Server\
    [docker-compose.yml](server/docker-compose.yml) - The docker-compose file for deployment of SecureTransport Server docker image\
    [build](server/build)/\
      [scripts](server/build/scripts)/ - The needed scripts in order to build SecureTransport Server docker image\
        [entrypoint.sh](server/build/scripts/entrypoint.sh) - Script used as entrypoint in the container\
        [logger-util.sh](server/build/scripts/logger-util.sh) - Script used to correct SecureTransport stdout apenders\
      [axway_installer.properties](server/build) - File used for installation\
      [st_install.properties](server/build) - File used for installtion\
    [example-configuration](server/example-configuration)/\
      [HaProxy](server/example-configuration/HaProxy)/\
        [haproxy.cfg](server/example-configuration/HaProxy/haproxy.cfg) - HaProxy configuration file\
        [haproxy.yaml](server/example-configuration/HaProxy/haproxy.yaml) - HaProxy Kubernetes configuration\
      [Kubernetes](server/example-configuration/Kubernetes)/\
        [st-server-kubernetes.yml](server/example-configuration/Kubernetes/st-server-kubernetes.yml) - SecureTransport Server Statefulset and Headless service Kubernetes configuration\
SecureTransport Edge files:\
  [edge](edge)/\
    [Dockerfile](edge/Dockerfile) - The Dockerfile of the SecureTransport Edge\
    [docker-compose.yml](edge/docker-compose.yml) - The docker-compose file for deployment of SecureTransport Edge docker image\
    [build](edge/build)/\
      [scripts](edge/build/scripts)/ - The needed scripts in order to build SecureTransport Server docker image\
        [entrypoint.sh](edge/build/scripts/entrypoint.sh) - Script used as entrypoint in the container\
        [logger-util.sh](edge/build/scripts/logger-util.sh.sh) - Script used to correct SecureTransport stdout apenders\
      [axway_installer.properties](edge/build/axway_installer.properties) - File used for installation\
      [st_install.properties](edge/build/st_install.properties) - File used for installtion\
    [example-configuration](edge/example-configuration)/\
      [HaProxy](edge/example-configuration/HaProxy)/\
        [streaming](edge/example-configuration/HaProxy/streaming)/\
          [haproxy.cfg](edge/example-configuration/HaProxy/streaming/haproxy.cfg) - HaProxy configuration file\
          [haproxy.yaml](edge/example-configuration/HaProxy/streaming/haproxy.yaml) - HaProxy Kubernetes configuration\
        [client](edge/example-configuration/HaProxy)/\
          [haproxy.cfg](edge/example-configuration/HaProxy/client/haproxy.cfg) - HaProxy configuration file\
          [haproxy.yaml](edge/example-configuration/HaProxy/client/haproxy.yaml) - HaProxy Kubernetes configuration\
        [onPremises](edge/example-configuration/HaProxy)/\
          [haproxy.cfg](edge/example-configuration/HaProxy/onPremises/haproxy.cfg) - HaProxy configuration file\
      [Kubernetes](edge/example-configuration/Kubernetes)/\
        [st-edge-kubernetes.yml](edge/example-configuration/Kubernetes/st-edge-kubernetes.yml) - SecureTransport Edge Statefulset and services Kubernetes configuration\
      [MySQL](edge/example-configuration/MySQL)/\
        [my.cnf](edge/example-configuration/MySQL/my.cnf) - The MySQL database configuration\
        [mysql.yaml](edge/example-configuration/MySQL/mysql.yaml) - The MySQL Kubernetes configuration file\

# Deployment procedure

More information on how to build custom images and deploy SecureTransport in docker can be found in [SecureTransport_5.5_Containerized_Deployment_Guide_allOS_en_HTML5](https://linkzaguide-a.com)

#### How to deploy single node MySQL database

   1. For MySQL in docker example is provided in [example-configuration/MySQL/](edge/example-configuration/MySQL) Note: The database must be in the same Kubernetes namespace as SecureTransport
   2. Create secret containing the my.conf file `kubectl create secret generic mysql-config -n <st-namespace> --from-file=./my.cnf`
   3. Generate certificates for the MySQL database if SSL connection will be used.
   4. Create secret for the certificates if SSL connection will be established with the database `kubectl create secret generic mysql-secret-certificates -n <st-namespace> --from-file=ca-key.pem --from-file=ca.pem --from-file=client-cert.pem --from-file=client-key.pem --from-file=server-cert.pem --from-file=server-key.pem`
   5. Deploy the database using the following command `kubectl create -f mysql.yaml`

# Copyright

Copyright (c) 2019 Axway Software SA and its affiliates. All rights reserved.

# License

All files in this repository are licensed by Axway Software SA and its affiliates under the Apache License, Version 2.0, available at http://www.apache.org/licenses/.
