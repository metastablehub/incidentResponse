v2 Install:
1. Create a Linux VM (Ubuntu 22.04/24.04 recommended) with at least:
- `4 vCPU`, `16 GB RAM`, `80+ GB disk`
- Public IP
- Firewall open on `80` and `443`

2. SSH into the VM and install Docker + Compose plugin:
```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin git
sudo usermod -aG docker $USER
newgrp docker
```

3. Clone your repo:
```bash
git clone <your-repo-url> /opt/incidentResponse
cd /opt/incidentResponse
```

4. Create config file:
```bash
cp config.example.env config.env
```

5. Edit `config.env`:
```bash
nano config.env
```
Set at minimum:
- `HOST=<your_vm_public_ip_or_domain>`
- `ONEUPTIME_HTTP_PORT=80`
- `PROVISION_SSL=false` (or `true` if domain DNS is ready for Let's Encrypt)
- All secrets (`ONEUPTIME_SECRET`, `DATABASE_PASSWORD`, etc.) to strong random values
- `SPLUNK_IMAGE_TAG=encarta-ui-2026-02-28`  ← important (pinned tag)

6. Export GHCR credentials:
```bash
export GHCR_USERNAME=metastablehub
export GHCR_TOKEN=<your_ghcr_pat_with_read:packages>
```

7. Pull and run prebuilt images:
```bash
chmod +x install-splunk-oneuptime-prebuilt.sh
./install-splunk-oneuptime-prebuilt.sh
```

8. Verify containers are up:
```bash
docker compose --env-file config.env -f docker-compose.splunk-prod.yml ps
```

9. Verify HTTP response:
```bash
curl -I http://127.0.0.1:80
curl -I http://<your_vm_public_ip>:80
```
You should see `HTTP/1.1 200 OK`.

10. Open in browser:
- `http://<your_vm_public_ip>`  
- If using DNS: `http://<your_domain>` (or `https://` if SSL enabled)

If you want, I can also give you a hardened production checklist (TLS, backups, monitoring, auto-restart policy, and upgrade procedure).





















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
