#### Secure Transport

#### Prerequisites

- Docker version >= 19.X
- Kubernetes >= 1.9 or Docker-compose version >= 1.17.0

#### Basic parameters are configurable through environment variables and files

# Secret file generation

Secret file must be generated and supplied to the ST container. The database password used later must also be encypted. In order to do so, the following steps must be executed on machine where the ST image is present and Docker runtime is installed:
1. mkdir /tmp/secret_folder
2. chmod 777 /tmp/secret_folder
2. touch /tmp/secret_folder/pass
3. Еdit the /tmp/secret_folder/pass file to contain the Database password.
4. Execute the following command - docker run --rm --entrypoint '' -v /tmp/secret_folder/:/tmp/secret_folder <st-image> /bin/bash -c '$ST_HOME/bin/createTaehFile /tmp/secret_folder ; cp /tmp/secret_folder/taeh $ST_HOME/bin/taeh ; $ST_HOME/bin/utils/aesenc "$(< /tmp/secret_folder/pass)" > /tmp/secret_folder/encpass' 
5. Store the taeh file and the value of the encrypted database password for later usage.

The generated taeh is passed on startup of the container. The file must be present in the mounted directory in **ST_CONTAINER_CONFIG_PATH**.

# Database configuration

Database configuration is performed via a file which is passed on startup of the container. The file must be present in the mounted directory in ST_CONTAINER_CONFIG_PATH.

An example is available here [db.conf .](backend/runtime/secrets/db.conf).

db.type= < Database Type: oracle, mssql or mysql >
db.host= < The FQDN or IP address of the Database system or cluster >
db.port= < The number of the port used to access the server or cluster >
db.user= < The name of the user authorized to create the SecureTransport schema and populate it >
db.password= < The password for the user > AES128 encrypted
db.name= < Service Name (Oracle) or Database Name (MSSQL/MySQL) >
db.use.secure.connection=true < Whether to use secure connection or not; when not specified, it's 'false' by default. If set to true, db.certificate.name and db.certificate.path must be set>
db.certificate.name= < Server certificate DN value. If provided, the value will be matched against the certificate provided by the database server: for Oracle - DN of the certificate; for MSSQL - Server name; for MySQL - Certificate name>
db.certificate.path= < PEM or DER file, containing the trusted certificates needed to establish a chain of trust >

# JVM Parameters for ST services using STStartScriptsConfig

The JVM MIN/MAX memory paramteres for each service are configurable via file that is supplied to ST using docker/Kubernetes secrets and environment variable **ST_START_SCRIPTS_CONF_PATH** containing the path to the file.

The format of the file [STStartScriptsConfig](backend/runtime/secrets/STStartScriptsConfig) is very simple:
{SERVICE}_JAVA_MEM_MIN
{SERVICE}_JAVA_MEM_MAX
{SERVICE}_JAVA_OPTS="<OPTIONS> ${JAVA_OPTS}"
Note: SOCKS service is present only on ST edges. TM service is present only on ST servers.
```
# Start scripts configuration should be specified here in the following format:
# [PROTPCOL_NAME]_[OPTION_NAME]=[value]

SSH_JAVA_MEM_MIN=256M
SSH_JAVA_MEM_MAX=512M
HTTP_JAVA_MEM_MIN=256M
HTTP_JAVA_MEM_MAX=512M
FTP_JAVA_MEM_MIN=256M
FTP_JAVA_MEM_MAX=512M
AS2_JAVA_MEM_MIN=256M
AS2_JAVA_MEM_MAX=512M
ADMIN_JAVA_MEM_MIN=256M
ADMIN_JAVA_MEM_MAX=512M
TM_JAVA_MEM_MIN=256M
TM_JAVA_MEM_MAX=512M
PESIT_JAVA_MEM_MIN=256M
PESIT_JAVA_MEM_MAX=512M
STATUSCHECKER_JAVA_MEM_MIN=256M
STATUSCHECKER_JAVA_MEM_MAX=384M
SOCKS_JAVA_MEM_MIN=256M
SOCKS_JAVA_MEM_MAX=512M

TM_JAVA_OPTS="-DStreaming.numberOfConnections=20 ${JAVA_OPTS}"
```

#### Performance tuning

Using configuration files performance tuning can be applied to the following files - configuration.xml options, hibernate-cache-config.xml, scheduler.properties, coherence-cache-config-tm.xml
The hibernate-cache-config.xml, scheduler.properties, coherence-cache-config-tm.xml are replaced on container start overwriting the default files, if they are present in the **ST_CONTAINER_CONFIG_PATH** mounted secret volume. 
Note: On ST edges only the hibernate-cache-config.xml is applicable and will be used.

