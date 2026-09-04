#!/bin/bash
set -e

# --- Wait for MariaDB to be ready ---
until mysqladmin ping -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
    echo "Waiting for MariaDB at $WORDPRESS_DB_HOST..."
    sleep 2
done

# --- First boot vs restart: does wp-config.php already exist? ---
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "First boot: downloading and configuring WordPress..."

    wp core download --allow-root --path=/var/www/html

    wp config create --allow-root --path=/var/www/html \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST"

    wp core install --allow-root --path=/var/www/html \
        --url="$WORDPRESS_URL" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --skip-email

    wp user create --allow-root --path=/var/www/html \
        "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" \
        --user_pass="$WORDPRESS_USER_PASSWORD" \
        --role=author
else
    echo "wp-config.php already exists, skipping install."
fi

chown -R www-data:www-data /var/www/html

exec php-fpm7.4 -F