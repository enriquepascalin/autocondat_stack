# ---------- builder stage ----------------------------------------------------
FROM composer:2.7 as vendor

# Speed up install by re-using host UID/GID for cache layers
WORKDIR /app
COPY ./autocondat7/composer.* ./
RUN composer install --prefer-dist --no-dev --no-interaction --optimize-autoloader

# Copy the rest of the source for autoload-dump
COPY ./autocondat7 ./
RUN composer dump-autoload --optimize

# ---------- runtime stage ----------------------------------------------------
FROM dunglas/frankenphp:1-php8.3-bookworm AS runtime

# Production PHP extensions
RUN install-php-extensions \
        pdo_pgsql intl redis opcache

# Harden PHP & enable preloading / opcache for Symfony
ENV PHP_OPCACHE_ENABLE=1 \
    PHP_OPCACHE_JIT=on \
    PHP_OPCACHE_MEMORY_CONSUMPTION=128 \
    PHP_OPCACHE_PRELOAD=/app/config/preload.php

# Copy code and vendor from builder
WORKDIR /app
COPY --from=vendor /app /app

# Copy Caddyfile inside the image (can still be overridden by volume)
COPY Caddyfile /etc/caddy/Caddyfile

# Drop root privileges
RUN addgroup --gid 1001 app && \
    adduser  --uid 1001 --gid 1001 --disabled-password --gecos "" app && \
    chown -R app:app /app
USER app

# Expose HTTP & HTTPS
EXPOSE 80 443
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
