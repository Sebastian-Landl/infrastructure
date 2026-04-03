Add containers that contribute models (e.g. ollama) to the `model_backend` network.

## Prometheus / Monitoring

LiteLLM exposes metrics at `GET /metrics` (port 4000).

The `litellm` container is attached to the external `monitoring` network so Prometheus (in the `monitoring` stack) can scrape it by container name (`litellm:4000`).

## Benchmarking models

```bash
uvx llama-benchy --base-url <LITELLM_ENDPOINT> --api-key <API_KEY> --latency-mode generation --runs 3 --pp 2048 --tg 2048 --depth 2048 --concurrency 1 --model <MODEL_NAME>
```

Adapt as needed: https://github.com/eugr/llama-benchy?tab=readme-ov-file#arguments

`--pp` (Prompt Processing)
Number of input tokens to prefill. Measures how fast the model ingests a prompt. Higher = tests bulk ingestion throughput.

`--tg` (Token Generation)
Number of output tokens to generate. Measures autoregressive decode speed. This is the t/s number users actually experience.

`--depth` (Context Depth)
Tokens pre-loaded into the KV cache before the test runs. Simulates an ongoing conversation. Use multiple values (e.g. 0 8192 32768) to see how performance degrades as context fills up.
