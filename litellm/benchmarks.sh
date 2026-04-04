#!/usr/bin/env bash
set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
BASE_URL="http://localhost:11434"
API_KEY="your-api-key"
MODELS=(
  "llama3.1:8b"
  "qwen2.5:14b"
  "mistral:7b"
)

# Output dir for results
RESULTS_DIR="./bench_results"
# ─────────────────────────────────────────────────────────────────────────────

mkdir -p "$RESULTS_DIR"

for MODEL in "${MODELS[@]}"; do
  # Sanitize model name for use as filename (replace : and / with -)
  SAFE_NAME="${MODEL//[:\/]/-}"
  OUTFILE="$RESULTS_DIR/${SAFE_NAME}.md"

  echo "━━━ Benchmarking: $MODEL → $OUTFILE"

  uvx llama-benchy \
    --base-url "$BASE_URL" \
    --api-key "$API_KEY" \
    --latency-mode generation \
    --runs 3 \
    --pp 2048 \
    --tg 2048 \
    --depth 2048 \
    --concurrency 1 \
    --format md \
    --save-result "$OUTFILE" \
    --model "$MODEL" \

  echo "━━━ Done: $MODEL"
  echo
done

echo "All benchmarks complete. Results in: $RESULTS_DIR"
