# CrowdSec

CrowdSec Security Engine running in Docker, integrated with Traefik via the
[crowdsec-bouncer-traefik-plugin](https://github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin).

## Architecture

- **CrowdSec engine** parses Traefik access logs and detects threats
- **Traefik bouncer plugin** queries CrowdSec LAPI and blocks banned IPs at the edge
- Traefik log path is bind-mounted via `TRAEFIK_LOG_PATH` env var (shared with the Traefik container)

## First-time setup

### 1. Configure environment variables

Create `crowdsec/.env` (all paths are host-side bind-mount locations):

```env
# Bouncer key — must match traefik/configurations/dynamic.yml
CROWDSEC_BOUNCER_KEY=<your-generated-key>

# Host path to Traefik access logs directory (shared with Traefik container)
TRAEFIK_LOG_PATH=/path/to/traefik/logs

# Persistent storage for CrowdSec database and config
CROWDSEC_DB_PATH=/path/to/crowdsec/db
CROWDSEC_CONFIG_PATH=/path/to/crowdsec/config
```

Generate a strong random bouncer key with `openssl rand -base64 32`.

### 2. Configure the bouncer key

**`traefik/configurations/dynamic.yml`** — replace the `<CROWDSEC_BOUNCER_KEY>` placeholder with the same key.

### 3. Bring up CrowdSec first

```bash
# From the infrastructure root
docker compose -f crowdsec/docker-compose.yml up -d
```

### 4. Restart Traefik

Traefik loads the experimental plugin on startup, so a restart picks up the new config:

```bash
docker compose -f traefik/docker-compose.yml up -d --force-recreate
```

## Verify

Check CrowdSec is running and connected:

```bash
docker exec crowdsec cscli bouncers list
docker exec crowdsec cscli metrics
```

To test that the bouncer is working, check Traefik logs for the plugin being loaded:

```bash
docker logs traefik 2>&1 | grep -i crowdsec
```

## Enroll in CrowdSec Console (optional)

```bash
docker exec crowdsec cscli console enroll <your-enroll-key>
```

Get your enroll key at https://app.crowdsec.net

## Update collections

```bash
docker exec crowdsec cscli hub update
docker exec crowdsec cscli collections upgrade crowdsecurity/traefik
```

## Cheatsheet

### View Bans
 
```bash
cscli decisions list                    # all decisions
cscli decisions list --type ban         # bans only
cscli decisions list --ip 203.0.113.42  # specific IP
cscli decisions list -o json | jq       # JSON output
```
 
### Delete a Ban
 
```bash
cscli decisions delete --ip 203.0.113.42
cscli decisions delete --range 203.0.113.0/24
```
 
### Custom Whitelist
Adapt the `whitelists-custom.yaml` file to add IPs or ranges you want to ensure are never blocked, then restart the container to apply.
