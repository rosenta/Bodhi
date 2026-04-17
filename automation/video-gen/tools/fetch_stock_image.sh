#!/usr/bin/env bash
# fetch_stock_image.sh — download a 1080x1920 stock image for a given query.
# Usage: fetch_stock_image.sh "<query>" <out_path>
# Free, no API key: uses source.unsplash.com (public CDN).
# Exits non-zero on failure (caller should fall back to a gradient).

set -euo pipefail

query="${1:-nature}"
out="${2:-./image.jpg}"

# URL-encode spaces and commas — good enough for the CDN
q=$(printf %s "$query" | sed 's/ /%20/g; s/,/%2C/g')

# Try unsplash source CDN first
url="https://source.unsplash.com/1080x1920/?${q}"
if curl -fsSL --max-time 15 -o "$out" -L "$url"; then
  # Sanity check: file exists and > 10KB
  if [[ -s "$out" ]] && [[ $(stat -f%z "$out" 2>/dev/null || stat -c%s "$out") -gt 10000 ]]; then
    exit 0
  fi
fi

# Fallback: picsum (no query match but valid image)
if curl -fsSL --max-time 15 -o "$out" "https://picsum.photos/1080/1920"; then
  if [[ -s "$out" ]] && [[ $(stat -f%z "$out" 2>/dev/null || stat -c%s "$out") -gt 10000 ]]; then
    exit 0
  fi
fi

exit 1
