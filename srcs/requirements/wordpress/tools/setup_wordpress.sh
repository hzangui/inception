#!/bin/bash
set -e

WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)
WORDPRESS_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WORDPRESS_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

if [ ! -f "${WORDPRESS_PATH}"/wp-config.php ]; then
    echo "First boot: downloading and configuring WordPress..."
    wp core download --allow-root --path="${WORDPRESS_PATH}"

    wp config create --allow-root --path="${WORDPRESS_PATH}" \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST"

    wp core install --allow-root --path="${WORDPRESS_PATH}" \
        --url="https://$DOMAIN_NAME" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \

    wp user create --allow-root --path="${WORDPRESS_PATH}" \
        "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" \
        --user_pass="$WORDPRESS_USER_PASSWORD" \
        --role=subscriber
else
    echo "wp-config.php already exists, skipping install."
fi

# --- Redis wiring: must run on every boot, not just first install ---
wp config set WP_REDIS_HOST redis --path="${WORDPRESS_PATH}" --allow-root --type=constant
wp config set WP_REDIS_PORT "${REDIS_PORT}" --path="${WORDPRESS_PATH}" --allow-root --type=constant --raw
wp config set WP_CACHE true --path="${WORDPRESS_PATH}" --allow-root --type=constant --raw

if ! wp plugin is-installed redis-cache --path="${WORDPRESS_PATH}" --allow-root; then
    wp plugin install redis-cache --path="${WORDPRESS_PATH}" --allow-root
fi
wp plugin activate redis-cache --path="${WORDPRESS_PATH}" --allow-root
wp redis enable --path="${WORDPRESS_PATH}" --allow-root

chown -R www-data:www-data "${WORDPRESS_PATH}"

exec php-fpm8.2 -F