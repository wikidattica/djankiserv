#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER "$DJANKISERV_MAINDB_USER" PASSWORD '$DJANKISERV_MAINDB_PASSWORD';
    CREATE DATABASE "$DJANKISERV_MAINDB_NAME" owner $DJANKISERV_MAINDB_USER;
    GRANT ALL PRIVILEGES ON DATABASE "$DJANKISERV_MAINDB_NAME" TO "$DJANKISERV_MAINDB_USER";
EOSQL

if [ ! "$DJANKISERV_USERDB_USER" = "$DJANKISERV_MAINDB_USER" ] ; then
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
     CREATE USER "$DJANKISERV_USERDB_USER" PASSWORD '$DJANKISERV_USERDB_PASSWORD';
EOSQL
fi

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE "$DJANKISERV_USERDB_NAME" owner $DJANKISERV_USERDB_USER;
    GRANT ALL PRIVILEGES ON DATABASE "$DJANKISERV_USERDB_NAME" TO "$DJANKISERV_USERDB_USER";
EOSQL
