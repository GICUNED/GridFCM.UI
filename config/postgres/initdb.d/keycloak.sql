\set KEYCLOAK_POSTGRES_USER 'keycloak'
\set KEYCLOAK_POSTGRES_PASSWORD `printf -- '%s' "${KEYCLOAK_POSTGRES_PASSWORD}"`
\set KEYCLOAK_POSTGRES_DATABASE 'keycloak'

CREATE USER :"KEYCLOAK_POSTGRES_USER" PASSWORD :'KEYCLOAK_POSTGRES_PASSWORD';
CREATE DATABASE :"KEYCLOAK_POSTGRES_DATABASE" WITH OWNER = :"KEYCLOAK_POSTGRES_USER" ENCODING = 'UTF8' TABLESPACE = pg_default;
GRANT ALL PRIVILEGES ON DATABASE :"KEYCLOAK_POSTGRES_DATABASE" TO :"KEYCLOAK_POSTGRES_USER";
