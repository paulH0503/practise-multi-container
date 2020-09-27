#!/bin/bash
set -e
echo "DB: $POSTGRES_USER $POSTGRES_DB"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER postgres;
    CREATE DATABASE course;
    GRANT ALL PRIVILEGES ON DATABASE course TO postgres;
EOSQL