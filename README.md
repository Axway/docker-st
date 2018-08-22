### Secure Transport Backend 5.4

#### Prerequisites

- Docker version >= 17.11
- Docker-compose version >= 1.17.0

#### Starting Secure Transport

1) To start Secure Transport, run 

   `docker-compose up`

2) Login to Secure Transport using on [https://localhost:9444](https://localhost:9444) with the following credentials

   - ID: `admin`
   - Password: `admin` 

#### Stopping Secure Transport

Stop the containers using the following command (from the folder where docker-compose.yml file is located)

   `docker-compose down -v`

#### Parameters

| Parameter | Description |
| --------- | ----------- |
| ST_CORE_LICENSE     |  |
| ST_FEATURE_LICENSE |  |
