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

if [ -z "${GHCR_USERNAME:-}" ] || [ -z "${GHCR_TOKEN:-}" ]; then
  echo "Set GHCR_USERNAME and GHCR_TOKEN before running this script."
  echo "Example: export GHCR_USERNAME=metastablehub"
  exit 1
fi

export SPLUNK_IMAGE_TAG="${SPLUNK_IMAGE_TAG:-latest}"

echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USERNAME" --password-stdin
docker compose --env-file config.env -f docker-compose.splunk-prod.yml pull
docker compose --env-file config.env -f docker-compose.splunk-prod.yml up -d

echo ""
echo "Deployment started from prebuilt GHCR images (tag: $SPLUNK_IMAGE_TAG)."
