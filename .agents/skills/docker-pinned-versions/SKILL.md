---
name: docker-pinned-versions
description: Look up the latest stable release tag for a Docker image on Docker Hub before using it in a docker-compose.yml file. Use this skill whenever a docker-compose file is being created or edited and any image is written as `latest` or without a version tag. Never write `image: foo:latest` or `image: foo` in production compose files — always resolve and pin a real version tag first.
---

# Docker Pinned Versions

Never use `:latest` or an untagged image in production `docker-compose.yml` files. Always resolve an explicit, stable version tag first.

## How to look up the latest stable tag

Use the Docker Hub API via `fetch_webpage`:

```
https://hub.docker.com/v2/repositories/<namespace>/<image>/tags?page_size=25&ordering=last_updated
```

For official images (no namespace), use `library` as the namespace:

```
https://hub.docker.com/v2/repositories/library/postgres/tags?page_size=25&ordering=last_updated
```

### Tag selection rules

1. **Prefer a semantic version** with no suffix (e.g. `v3.6.10`, `12.4.2`, `16`) over suffixed variants (`-alpine`, `-beta`, `-rc*`, `-nightly`).
2. **Avoid** tags like `latest`, `stable`, `edge`, `nightly`, `main`, `master`, `canary`, `dev`.
3. For images published with both a full semver and a major-only shorthand (e.g. `16.3` and `16`), use the **most specific stable tag** (`16.3`), unless the repo's convention is to pin only the major (check the image readme).

### Images that require a registry URL prefix

| Registry | URL prefix | Example |
|---|---|---|
| Docker Hub | *(none)* | `prom/prometheus:v3.2.1` |
| GitHub Container Registry | `ghcr.io/` | `ghcr.io/berriai/litellm:v1.82.0-stable` |
| NVIDIA NGC | `nvcr.io/nvidia/` | `nvcr.io/nvidia/k8s/dcgm-exporter:4.5.2-4.8.1-ubuntu22.04` |
| Google Container Registry | `gcr.io/` | `gcr.io/cadvisor/cadvisor:v0.51.0` |

For non-Docker-Hub registries, fetch the tags page from the respective registry or the project's GitHub releases page.

## Lookup procedure

1. Fetch the tags API URL for the image.
2. Scan the returned tags for the latest entry that matches the selection rules above.
3. Write the image line as `image: <repo>/<image>:<resolved-tag>`.
4. If the API returns only digest-based or architecture-split tags and no human-readable semver, fall back to the project's GitHub releases page.

## Examples of correct lookups

```
# Prometheus
GET https://hub.docker.com/v2/repositories/prom/prometheus/tags?page_size=25&ordering=last_updated
→ pick e.g. v3.2.1
image: prom/prometheus:v3.2.1

# Grafana
GET https://hub.docker.com/v2/repositories/grafana/grafana/tags?page_size=25&ordering=last_updated
→ pick e.g. 12.4.2
image: grafana/grafana:12.4.2

# Postgres (official image)
GET https://hub.docker.com/v2/repositories/library/postgres/tags?page_size=25&ordering=last_updated
→ pick e.g. 17.4
image: postgres:17.4
```

## When to apply this skill

- Any new `image:` line being written
- Any existing `image: foo:latest` or `image: foo` found during a review or edit
- Before committing a new docker-compose.yml to the repo
