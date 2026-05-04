#!/bin/bash
# Mix a Hindi voice-over with a music bed using ffmpeg sidechain compression (ducking).
# The music drops automatically when the voice speaks.
#
# Usage:
#   mix_vo_with_music.sh VO_FILE MUSIC_FILE OUT_FILE [VO_GAIN_DB] [MUSIC_GAIN_DB]
# Defaults: VO_GAIN_DB=0, MUSIC_GAIN_DB=-14
set -euo pipefail

VO="${1:?vo file required}"
MUSIC="${2:?music file required}"
OUT="${3:?output file required}"
VO_GAIN_DB="${4:-0}"
MUSIC_GAIN_DB="${5:--14}"

VO_DUR=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$VO")

# Strategy:
#  - Music: looped/trimmed to VO duration + 0.5s padding, gain -14dB baseline.
#  - VO: leave at 0dB, slight 200Hz HP filter to clean up rumble.
#  - Sidechain compress music against VO so music ducks ~6dB when VO plays.
#  - Add 0.4s fade-in / 0.8s fade-out on music tails.
#
# Filter graph:
#   [1]aloop=loop=-1:size=2e9,atrim=0:DUR+0.5,afade=in:0:9600,afade=out:st=DUR-0.5:d=0.5,volume=MUSIC_GAIN[bg]
#   [0]highpass=f=80,volume=VO_GAIN[vo]
#   [bg][vo]sidechaincompress=threshold=0.05:ratio=8:attack=80:release=400[ducked]
#   [ducked][vo]amix=inputs=2:duration=longest:dropout_transition=0[mix]

ffmpeg -y -hide_banner -loglevel error \
  -i "$VO" \
  -stream_loop -1 -i "$MUSIC" \
  -filter_complex "
    [1:a]atrim=0:$(awk -v d=$VO_DUR 'BEGIN{print d+0.5}'),asetpts=N/SR/TB,
         afade=t=in:st=0:d=0.4,
         afade=t=out:st=$(awk -v d=$VO_DUR 'BEGIN{print d-0.3}'):d=0.8,
         volume=${MUSIC_GAIN_DB}dB[bg];
    [0:a]highpass=f=80,volume=${VO_GAIN_DB}dB,asplit=2[vo1][vo2];
    [bg][vo1]sidechaincompress=threshold=0.06:ratio=8:attack=80:release=400[ducked];
    [ducked][vo2]amix=inputs=2:duration=longest:dropout_transition=0,
         alimiter=limit=0.95[mix]
  " \
  -map "[mix]" \
  -ac 2 -ar 44100 -c:a libmp3lame -b:a 192k \
  "$OUT"

echo "[mix] wrote $OUT"
ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$OUT" \
  | awk '{printf "[mix] duration: %.2fs\n", $1}'
