#!/usr/bin/env bash
# ollama_visual_query.sh — turn a verbose scene description into a 2-3 word
# stock-image search query using a local Ollama text model.
# Usage:   ollama_visual_query.sh "<scene visual description>"
# Prints a single short query to stdout. If Ollama is unreachable, prints the
# first 4 words of the input as a degraded fallback.

set -euo pipefail

visual="${1:?visual description required}"
model="${OLLAMA_MODEL:-llama3.2:3b}"

if ! command -v ollama >/dev/null 2>&1; then
  printf '%s' "$visual" | awk '{for(i=1;i<=4 && i<=NF;i++) printf "%s ", $i; print ""}'
  exit 0
fi

prompt=$(cat <<EOF
You convert a cinematic scene description into a SHORT stock-photo search query.

RULES:
- Output 2 to 4 English words only.
- Concrete nouns + an adjective if useful (e.g. "misty river dawn", "kneeling man silhouette").
- No punctuation. No quotes. No explanation. No trailing period.
- Lowercase.

Scene: ${visual}

Query:
EOF
)

# 10s timeout is plenty for llama3.2:3b
result=$(printf '%s' "$prompt" | ollama run "$model" 2>/dev/null | tr -d '\r' | head -n 1 || true)
# Strip any stray punctuation/quotes
result=$(printf '%s' "$result" | tr -d '".!?' | sed 's/^ *//; s/ *$//')

if [[ -z "$result" ]]; then
  printf '%s' "$visual" | awk '{for(i=1;i<=4 && i<=NF;i++) printf "%s ", $i; print ""}'
else
  printf '%s\n' "$result"
fi
