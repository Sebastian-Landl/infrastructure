#!/usr/bin/env bash
# scripts/download_tiktoken.sh
# Run this once on the host to populate the tiktoken_encodings/ volume.
# Only needed for openai/gpt-oss-* models.
#
# Usage:
#   bash scripts/download_tiktoken.sh

set -euo pipefail

DEST="${1:-./tiktoken_encodings}"
mkdir -p "$DEST"

ENCODINGS=(
  "https://openaipublic.blob.core.windows.net/encodings/o200k_base.tiktoken"
  "https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken"
)

for url in "${ENCODINGS[@]}"; do
  filename="$(basename "$url")"
  target="$DEST/$filename"
  if [ -f "$target" ]; then
    echo "Already exists, skipping: $filename"
  else
    echo "Downloading: $filename"
    wget -q --show-progress -O "$target" "$url"
  fi
done

echo ""
echo "Done. Files in $DEST:"
ls -lh "$DEST"
