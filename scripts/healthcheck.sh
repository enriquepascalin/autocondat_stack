#!/usr/bin/env bash
# scripts/healthcheck.sh – unified health probe for the Autocondat stack
set -euo pipefail

# -------- helper -------------------------------------------------------------
# Runs the given command; on non-zero exit prints a custom error then aborts.
check() {
  "$@" || { echo "ERROR: $* failed"; exit 1; }
}

# -------- generic container state -------------------------------------------
services=( db cache messaging app mailhog code-quality )

for srv in "${services[@]}"; do
  docker compose ps --format json "$srv" | jq -e '.[0].State=="running"' >/dev/null \
    || { echo "ERROR: Service $srv is not running"; exit 1; }
done

# -------- service-specific probes -------------------------------------------
# PostgreSQL – waits until the DB accepts connections
check docker compose exec db pg_isready -U autocondat -d autocondat

# Redis – AUTH required; ping must return PONG
check docker compose exec cache redis-cli -a redis ping | grep -q PONG

# RabbitMQ – status must include "running"
check docker compose exec messaging rabbitmqctl status | grep -q running

# Symfony application HTTP health endpoint (returns 200/OK)
check curl -fs http://localhost:8000/health

# MailHog UI reachable
check curl -fs http://localhost:8025

# SonarQube reports status "UP"
check curl -fs http://localhost:9000/api/system/status | jq -e '.status=="UP"'

echo "✅  All services are healthy"