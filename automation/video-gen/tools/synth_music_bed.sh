#!/bin/bash
# Synthesize a contemplative ambient music bed using only ffmpeg.
# Layered drones (D2/A2/D3 fifths-octave shimmer) + pink-noise wash + soft heartbeat thumps.
# All synthesized — no network, no external models. Apt for Gate-1 reel sample.
set -euo pipefail

DUR="${1:-32}"
OUT="${2:-automation/video-gen/samples/music/ambient-drone-${DUR}s.mp3}"

mkdir -p "$(dirname "$OUT")"

# --- Step 1: render a single heartbeat thump (180ms, 70Hz, decaying)
HEARTBEAT_TMP="$(mktemp -t hb).wav"
ffmpeg -y -hide_banner -loglevel error \
  -f lavfi -i "sine=frequency=70:duration=0.18" \
  -af "afade=t=out:st=0.05:d=0.13,lowpass=f=140,volume=0.7" \
  "$HEARTBEAT_TMP"

# --- Step 2: render layered drones bed (no heartbeat yet)
DRONE_TMP="$(mktemp -t drone).wav"
DRONE_FILTER="$(mktemp -t dronefilter).txt"
cat > "$DRONE_FILTER" << 'EOF'
[0:a]volume=0.45,tremolo=f=0.18:d=0.25[d1];
[1:a]volume=0.30,tremolo=f=0.11:d=0.20[d2];
[2:a]volume=0.18,tremolo=f=0.10:d=0.15[d3];
[3:a]lowpass=f=600,volume=0.22[noise];
[d1][d2]amix=inputs=2:duration=longest:normalize=0[drone12];
[drone12][d3]amix=inputs=2:duration=longest:normalize=0[drones];
[drones][noise]amix=inputs=2:duration=longest:normalize=0[bg]
EOF

ffmpeg -y -hide_banner -loglevel error \
  -f lavfi -i "sine=frequency=73.42:duration=${DUR}" \
  -f lavfi -i "sine=frequency=110:duration=${DUR}" \
  -f lavfi -i "sine=frequency=146.83:duration=${DUR}" \
  -f lavfi -i "anoisesrc=duration=${DUR}:color=pink:amplitude=0.10" \
  -filter_complex_script "$DRONE_FILTER" \
  -map "[bg]" -c:a pcm_s16le "$DRONE_TMP"

# --- Step 3: mix drones with looped heartbeat, apply fades + loudnorm + final mp3
FADE_OUT_START=$(awk -v d="$DUR" 'BEGIN{print d-2}')
MIX_FILTER="$(mktemp -t mixfilter).txt"
cat > "$MIX_FILTER" << EOF
[1:a]apad,atrim=0:${DUR},asetpts=N/SR/TB,volume=0.45[heart];
[0:a][heart]amix=inputs=2:duration=longest:normalize=0,
    afade=t=in:st=0:d=2,
    afade=t=out:st=${FADE_OUT_START}:d=2,
    aformat=sample_fmts=fltp:channel_layouts=stereo,
    alimiter=limit=0.92,
    loudnorm=I=-22:TP=-2:LRA=8[mix]
EOF

ffmpeg -y -hide_banner -loglevel error \
  -i "$DRONE_TMP" \
  -stream_loop -1 -i "$HEARTBEAT_TMP" \
  -filter_complex_script "$MIX_FILTER" \
  -map "[mix]" -c:a libmp3lame -b:a 192k -ac 2 -ar 44100 "$OUT"

rm -f "$HEARTBEAT_TMP" "$DRONE_TMP" "$DRONE_FILTER" "$MIX_FILTER"

echo "[bed] wrote $OUT"
ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$OUT" \
  | awk '{printf "[bed] duration: %.2fs\n", $1}'
