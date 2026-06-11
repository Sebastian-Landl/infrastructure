# Traefik + CrowdSec

This repository uses a single Docker Compose configuration in `traefik/docker-compose.yml` to run Traefik alongside an integrated CrowdSec service. CrowdSec parses Traefik access logs and the Traefik bouncer plugin blocks banned IPs at the edge.

## Architecture

- Traefik handles HTTP/HTTPS routing and exposes the dashboard/API
- CrowdSec analyzes Traefik access logs and maintains ban decisions
- The Traefik CrowdSec bouncer plugin queries CrowdSec LAPI for real-time blocking
- Traefik access logs are bind-mounted into the CrowdSec container via `TRAEFIK_LOG_PATH`

## Prerequisites

### 1. Create the external Docker network

This service uses the shared `public` network.

```bash
docker network create public
```

### 2. Create a basic auth hash for Traefik dashboard/API

```bash
docker run --rm -it httpd:2.4-alpine htpasswd -nB <username>
```

You will be prompted to enter a password. The hash will differ each time because the salt changes.

## Configuration

Create `traefik/.env` with the following values. All host paths are bind-mounted into the containers.

```env
# Traefik configuration
TRAEFIK_YML_PATH=/path/to/traefik/traefik.yml
TRAEFIK_ACME_PATH=/path/to/traefik/acme.json
TRAEFIK_CONFIGURATIONS_PATH=/path/to/traefik/configurations
TRAEFIK_LOG_PATH=/path/to/traefik/logs
TRAEFIK_DOMAIN=example.com

# CrowdSec configuration
CROWDSEC_BOUNCER_KEY=<your-generated-key>
CROWDSEC_DB_PATH=/path/to/crowdsec/db
CROWDSEC_CONFIG_PATH=/path/to/crowdsec/config
```

Generate a strong random bouncer key:

```bash
openssl rand -base64 32
```

Then configure the same key in `traefik/configurations/dynamic.yml`.

## Deploy

From the repository root:

```bash
docker compose -f traefik/docker-compose.yml up -d
```

If you update the Traefik dynamic configuration or the CrowdSec setup, restart the stack:

```bash
docker compose -f traefik/docker-compose.yml up -d --force-recreate
```

## Expose a container through Traefik

To expose another container through this Traefik stack, attach the container to the shared `public` network and add the standard Traefik Docker labels.

Example service labels for a container called `myapp` listening on port `8080`:

```yaml
services:
  myapp:
    image: myapp:latest
    networks:
      - public
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=public"
      - "traefik.http.routers.myapp-secure.entrypoints=websecure"
      - "traefik.http.routers.myapp-secure.rule=Host(`${MYAPP_TRAEFIK_DOMAIN}`)"
      - "traefik.http.routers.myapp-secure.service=myapp"
      - "traefik.http.services.myapp.loadbalancer.server.port=8080"
```

Key points:

- `traefik.enable=true` turns Traefik routing on for the container.
- `traefik.docker.network=public` tells Traefik which Docker network to use.
- The router rule should match the hostname you want to expose.
- Set `traefik.http.services.<name>.loadbalancer.server.port` to the container's internal HTTP port.

If your service has additional subpaths, mixed HTTP/TLS routes, or custom middleware, add the corresponding `traefik.http.routers.*` and `traefik.http.middlewares.*` labels as needed.

## Verify

Check CrowdSec connectivity and status:

```bash
docker exec crowdsec cscli bouncers list
docker exec crowdsec cscli metrics
```

Check Traefik logs for CrowdSec plugin activity:

```bash
docker logs traefik 2>&1 | grep -i crowdsec
```

## Optional: Enroll in CrowdSec Console

```bash
docker exec crowdsec cscli console enroll <your-enroll-key>
```

Get your enroll key at https://app.crowdsec.net

## Update CrowdSec collections

```bash
docker exec crowdsec cscli hub update
docker exec crowdsec cscli collections upgrade crowdsecurity/traefik
```

## CrowdSec cheatsheet

### View bans

```bash
cscli decisions list                    # all decisions
cscli decisions list --type ban         # bans only
cscli decisions list --ip 203.0.113.42  # specific IP
cscli decisions list -o json | jq       # JSON output
```

### Delete a ban

```bash
cscli decisions delete --ip 203.0.113.42
cscli decisions delete --range 203.0.113.0/24
```

### Custom whitelist

Adapt `whitelists-custom.yaml` to add IPs or ranges that should never be blocked, then restart the container to apply the change.