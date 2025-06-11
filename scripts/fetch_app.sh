#!/usr/bin/env bash
set -euo pipefail
REPO_URL="https://github.com/enriquepascalin/autocondat7.git"
TARGET_DIR="$(dirname "$0")/../autocondat7"

if [ -d "$TARGET_DIR/.git" ]; then
  echo "🔄 Updating Autocondat7 …"
  git -C "$TARGET_DIR" pull --ff-only
else
  echo "📥 Cloning Autocondat7 …"
  git clone "$REPO_URL" "$TARGET_DIR"
fi
echo "✅ Autocondat7 is ready at $TARGET_DIR"