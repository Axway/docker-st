# AMPLIFY SecureTransport Docker Images

The repository contains the Dockerfiles and related scripts to build the Amplify SecureTransport Server and Edge Docker Images. 

You can find more information about building the Docker images, deploying them in Kubernetes, and much more in the dedicated guide - [SecureTransport_5.5_Containerized_Deployment_Guide_allOS_en_HTML5](https://linkzaguide-a.com)

# Quick start using docker-compose

Despite it is not the official deployment mechanism, SecureTransport can be deployed using docker-compose following the below steps:

1) Download the SecureTransport Server/Edge Docker image from [Axway Support](https://support.axway.com/).

2) Unzip the downloaded package.

3) Load the image.

From the folder where the docker image is located, run the command:

```console
    docker load -i <Secure-Transport-image>.tar.gz
```

#### E  nvironment Variable Parameters

The following environment variables must be present in the docker-compose.yml file. Only ST_START_SCRIPTS_CONF_PATH is optional variable.

|          Parameter         |                                                                              Description                                                                          |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ST_CORE_LICENSE            | The contents of the ST Core license                                                                                                                               |
| ST_FEATURE_LICENSE         | The contents of the ST Feature license                                                                                                                            |
| ST_CONTAINER_CONFIG_PATH   | The location of the ST configuration files directory. Mandatory files are - taeh file, db.conf, st.license and filedrive.license                                  |
| ST_START_SCRIPTS_CONF_PATH | The location inside the contaioner of the file that specifies the JVM settings for the running services if set the file must be present on the specified location |

#### Start Secure Transport with docker-compose

0) External database and storage must be pre-setup before begining the process. Note that for SecureTransport server MSSQL and Oracle databases are supported, SecureTransport edges support only MySQL database.

1) Obtain your licenses from [Axway Support](https://support.axway.com/).

2) Place them in the respective files [filedrive.license](server/runtime/secrets/filedrive.license) and [st.license](server/runtime/secrets/st.license).

3) Generate taeh file and encrypt the database password using the following commands:

```console
$ mkdir /tmp/secret_folder
$ chmod 777 /tmp/secret_folder
$ touch /tmp/secret_folder/pass # Еdit the /tmp/secret_folder/pass file to contain the Database password.
$ docker run --rm --entrypoint '' -v /tmp/secret_folder/:/tmp/secret_folder <st-image> /bin/bash -c '$ST_HOME/bin/createTaehFile /tmp/secret_folder ; cp /tmp/secret_folder/taeh $ST_HOME/bin/taeh ; $ST_HOME/bin/utils/aesenc "$(< /tmp/secret_folder/pass)" > /tmp/secret_folder/encpass'
```
Place the taeh file in [server/runtime/secrets](server/runtime/secrets) and store the value of the encrypted database password for later usage located in encpass file.

4) Populate the [db.conf](server/runtime/secrets/db.conf) file with the database information. The encrypted password from the previous step must be used. Note if certificate is used for the database connection it must be present in the same location where ST_START_SCRIPTS_CONF_PATH is mounted.

5) Start Secure Transport, run (from the folder where docker-compose.yml file is located)

```console
   docker-compose up
```

6) Login to Secure Transport using on [https://localhost:9444](https://localhost:9444) with the following credentials

   - ID: `admin`
   - Password: `admin` 

#### Stopping Secure Transport with docker-compose

Stop the containers using the following command (from the folder where docker-compose.yml file is located)

```console
   docker-compose down -v
```

# Copyright

Copyright (c) 2020 Axway Software SA and its affiliates. All rights reserved.

# License

All files in this repository are licensed by Axway Software SA and its affiliates under the Apache License, Version 2.0, available at http://www.apache.org/licenses/.
