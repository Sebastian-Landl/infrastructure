Add containers that contribute models (e.g. ollama) to the `model_backend` network.

## Prometheus / Monitoring

LiteLLM exposes metrics at `GET /metrics` (port 4000).

The `litellm` container is attached to the external `monitoring` network so Prometheus (in the `monitoring` stack) can scrape it by container name (`litellm:4000`).
