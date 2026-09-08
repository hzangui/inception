#!/bin/bash
set -e

MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)



echo "[setup.sh] Applying database and credentials..."
mysqld --user=mysql --datadir=/var/lib/mysql --bootstrap << EOSQL
    FLUSH PRIVILEGES;
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

echo "[setup.sh] Starting MariaDB in foreground..."
exec mysqld --user=mysql --datadir=/var/lib/mysql