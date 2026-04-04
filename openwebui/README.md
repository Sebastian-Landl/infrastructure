## Overview
This stack uses one compose file with:

1. Profile-based CPU/GPU startup.
2. Traefik HTTPS routing on the external `public` network.
3. OpenAI API-compatible backend configured via env.
4. Data persistence via env-driven bind mount path.

## Start Modes
The compose file defines two profiles:

1. `cpu`: no GPU reservation.
2. `gpu`: includes NVIDIA GPU reservation.

Choose one profile in `.env` via `COMPOSE_PROFILES`, then run:

```bash
docker compose up -d
```

Or explicitly:

```bash
docker compose --profile cpu up -d
docker compose --profile gpu up -d
```

The recommended place to review and edit variables is [openwebui/.env.example](openwebui/.env.example).

## Networking and Routing
OpenWebUI is published through Traefik using:

1. `OPENWEBUI_TRAEFIK_DOMAIN` for host rule routing.
2. Internal service port `8080` (no host port mapping — traffic goes through Traefik only).
3. Connected to two external networks: `public` (Traefik) and `mcp` (MCP gateway).

## Persistence
Data is persisted with a bind mount:

1. `OPENWEBUI_DATA_PATH:/app/backend/data`

Set `OPENWEBUI_DATA_PATH` in `.env`.

## Notes
1. `CORS_ALLOW_ORIGIN` is currently derived from `WEBUI_URL` in compose.
2. Admin auto-creation only happens on fresh data and when both admin email and password are set.
3. `ENABLE_PERSISTENT_CONFIG=true` means many settings can be overridden by values previously saved in OpenWebUI. If env changes seem ignored, check persisted settings in the UI/database.
4. `ENABLE_RAG_LOCAL_WEB_FETCH=false` is a security-focused default (SSRF protection for private/local addresses).

Reference docs:

- https://docs.openwebui.com/reference/env-configuration/
