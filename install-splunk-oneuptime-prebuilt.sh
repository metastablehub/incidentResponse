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

if [ -z "${SPLUNK_IMAGE_TAG:-}" ]; then
  echo "Set SPLUNK_IMAGE_TAG to a published GHCR tag (for example: encarta-ui-2026-02-28)."
  exit 1
fi

if [ "$SPLUNK_IMAGE_TAG" = "latest" ]; then
  echo "SPLUNK_IMAGE_TAG=latest is not allowed for production installs. Use a pinned tag."
  exit 1
fi

echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USERNAME" --password-stdin
docker compose --env-file config.env -f docker-compose.splunk-prod.yml pull
docker compose --env-file config.env -f docker-compose.splunk-prod.yml up -d

echo ""
echo "Deployment started from prebuilt GHCR images (tag: $SPLUNK_IMAGE_TAG)."
