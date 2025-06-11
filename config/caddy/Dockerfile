# ---------- builder stage (Alpine) ------------------------------------------
FROM composer:2.7 AS vendor

RUN apk add --no-cache rabbitmq-c rabbitmq-c-dev autoconf g++ make \
 && pecl install redis amqp \
 && docker-php-ext-enable redis amqp

ENV APP_ENV=dev
WORKDIR /app
COPY ./autocondat7/ ./
RUN composer install --prefer-dist --no-interaction --optimize-autoloader
RUN composer dump-autoload --optimize

# ---------- runtime stage (Debian) ------------------------------------------
FROM dunglas/frankenphp:1-php8.3-bookworm AS runtime

RUN apt-get update \
 && apt-get install -y --no-install-recommends librabbitmq-dev \
 && install-php-extensions pdo_pgsql intl redis opcache amqp \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV APP_ENV=dev \
    PHP_OPCACHE_ENABLE=1 \
    PHP_OPCACHE_JIT=on \
    PHP_OPCACHE_MEMORY_CONSUMPTION=128 \
    PHP_OPCACHE_PRELOAD=/app/config/preload.php

WORKDIR /app
COPY --from=vendor /app /app
COPY config/caddy/Caddyfile /etc/caddy/Caddyfile

RUN mkdir -p /app/storage/caddy \
 && chown -R 1001:1001 /app/storage

COPY config/caddy/docker-entrypoint.sh /usr/local/bin/entry
RUN chmod +x /usr/local/bin/entry
ENTRYPOINT ["/usr/local/bin/entry"]

RUN addgroup --gid 1001 app \
 && adduser  --uid 1001 --gid 1001 --disabled-password --gecos "" app \
 && chown -R app:app /app
USER app

EXPOSE 80 443
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
