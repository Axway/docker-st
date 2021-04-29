CREATE TABLESPACE st_data
OWNER postgres
LOCATION '/var/lib/postgresql/st_data';

ALTER TABLESPACE st_data OWNER TO postgres;

CREATE TABLESPACE st_serverlog
OWNER postgres
LOCATION '/var/lib/postgresql/st_slog';

ALTER TABLESPACE st_serverlog OWNER TO postgres;

CREATE TABLESPACE st_filetracking
OWNER postgres
LOCATION '/var/lib/postgresql/st_ftrack';

ALTER TABLESPACE st_filetracking OWNER TO postgres;

GRANT CREATE ON TABLESPACE st_data TO PUBLIC;
GRANT CREATE ON TABLESPACE st_serverlog TO PUBLIC;
GRANT CREATE ON TABLESPACE st_filetracking TO PUBLIC;

CREATE ROLE stuser WITH
    LOGIN
    SUPERUSER
    CREATEDB
    CREATEROLE
    INHERIT
    NOREPLICATION
    CONNECTION LIMIT -1
    PASSWORD 'stuser';

CREATE DATABASE stuser
WITH
OWNER = stuser
ENCODING = 'UTF8'
CONNECTION LIMIT = -1;
