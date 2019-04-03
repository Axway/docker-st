### Secure Transport

#### Prerequisites

- Docker version >= 17.11
- Docker-compose version >= 1.17.0

#### Basic parameters are configurable through environment variables and files

Most of the ST's Server Configuration, related to the various services, has been exposed and can be changed via a file. You can specify which services must be started when the container starts, which port(s) to listen to, the certificate alias, cipher suites, etc. In order to supply the file to ST one needs to create a docker secret and set **ST_GLOBAL_CONFIG_PATH** environment variable to specify it's location inside the container.

An example is available here [STGlobalConfig.properties .](backend/runtime/standalone/STGlobalConfig.properties)

```
Ssh.Enable=true
Ssh.Sftp.enable=true
Ssh.Scp.enable=true

#Ssh.Ciphers=aes256-cbc
Ssh.Fips.enable=false
Ssh.Key.Alias=dockerd
Ssh.Port=22
```

The above example enables the SSH service, enabled both SCP and SFTP, specifies that the certificate alias that must be used by the SSH service is called **dockerd** and that FIPS Mode is disabled.

By default there is only one Local Certificate available in ST Certificate store that is created during image creation with alias **admind**. In order to import a new custom certificate (with it's Root CA) the following Environment Variables can be used:

```
ST_CA_PATH: /run/secrets/st-root-ca.crt
ST_CA_ALIAS: docker_ca
ST_CERT_PATH: /run/secrets/st-be-services-crt.p12
ST_CERT_PASS: SECRET123
ST_CERT_ALIAS: dockerd
```

As with the basic configuration file, the certificates must be supplied using a docker secret via the docker-compose file ([example is located here.](docker-compose.yml)). Note that you can import only one Root CA and one local certificate.

#### JVM Parameters for ST services are configurable

The JVM MIN/MAX memory paramteres for each service are configurable via file that is supplied to ST using docker secrets and environment variable (see docker-compose.yml above).

The format of the file ([STStartScriptsConfig](backend/runtime/standalone/STStartScriptsConfig)) is very simple:

```
# Start scripts configuration should be specified here in the following format:
# [PROTPCOL_NAME]_[OPTION_NAME]=[value]

TM_JAVA_MEM_MIN=256M
TM_JAVA_MEM_MAX=256M
SSH_JAVA_MEM_MIN=128M
SSH_JAVA_MEM_MAX=128M
HTTP_JAVA_MEM_MIN=128M
HTTP_JAVA_MEM_MAX=128M
FTP_JAVA_MEM_MIN=128M
FTP_JAVA_MEM_MAX=128M
AS2_JAVA_MEM_MIN=128M
AS2_JAVA_MEM_MAX=128M
ADMIN_JAVA_MEM_MIN=128M
ADMIN_JAVA_MEM_MAX=128M
PESIT_JAVA_MEM_MIN=128M
PESIT_JAVA_MEM_MAX=128M
```

#### Configuration enables composition with other services or products

A lot of the ST fuctionality can be configured using the ST REST API. You can write a custom shell script that can be executed as part of the normal ST startup procedure that will perform additional configuration of ST using the REST API.

The script must be made available inside the container as a docker secret and it's location must be specified using the following environment variable: **SETUP_EXTERNAL_SERVICES_PATH**. You can find an example script, that is used to configure Sentinel (on the ST Backend) and setup streaming between the Edge and Backend, here: ([setup_external_services.sh](backend/runtime/setup_external_services.sh)).

When the **SETUP_EXTERNAL_SERVICES_PATH** has been set and it points to an executable file, the ST startup procedure will start the DB and Admin and will wait for the Admin to start before proceeding with executing the script and starting the rest of the services. This change of the flow is mostly required for the Streaming setup.

##### Sentinel

Sentinel can be configured using the [setup_external_services.sh](backend/runtime/setup_external_services.sh). The script expects to find the JSON file, containing the sentinel configuration, in the **ST_SENTINEL_CONFIG_PATH** environment variable (example: [SentinelConfig.json](backend/runtime/standalone/SentinelConfig.json)).

##### ST Streaming 

Setting up Streaming between the ST Edge and Backend requires several things:
- Importing Certificates for the Streaming servers (EDGE) and Streaming Client (Backend) signed by the same CA (the ST_CA_* and ST_CERT_* variables are used for this - see above)
- Updating the "Private" network zone on the ST Edge to specify that the streaming servers for the individual protocol services should bind to 0.0.0.0, and (optionally) set ssl alias
- Creating a new Network Zone on the Backend that points to Edge
- Setting "Streaming.TrustedAliases" Server Configuration option to point the the CA certificate used to sing the Streaming certificates

The first part (Importing Certificates) is covered in  [basic-configuration-through-environment-variables](#basic-configuration-through-environment-variables) section.
Updating the Private Zone on the Edge and creating the new zone on the Backend is performed using the [setup_external_services.sh](backend/runtime/setup_external_services.sh) script by supplying the Network Zone definition in JSON format as a docker secret and then setting the value of the **ST_NETWORK_ZONES_CONFIG_PATH** variable to point the file.

Examples:
- Private Zone on the Edge - [NetworkZonePrivateConfig.json](edge/runtime/NetworkZonePrivateConfig.json)
- Edge Zone on the Backend - [NetworkZoneEdgeConfig.json](backend/runtime/streaming/NetworkZoneEdgeConfig.json)

Last but not least the "Streaming.TrustedAliases" Server Configuration option is set by creating an "options-overwrite" file that must be supplied inside the contaiiner and its location must be set using **ST_OPTIONS_OVERWRITE_CONF_PATH** environment variable.

The following docker-compose file has all this configured - [docker-compose-streaming.yml](docker-compose-streaming.yml).

#### The application should log everything to stdout/stderr

By default ST keeps its Server Log inside the embedded MySQL database. This will remain like this because the Server Log data is used together with the File Tracking information to help the ST administrator in debugging failed transfers (i.e. the data in the File Tracking tables has links to the data in the Server Log tables).

However for the purposes of the ST - Docker integration most of the Server Log data has been also exposed on STDOUT/STDERR and this is enabled by default when the image is built. Behind the scenes each **-log4j.xml gets additional appenders (Stdout/Stderr) that are commented by default but are enabled duirng the docker image build process.

#### Fast stop: In order to be gracefully stopped, a container has 10 seconds (by default) to exit (SIGTERM)

Becasue ST is a monolithic application one can start multiple services at the same time (SSH, PESIT and AS2 for example). It is hard to stop all of that gracefully under 10 seconds. However the improvement in this version is that the **SecureTransport/bin/start_all** script has been modifed and can now be executed in "trap" mode which means that after all enabled services are started the scripts stays in foreground (not allowing docker to kill the container) and when SIGTERM is received all enabled services are stopped using their respective **stop_XX** script. Since the process takes longer than 10 seconds the example docker-compose.yml file has the **stop_grace_period: 2m** setting to give it enough time (the setting can be tuned of course)

#### Start/Stop/Restart container: Sometimes containers perform tasks on first start preventing them to be restarted

The current docker images uses a Standalone ST with the Embedded MySQL Database. ST is already installed during the image build process and using the above mentioned features the runtime configuration can be easily changed so there is no need to perform any "special" tasks on the first start.

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

| Parameter | Description |
| --------- | ----------- |
| ST_CORE_LICENSE     | The contents of the ST Core license (usually `cat /run/secrets/st-core-license`) |
| ST_FEATURE_LICENSE | The contents of the ST Feature license (usually `cat /run/secrets/st-feature-license`) |
| ST_GLOBAL_CONFIG_PATH | The location of the ST Configuration file (to enable/disable/configure ST services) |
| START_SCRIPTS_CONF_PATH | The location inside the contaioner of the file that specifies the JVM settings for the running services |
| ST_CA_PATH | The location inside the container of the Custom Root CA Certificate (PEM/DER) |
| ST_CA_ALIAS | The certificate alias of the Custom Root CA |
| ST_CERT_PATH | The location inside the container of the Local Certificate (PKCS#12) that must be imported in ST Local Certificates store |
| ST_CERT_PASS | The password of the PKCS#12 local certificate |
| ST_CERT_ALIAS | The alias of the local certificate |
| SETUP_EXTERNAL_SERVICES_PATH | The location inside the container of the custom script that configures ST features using the ST REST API |
