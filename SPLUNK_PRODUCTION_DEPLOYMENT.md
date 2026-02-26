# Splunk Production Deployment (Custom OneUptime)

This deployment uses local source builds so it includes your current repository changes (UI/logo/branding/customizations).

## Included

- All standard product services required for Essentials, Analytics & Automation, and Settings.
- Your local code changes from this repo.

## Excluded

- Observability services in deployment runtime:
  - `telemetry`
  - `otel-collector`

- Observability product routes/items removed from Dashboard UI:
  - Logs
  - Metrics
  - Traces
  - Exceptions
  - Services

## One-click install

```bash
./install-splunk-oneuptime.sh
```

This runs:

```bash
docker compose --env-file config.env -f docker-compose.splunk-prod.yml up -d --build
```

## Notes

- `clickhouse` is still required by core backend startup checks and remains in the stack.
- If `config.env` does not exist, installer copies it from `config.example.env`.
- Before internet-facing production use, set secure values in `config.env` (secrets, host, SSL, etc.).
