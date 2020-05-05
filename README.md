# Secure Transport

## Prerequisites

- Docker version >= 17.11
- Docker-compose version >= 1.17.0

#### Basic parameters are configurable through environment variables and files

Most of the ST's Server Configuration, related to the various services, has been exposed and can be changed via a file. You can specify which services must be started when the container starts, which port(s) to listen to, the certificate alias, cipher suites, etc. In order to supply the file to ST one needs to create a docker secret and set **ST_GLOBAL_CONFIG_PATH** environment variable to specify it's location inside the container.

An example is available here [STGlobalConfig.properties .](backend/runtime/secrets/STGlobalConfig.properties or edge/runtime/secrets/STGlobalConfig.properties)

```
Ssh.Enable=true
Ssh.Sftp.enable=true
Ssh.Scp.enable=true

#Ssh.Ciphers=aes256-cbc
Ssh.Fips.enable=false
Ssh.Key.Alias=admind
Ssh.Port=22
```

The above example enables the SSH service, enabled both SCP and SFTP, specifies that the certificate alias that must be used by the SSH service is called **admind** and that FIPS Mode is disabled.

By default there is only one Local Certificate available in ST Certificate store that is created during image creation with alias **admind**. In order to import a new custom certificate (with it's Root CA) the following Environment Variables can be used:

```
ST_CA_PATH: /run/secrets/st-root-ca.crt
ST_CA_ALIAS: docker_ca
ST_CERT_PATH: /run/secrets/st-be-services-crt.p12
ST_CERT_PASS: SECRET123
ST_CERT_ALIAS: admind
```

As with the basic configuration file, the certificates must be supplied using a docker secret via the docker-compose file ([example is located here.](docker-compose.yml)). Note that you can import only one Root CA and one local certificate.

#### JVM Parameters for ST services are configurable

The JVM MIN/MAX memory paramteres for each service are configurable via file that is supplied to ST using docker secrets and environment variable (see docker-compose.yml above).

The format of the file ([STStartScriptsConfig](backend/runtime/secrets/STStartScriptsConfig) (edge/runtime/secrets/STStartScriptsConfig)) is very simple:
{SERVICE}_JAVA_MEM_MIN
{SERVICE}_JAVA_MEM_MAX
{SERVICE}_JAVA_OPTS="<OPTIONS> ${JAVA_OPTS}"
Note: SOCKS service is present only on ST edges.
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
```

#### The application should log everything to stdout/stderr

By default ST keeps its Server Log inside the external database for Servers. On ST edges the logs will be redirected only on to the stdout/stderr

However for the purposes of the ST - Docker integration most of the Server Log data has been also exposed on STDOUT/STDERR and this is enabled by default when the image is built. Behind the scenes each **-log4j.xml gets additional appenders (Stdout/Stderr) that are commented by default but are enabled duirng the docker image build process.

#### Fast stop: In order to be gracefully stopped, a container has 10 seconds (by default) to exit (SIGTERM)

Becasue ST is a monolithic application one can start multiple services at the same time (SSH, PESIT and AS2 for example). It is hard to stop all of that gracefully under 10 seconds. However the improvement in this version is that the **SecureTransport/bin/start_all** script has been modifed and can now be executed in "trap" mode which means that after all enabled services are started the scripts stays in foreground (not allowing docker to kill the container) and when SIGTERM is received all enabled services are stopped using their respective **stop_XX** script. Since the process takes longer than 10 seconds the example docker-compose.yml file has the **stop_grace_period: 2m** setting to give it enough time (the setting can be tuned of course)

#### Starting Secure Transport

0) To build the image separatelly use

   `docker-compose build`
   
1) To start Secure Transport, run 

   `docker-compose up`

2) Login to Secure Transport using on [https://localhost:9444](https://localhost:9444) with the following credentials

   - ID: `admin`
   - Password: `admin` 

#### Stopping Secure Transport

Stop the containers using the following command (from the folder where docker-compose.yml file is located)

   `docker-compose down -v`

#### Environemnt Variable Parameters

|          Parameter         |                                                                              Description                                                                         |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ST_CORE_LICENSE            | The contents of the ST Core license (usually `cat /run/secrets/st-core-license`)                                                                                 |
| ST_FEATURE_LICENSE         | The contents of the ST Feature license (usually `cat /run/secrets/st-feature-license`)                                                                           |
| ST_CONTAINER_CONFIG_PATH   | The location of the ST configuration files directory. Mandatory files are - taeh file, db.conf, st.license and filedrive.license                                 |
| ST_GLOBAL_CONFIG_PATH      | The location of the ST Configuration file (to enable/disable/configure ST services) if set the file must be present on the specified location                    |
| ST_START_SCRIPTS_CONF_PATH | The location inside the contaioner of the file that specifies the JVM settings for the running services if set the file must be present on the specified location|

## Copyright

Copyright (c) 2019 Axway Software SA and its affiliates. All rights reserved.

## License

All files in this repository are licensed by Axway Software SA and its affiliates under the Apache License, Version 2.0, available at http://www.apache.org/licenses/.
