---
name: docker-volume-env
description: Convention for Docker container volume mounts — always use environment variables for bind-mount host paths (configs, databases, data dirs). Use this skill whenever adding or modifying volume mounts in docker-compose.yml files or any container config. When a new volume, config path, or database path is added to a container, the host-side path MUST become an env var using ${VAR_NAME} syntax. Never hardcode absolute host paths directly in volume entries. Exceptions: Docker socket (/var/run/docker.sock), system files (/etc/localtime, /etc/timezone), device paths (/dev/), and relative paths to files committed in the repo (./config.yml, ./acquis.yaml, etc.).
---

# Docker Volume Mount — Env Var Convention

All host-side paths in bind mounts must be env vars. This keeps deployments portable: the host layout can differ between machines without touching compose files.

## The Rule

Every bind mount with an absolute host path gets an env var:

```yaml
# Wrong — hardcoded path
volumes:
  - /opt/myapp/config:/config
  - /mnt/data/postgres:/var/lib/postgresql/data

# Correct — env var, no default
volumes:
  - ${CONFIG_PATH}:/config
  - ${POSTGRES_DATA}:/var/lib/postgresql/data
```

## Naming Conventions

Choose a name that is scoped to the service and describes the role of the data:

| Role              | Pattern                        | Example                     |
|-------------------|--------------------------------|-----------------------------|
| App config dir    | `<SERVICE>_CONFIG_PATH`        | `JELLYFIN_CONFIG_PATH`      |
| Data / media dir  | `<SERVICE>_DATA_PATH`          | `NEXTCLOUD_DATA_PATH`       |
| Database storage  | `<SERVICE>_DB_PATH` or `<SERVICE>_DB_DATA_PATH` | `POSTGRES_DATA_PATH` |
| Cache dir         | `<SERVICE>_CACHE_PATH`         | `JELLYFIN_CACHE_PATH`       |
| Log dir           | `<SERVICE>_LOG_PATH`           | `TRAEFIK_LOG_PATH`          |
| Upload / media    | `<SERVICE>_UPLOAD_PATH`        | `IMMICH_UPLOAD_PATH`        |

When the compose file only has one service or the service name is already in the file name (e.g. `jellyfin/docker-compose.yml`), the prefix can be dropped: `CONFIG_PATH`, `DATA_PATH`, `DB_PATH`.

## Declaring the Env Var

Add the variable to the service's `.env.example` file (create one if it doesn't exist) alongside a sensible default comment, and optionally to `environment:` or `env_file:` in the compose service.

```dotenv
# .env.example
# Path on the host where Jellyfin stores its configuration
CONFIG_PATH=/opt/jellyfin/config

# Path on the host where Jellyfin stores its cache
CACHE_PATH=/opt/jellyfin/cache

# Path on the host where media files are located (read-only mount)
MEDIA_PATH=/mnt/media
```

If the compose file uses `env_file: - .env`, variables in `.env` are automatically picked up — no need to re-list them under `environment:`.

## Exceptions — Do NOT wrap in env vars

These path types are special and must stay literal:

| Path pattern | Reason |
|---|---|
| `/var/run/docker.sock` | Docker socket; must always be this exact path |
| `/etc/localtime`, `/etc/timezone` | Host time sync; host path is always the same |
| `/dev/**` | Device nodes; hardware-specific, not configurable |
| `./relative/path` | Files committed to the repo; relative path is intentional and portable within the checkout |
| Named volumes (`myvolume:/data`) | Volume name on the left is a Docker concept, not a host path |

```yaml
volumes:
  # These stay as-is — they are exceptions
  - /var/run/docker.sock:/var/run/docker.sock
  - /etc/localtime:/etc/localtime:ro
  - ./config.yml:/app/config.yml:ro
  - pgdata:/var/lib/postgresql/data   # named volume, not a bind mount
```

## Full Example

**Before** (adding a new service — raw paths):
```yaml
services:
  myapp:
    image: myapp:latest
    volumes:
      - /srv/myapp/config:/config
      - /srv/myapp/data:/data
      - /var/run/docker.sock:/var/run/docker.sock
      - /etc/localtime:/etc/localtime:ro
      - ./custom.conf:/app/custom.conf:ro
```

**After** (applying this convention):
```yaml
services:
  myapp:
    image: myapp:latest
    volumes:
      - ${CONFIG_PATH}:/config
      - ${DATA_PATH}:/data
      - /var/run/docker.sock:/var/run/docker.sock      # exception
      - /etc/localtime:/etc/localtime:ro               # exception
      - ./custom.conf:/app/custom.conf:ro              # exception (repo file)
    env_file:
      - .env
```

`.env.example`:
```dotenv
CONFIG_PATH=/srv/myapp/config
DATA_PATH=/srv/myapp/data
```

## When Updating Existing Files

If an existing service in this repo has hardcoded host paths that are not yet parameterised, refactor them to follow this convention as part of the change — don't leave the old pattern next to new env-var mounts in the same service.
