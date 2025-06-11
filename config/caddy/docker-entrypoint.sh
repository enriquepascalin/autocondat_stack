#!/usr/bin/env sh
set -e
# wait until Postgres accepts connections
until php /app/bin/console doctrine:query:sql "SELECT 1" >/dev/null 2>&1; do
  echo "⏳ waiting for database…" && sleep 2
done
php /app/bin/console doctrine:migrations:migrate --no-interaction
exec "$@"