Before modifing the files you must obtain them from the docker image using the following command: 
1. mkdir /tmp/secret_folder
2. chmod 777 /tmp/secret_folder
3. docker run --rm --entrypoint '' -v /tmp/secret_folder/:/tmp/secret_folder <st-image> /bin/bash -c 'cp $ST_HOME/conf/hibernate-cache-config.xml /tmp/secret_folder ; cp $ST_HOME/conf/scheduler.properties /tmp/secret_folder ; cp $ST_HOME/conf/coherence-cache-config-tm.xml /tmp/secret_folder'

In order to perform changes to the configuration.xml options a file named [database_configuration_components.xml](backend/runtime/secrets/database_configuration_components.xml) must be present in the **ST_CONTAINER_CONFIG_PATH**.
The options are supplied in key-value pair. If an option doesn't exist it will be added to the list of options of the specified component, if it is present, it's value will be changed.
Valid components are: "Database", "Admin", "AS2", "SSHD", "FTPD", "HTTPD", "Tools", "Installer", "Pesit", "TransactionManager", "TransferLog", "ServerLog"

#### The application should log everything to stdout/stderr

For the purposes of the ST - Docker integration most of the Server Log data has been exposed on STDOUT/STDERR and this is enabled by default when the image is built. Behind the scenes each **-log4j.xml gets additional appenders (Stdout/Stderr) that are commented by default but are enabled duirng the docker image build process.

The application logs on ST server and ST edge are redirected to the stdout/stderr. 
On ST servers the logs are also stored in the database.
On ST edges the logs will be redirected only to the stdout/stderr

#### Kubernetes readiness and liveness checks

Liveness and readiness checks are implemented in order monitor the status and health of the ST services in Kubernetes.
Container is considered ready when:
- For ST servers, the container is considered ready when the admin service is started.
- For ST edges, the container is considered ready when all enabled services have started their streaming server.

Container is considered healthy/live when:
- The container is considered live when all the enabled services have streaming connections established with the ST server. If any of the enabled services has no streaming connections or the Transaction Manager of ST servers is not running the pod is considered unhealty and it is restarted.

The scripts are executed by Kubernetes on configurable schedule setup in st-server-kubernetes.yml and st-edge-kubernetes.yml.
In order to perform the initial configuration and configure streaming, the liveness check should be commented, so that the containers are not restarted.

Note: On ST edges it is mandatory for the admin streaming to be established and SOCKS proxy to be running.

#### Graceful shutdown of ST services

Graceful shutdown of protocol daemons is supported for ST edges, when scaling down or stopping a container. All the currently running transfers will be finished before the edge container is terminated. In order to configure the timeout before the container is killed forcefully the following options can be set in docker **stop_grace_period: Xm** Kubernetes: terminationGracePeriodSeconds: X (seconds).

Note during the graceful shutdown of edge container, the number of containers cannot be increased in Kubernetes.

#### Starting SecureTransport with Kubernetes

0) Obtain the ST docker images and import them in docker or build your own
   0.1 Import - `docker load -i ST_Backend_5.5_Docker_Image_linux-x86-64_<build number>.tar.gz` `docker load -i ST_Edge_5.5_Docker_Image_linux-x86-64_<build number>.tar.gz`
   0.2 Build - `docker build --no-cache --build-arg INSTALL_KIT=<st-installation.zip> -t <image-tag> .`

1) Prepare the External databases for ST Server (MSSQL or Oracle) and ST edge - MySQL, Create users and databases
   1.1 For MySQL in docker example is provided in example-configuration/MySQL/ Note: The database must be in the same Kubernetes namespace
   1.2 Create secret containing the my.conf file `kubectl create secret generic mysql-config -n <st-namespace> --from-file=./my.cnf`
   1.3 Generate certificates for the MySQL database if SSL connection will be used.
   1.4 Create secret for the certificates if SSL connection will be established with the database `kubectl create secret generic mysql-secret-certificates -n <st-namespace> --from-file=ca-key.pem --from-file=ca.pem --from-file=client-cert.pem --from-file=client-key.pem --from-file=server-cert.pem --from-file=server-key.pem`
   1.5 Deploy the database using the following command `kubectl create -f mysql.yaml`

2) Configure the HaProxy from example-configuration/HaProxy:
   2.1 Fill the needed data in example-configuration/HaProxy/haproxy.cfg
   2.2 Fill the needed data in example-configuration/HaProxy/haproxy.yaml
   2.3 Create secret containing the haproxy.cfg file `kubectl create secret generic <name-described-in-haproxy.yaml> -n <st-namespace> --from-file=./haproxy.cfg` for each HaProxy
   2.4 Deploy the HaProxy in Kubernetes `kubectl create -f haproxy.yaml` (from the folder where haproxy.yaml file is located)
   2.5 Install HaProxy on any linux machine.
   2.6 Fill the needed data in example-configuration/HaProxy/onPremises/haproxy.cfg and put it in /etc/haproxy/
   2.7 Start the HaProxy.
   Note: If the on premises HaProxy is not installed sticky sessions will not be usable and all the client connections will be redirected to only one server/edge.

