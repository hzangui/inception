#!/bin/bash
set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[setup.sh] No existing database found — initializing..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Start MariaDB temporarily to (re)apply config, every boot
mysqld_safe --datadir=/var/lib/mysql --skip-networking &

until mysqladmin ping --silent; do
    sleep 1
done

mysql -u root <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

echo "[setup.sh] Starting MariaDB in foreground..."
exec mysqld_safe --datadir=/var/lib/mysql