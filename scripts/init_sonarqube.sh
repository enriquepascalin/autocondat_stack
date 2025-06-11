#!/usr/bin/env bash
set -euo pipefail

echo "⌛ Waiting for SonarQube to report status UP…"
until curl -sf http://code-quality:9000/api/system/status | jq -e '.status=="UP"' >/dev/null; do
  sleep 5
done

echo "⚙️  Configuring SonarQube"
ADMIN_TOKEN=$(curl -sf -u admin:admin -X POST \
  "http://code-quality:9000/api/user_tokens/generate" \
  -d "name=autocondat" | jq -r '.token')

# Example custom profile
curl -sf -u "$ADMIN_TOKEN": -X POST \
  "http://code-quality:9000/api/qualityprofiles/create" \
  -d "language=php&name=Autocondat+PHP"

echo "✅ SonarQube configured — token: $ADMIN_TOKEN"
