ARG PHP_VERSION=8.1.12
ARG PHP_IMAGE_TYPE=cli

FROM php:${PHP_VERSION}-${PHP_IMAGE_TYPE}

LABEL maintainer="Md Nazmus Saqib Khan<ratulkhan.jhenidah@gmail.com>"

# APT Dependencies
ARG APT_DEPENDENCIES="g++ git curl nginx libcurl4-openssl-dev zip unzip make cmake clang autoconf build-essential libc6 libgmp-dev libicu-dev libpcre3-dev libssl-dev libyaml-dev libzip-dev multiarch-support openssl supervisor tzdata uuid-dev zlib1g-dev gnupg gosu ca-certificates libcap2-bin libpng-dev dh-python"
# PHP Dependencies
ARG PHP_DOCKER_EXTENSIONS="bcmath exif fileinfo gd gettext intl pdo pcntl sockets zip curl mysqli pdo pdo_mysql"
ARG PHP_PECL_EXTENSIONS="redis uuid pcov msgpack igbinary"

# Composer variables
ARG COMPOSER_HOME="/var/www/.composer"
ARG COMPOSER_VERSION="2.4.4"

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "--- Install Dependencies ---" \
    && apt-get update \
    && apt-get install -y wget \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/g/glibc/multiarch-support_2.27-3ubuntu1_amd64.deb \
    && apt-get install ./multiarch-support_2.27-3ubuntu1_amd64.deb \
    && apt-get install -y ${APT_DEPENDENCIES}
RUN echo "--- Setup PHP Extensions ---" \
    && apt-get update \
    && docker-php-ext-install -j$(nproc) ${PHP_DOCKER_EXTENSIONS}
RUN echo "-- Install PHP Extensions --" \
    && pear update-channels \
    && pecl install ${PHP_PECL_EXTENSIONS} \
    && pecl install openswoole-22.0.0 \
    && docker-php-ext-enable ${PHP_PECL_EXTENSIONS} \
    && docker-php-ext-enable openswoole \
    && pear clear-cache
RUN echo "--- Installing Composer ---" \
    && curl -L -o /usr/local/bin/composer https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar \
    && mkdir -p ${COMPOSER_HOME} \
    && mkdir /run/php \
    && chown -R www-data:www-data ${COMPOSER_HOME} /run/php \
    && chmod -R ugo+w ${COMPOSER_HOME} \
    && chmod -R g+s ${COMPOSER_HOME} \
    && chmod ugo+x /usr/local/bin/composer \
    && composer --version

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