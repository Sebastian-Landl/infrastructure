# Watchtower

Automatically pulls and redeploys updated Docker images for containers that opt in via a label.

## Setup

```bash
cp .env.example .env
docker compose up -d
```

## Schedule

`WATCHTOWER_SCHEDULE` uses a 6-field cron expression (`sec min hour dom mon dow`).  
Default `0 0 6 * * *` runs daily at 06:00.

## Opting containers in

Add the following label to any service you want Watchtower to watch:

```yaml
services:
  ollama:
    image: ollama/ollama:latest
    labels:
      - com.centurylinklabs.watchtower.enable=true
```

Containers **without** this label are ignored (enforced by the `--label-enable` flag).  
The `--cleanup` flag removes old images after a successful update.
