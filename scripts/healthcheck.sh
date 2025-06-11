#!/usr/bin/env bash
set -euo pipefail

# ------ container state ------------------------------------------------------
is_running() {
  docker compose ps --format json \
  | jq -e --arg svc "$1" '
       select(.Service==$svc) | select(.State=="running")
    ' >/dev/null                   # works with Compose ≥2.21 JSON stream:contentReference[oaicite:8]{index=8}:contentReference[oaicite:9]{index=9}
}

for s in db cache messaging code-quality app mailhog; do
  is_running "$s" || { echo "ERROR: $s not running"; exit 1; }
done

# ------ deep probes ----------------------------------------------------------
docker compose exec db pg_isready -U autocondat -d autocondat >/dev/null
docker compose exec cache redis-cli -a redis ping | grep -q PONG
docker compose exec messaging rabbitmq-diagnostics -q ping               # no curl needed
curl -fs http://localhost:8000/health >/dev/null
curl -fs http://localhost:8025        >/dev/null
curl -fs http://localhost:9000/api/system/status | jq -e '.status=="UP"' >/dev/null

echo "✅  All services are healthy"
