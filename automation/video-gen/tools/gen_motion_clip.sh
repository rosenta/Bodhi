#!/usr/bin/env bash
# gen_motion_clip.sh — thin wrapper around gen_motion_clip.py
# Usage: gen_motion_clip.sh <input_image> <output_mp4> [extra python args...]
set -euo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
exec python3 "${SCRIPT_DIR}/gen_motion_clip.py" "$@"
