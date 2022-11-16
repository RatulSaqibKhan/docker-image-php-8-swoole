ARG PHP_VERSION=8.0.6
ARG PHP_IMAGE_TYPE=cli

FROM php:${PHP_VERSION}-${PHP_IMAGE_TYPE}

ARG APT_DEPENDENCIES="libcurl4-openssl-dev libzip-dev libicu-dev uuid-dev zlib1g-dev libpng-dev"
ARG PHP_DOCKER_EXTENSIONS="bcmath exif fileinfo gd gettext intl pdo pcntl sockets tokenizer zip curl"
ARG PHP_PECL_EXTENSIONS="redis uuid pcov msgpack igbinary openswoole"

RUN echo "--- Install Dependencies ---" \
        && apt-get update \
        && apt-get install -y ${APT_DEPENDENCIES} \
    && echo "--- Setup PHP Extensions ---" \
        && apt-get update \
        && docker-php-ext-install -j$(nproc) ${PHP_DOCKER_EXTENSIONS} \
    && echo "-- Install PHP Extensions --" \
        && pear update-channels \
        && pecl install ${PHP_PECL_EXTENSIONS} \
        && docker-php-ext-enable ${PHP_PECL_EXTENSIONS} \
        && pear clear-cache \
    && echo "--- Clean Up ---" \
        && apt-get -y autoremove \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY .config/php.ini /usr/local/etc/php/conf.d/app-php.ini

# PHP INI Settings for production by default
ENV PHP_INI_OUTPUT_BUFFERING=4096 \
    PHP_INI_MAX_EXECUTION_TIME=60 \
    PHP_INI_MAX_INPUT_TIME=60 \
    PHP_INI_MEMORY_LIMIT="256M" \
    PHP_INI_DISPLAY_ERRORS="Off" \
    PHP_INI_DISPLAY_STARTUP_ERRORS="Off" \
    PHP_INI_POST_MAX_SIZE="2M" \
    PHP_INI_FILE_UPLOADS="On" \
    PHP_INI_UPLOAD_MAX_FILESIZE="2M" \
    PHP_INI_MAX_FILE_UPLOADS="2" \
    PHP_INI_ALLOW_URL_FOPEN="On" \
    PHP_INI_SESSION_SAVE_HANDLER="files" \
    PHP_INI_SESSION_SAVE_PATH="/tmp" \
    PHP_INI_SESSION_USE_STRICT_MODE=0 \
    PHP_INI_SESSION_USE_COOKIES=1 \
    PHP_INI_SESSION_USE_ONLY_COOKIES=1 \
    PHP_INI_SESSION_NAME="APP_SSID" \
    PHP_INI_SESSION_COOKIE_SECURE="On" \
    PHP_INI_SESSION_COOKIE_LIFETIME=0 \
    PHP_INI_SESSION_COOKIE_PATH="/" \
    PHP_INI_SESSION_COOKIE_DOMAIN="" \
    PHP_INI_SESSION_COOKIE_HTTPONLY="On" \
    PHP_INI_SESSION_COOKIE_SAMESITE="" \
    PHP_INI_SESSION_UPLOAD_PROGRESS_NAME="APP_UPLOAD_PROGRESS" \
    PHP_INI_OPCACHE_ENABLE=1 \
    PHP_INI_OPCACHE_ENABLE_CLI=0 \
    PHP_INI_OPCACHE_MEMORY_CONSUMPTION=256 \
    PHP_INI_OPCACHE_INTERNED_STRINGS_BUFFER=16 \
    PHP_INI_OPCACHE_MAX_ACCELERATED_FILES=100000 \
    PHP_INI_OPCACHE_MAX_WASTED_PERCENTAGE=25 \
    PHP_INI_OPCACHE_USE_CWD=0 \
    PHP_INI_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    PHP_INI_OPCACHE_REVALIDATE_FREQ=0 \
    PHP_INI_OPCACHE_SAVE_COMMENTS=0 \
    PHP_INI_OPCACHE_ENABLE_FILE_OVERRIDE=1 \
    PHP_INI_OPCACHE_MAX_FILE_SIZE=0 \
    PHP_INI_OPCACHE_FAST_SHUTDOWN=1