3) Prepare the configuration files for ST server and ST edge found in example-configuration:
   3.1 Prepare secret file and encrypted password for the database (Section Secret file generation above).
   3.2 Prepare the copy of the taeh file and upload it in runtime/secrets.
   3.3 Prepare db.conf file for both ST server and ST edge using the encrypted database password from step 1.1 and all the database info (Section Database configuration).
   3.4 If ssl connection to the database is used the certificate file should be supplied in the Kubernetes secret in step 1.8 - add at the end of the command - `--from-file=./<certificate>`
   3.6 Optional - prepare STStartScriptsConfig file. (Section JVM Parameters for ST services using STStartScriptsConfig) if used should be supplied in the Kubernetes secret in step 1.8 - add at the end of the command `--from-file=./STStartScriptsConfig`
   3.7 Prepare ST feature and core licenses as per your database.
   3.8 Create Kubernetes secret with the needed files (do not include STStartScriptsConfig if not used) - st-server-secret - `kubectl create secret generic st-server-secret/st-edge-secret -n <st-namespace> --from-file=./taeh --from-file=./db.conf --from-file=./st.license --from-file=filedrive.license` (command should be executed where the files are located eg. runtime/secrets). If performance tunning is applied, the above mentioned files should be also added to the command (`--from-file=./database_configuration_components.xml --from-file=./hibernate-cache-config.xml --from-file=./scheduler.properties --from-file=./coherence-cache-config-tm.xml`)
   3.9 Fill the needed data in st-server-kubernetes.yml and st-edge-kubernetes.yml. (remove environement variables for STStartScriptsConfig if not used)
   3.10 Deploy the ST server - `kubectl create -f st-server-kubernetes.yml` (from the folder where st-server-kubernetes.yml file is located)
   3.11 Verify container is started - `kubectl get pods -n <st-namespace>`
   3.12 After successful start, Login into the administraton tool Configure network zone for the Edge
   3.13 Deploy the ST edge - `kubectl create -f st-edge-kubernetes.yml` (from the folder where st-edge-kubernetes.yml file is located)
   3.14 Verify container is started - `kubectl get pods -n <st-namespace>`

#### Scaling Secure Transport in Kubernetes

   You can change the number of deployed containers for Secure Transport Server or Edge both manually or automatically by the following commands:
      Manually: `kubectl scale statefulset <statefulset-name> -n <st-namespace> --replicas=X` (where X is the number of containers desired).
      Automatically: `kubectl autoscale statefulset <statefulset-name> -n <st-namespace> --cpu-percent=X --min=Y --max=Z` (X is the CPU percentage load. Recommended value 70. Y minimum containers. Recommended value 2. Z max containers. Recomended value 4.)

#### Stopping SecureTransport with Kubernetes

Stop the containers using the following command (from the folder where st-server-kubernetes.yml or st-edge-kubernetes.yml file is located)
   `kubectl delete -f st-server-kubernetes.yml`
   `kubectl delete -f st-edge-kubernetes.yml`

#### Starting Secure Transport with docker-compose

0) Obtain the ST docker images and import them in docker or build your own
   0.1 Import - `docker load -i ST_Backend_5.5_Docker_Image_linux-x86-64_<build number>.tar.gz` `docker load -i ST_Edge_5.5_Docker_Image_linux-x86-64_<build number>.tar.gz`
   0.2 Build - `docker-compose build`
   
1) To start Secure Transport, run 

   `docker-compose up`

2) Login to Secure Transport using on [https://localhost:9444](https://localhost:9444) with the following credentials

   - ID: `admin`
   - Password: `admin` 

#### Stopping Secure Transport with docker-compose

Stop the containers using the following command (from the folder where docker-compose.yml file is located)

   `docker-compose down -v`

#### Environemnt Variable Parameters
_________________________________________________________________________________________________________________________________________________________________________________________________
|          Parameter         |                                                                              Description                                                                          |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ST_CORE_LICENSE            | The contents of the ST Core license                                                                                                                               |
| ST_FEATURE_LICENSE         | The contents of the ST Feature license                                                                                                                            |
| ST_CONTAINER_CONFIG_PATH   | The location of the ST configuration files directory. Mandatory files are - taeh file, db.conf, st.license and filedrive.license                                  |
| ST_START_SCRIPTS_CONF_PATH | The location inside the contaioner of the file that specifies the JVM settings for the running services if set the file must be present on the specified location |
|____________________________|___________________________________________________________________________________________________________________________________________________________________|

#### Copyright

Copyright (c) 2019 Axway Software SA and its affiliates. All rights reserved.

#### License

All files in this repository are licensed by Axway Software SA and its affiliates under the Apache License, Version 2.0, available at http://www.apache.org/licenses/.
