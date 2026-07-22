# IncidentResponse Custom OneUptime Deployment Guide

This repository contains a customized OneUptime build for `metastablehub/incidentResponse` with branding changes and a reduced product surface.

The dashboard excludes these products:

- Logs
- Metrics
- Traces
- Exceptions
- Services

Telemetry and OTel Collector services are also excluded from the custom deployment stack.

---

## Scenario 1: Development Source Deployment (for ongoing code changes)

Use this when you want to keep modifying source code and redeploy from source.

### 1. Clone repository

```bash
git clone https://github.com/metastablehub/incidentResponse.git
cd incidentResponse
```

### 2. Prepare environment

```bash
cp config.example.env config.env
```

Update required values in `config.env`:

- `HOST`
- `ONEUPTIME_SECRET`
- `REGISTER_PROBE_KEY`
- `DATABASE_PASSWORD`
- `CLICKHOUSE_PASSWORD`
- `REDIS_PASSWORD`
- `ENCRYPTION_SECRET`
- `GLOBAL_PROBE_1_KEY`
- `GLOBAL_PROBE_2_KEY`

### 3. Build and run from source

```bash
./install-splunk-oneuptime.sh
```

This command runs:

```bash
docker compose --env-file config.env -f docker-compose.splunk-prod.yml up -d --build
```

### 4. Verify

```bash
docker compose --env-file config.env -f docker-compose.splunk-prod.yml ps
```

### 5. Update workflow for future source changes

After code changes:

```bash
git pull
./install-splunk-oneuptime.sh
```

---

## Scenario 2: Prebuilt Production Deployment (no rebuild on target VM)

Use this when deploying to a different VM and you want to pull hardened images from GHCR instead of building.

### 0. Pre-requisites
Docker, Docker compose, Git, vim
RAM: 16 GB
ROM: 140GB

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

```bash
sudo apt update && sudo apt install git -y
```

```bash
sudo apt update
sudo apt install vim -y
```


### 1. Clone repository

```bash
git clone https://github.com/metastablehub/incidentResponse.git
cd incidentResponse
```

### 2. Prepare environment

```bash
cp config.example.env config.env
```

Set required production values in `config.env`.

### 3. Set GHCR credentials and image tag

```bash
export GHCR_USERNAME=metastablehub
export GHCR_TOKEN=<your_pat_with_packages_write_or_read>
export SPLUNK_IMAGE_TAG=latest
```

### 4. Deploy prebuilt images

```bash
./install-splunk-oneuptime-prebuilt.sh
```

This script logs into GHCR, pulls published images, and starts containers without `--build`.

---

## Publishing Prebuilt Images to GHCR

Run this from your build/publish machine:

```bash
export GHCR_USERNAME=metastablehub
export GHCR_TOKEN=<your_pat_with_packages_write>
export SPLUNK_IMAGE_TAG=latest
./publish-splunk-ghcr.sh
```

Published image names:

- `ghcr.io/metastablehub/incidentresponse/accounts:<tag>`
- `ghcr.io/metastablehub/incidentresponse/dashboard:<tag>`
- `ghcr.io/metastablehub/incidentresponse/admin-dashboard:<tag>`
- `ghcr.io/metastablehub/incidentresponse/status-page:<tag>`
- `ghcr.io/metastablehub/incidentresponse/app:<tag>`
- `ghcr.io/metastablehub/incidentresponse/worker:<tag>`
- `ghcr.io/metastablehub/incidentresponse/docs:<tag>`
- `ghcr.io/metastablehub/incidentresponse/workflow:<tag>`
- `ghcr.io/metastablehub/incidentresponse/home:<tag>`
- `ghcr.io/metastablehub/incidentresponse/probe:<tag>`
- `ghcr.io/metastablehub/incidentresponse/probe-ingest:<tag>`
- `ghcr.io/metastablehub/incidentresponse/server-monitor-ingest:<tag>`
- `ghcr.io/metastablehub/incidentresponse/incoming-request-ingest:<tag>`
- `ghcr.io/metastablehub/incidentresponse/isolated-vm:<tag>`
- `ghcr.io/metastablehub/incidentresponse/mcp:<tag>`
- `ghcr.io/metastablehub/incidentresponse/ingress:<tag>`

---

## Notes

- `clickhouse` remains required by core backend startup checks.
- The prebuilt deployment still uses upstream `postgres`, `redis`, and `clickhouse` images.
- For internet-facing production, enable TLS and review all security settings in `config.env`.
