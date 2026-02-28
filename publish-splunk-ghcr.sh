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
  cp config.example.env config.env
fi

if [ -z "${GHCR_USERNAME:-}" ] || [ -z "${GHCR_TOKEN:-}" ]; then
  echo "Set GHCR_USERNAME and GHCR_TOKEN before running this script."
  exit 1
fi

if [ -z "${SPLUNK_IMAGE_TAG:-}" ]; then
  echo "Set SPLUNK_IMAGE_TAG to a new release tag (for example: encarta-ui-2026-02-28)."
  exit 1
fi

if [ "$SPLUNK_IMAGE_TAG" = "latest" ]; then
  echo "SPLUNK_IMAGE_TAG=latest is not allowed for publish. Use a versioned tag."
  exit 1
fi

echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USERNAME" --password-stdin

docker compose --env-file config.env -f docker-compose.splunk-prod.yml build

docker compose --env-file config.env -f docker-compose.splunk-prod.yml push \
  accounts dashboard admin-dashboard status-page app worker docs workflow home \
  probe-1 probe-2 probe-ingest server-monitor-ingest incoming-request-ingest \
  isolated-vm mcp ingress

echo "GHCR publish complete with tag: $SPLUNK_IMAGE_TAG"
