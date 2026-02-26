#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required but not installed."
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "docker compose plugin is required but not installed."
  exit 1
fi

if [ ! -f "config.env" ]; then
  echo "config.env not found. Creating it from config.example.env..."
  cp config.example.env config.env
fi

echo "Building and starting custom OneUptime stack (without Observability products)..."
docker compose --env-file config.env -f docker-compose.splunk-prod.yml up -d --build

echo ""
echo "Deployment started."
echo "Run 'docker compose --env-file config.env -f docker-compose.splunk-prod.yml ps' to check status."
