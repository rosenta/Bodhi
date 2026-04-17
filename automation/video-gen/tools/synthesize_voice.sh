#!/usr/bin/env bash
# synthesize_voice.sh — synthesise a WAV from text.
# Usage: synthesize_voice.sh "<text>" <out.wav> [engine]
# engine = piper | say (default: auto — piper if PIPER_BIN set, else say)

set -euo pipefail

text="${1:?text required}"
out="${2:?out path required}"
engine="${3:-auto}"

if [[ "$engine" == "auto" ]]; then
  if [[ -n "${PIPER_BIN:-}" ]] && [[ -x "$PIPER_BIN" ]] && [[ -n "${PIPER_VOICE:-}" ]]; then
    engine="piper"
  else
    engine="say"
  fi
fi

case "$engine" in
  piper)
    printf '%s' "$text" | "$PIPER_BIN" \
      --model "$PIPER_VOICE" \
      --output_file "$out" >/dev/null
    ;;
  say)
    # macOS `say` → intermediate WAV (LEI16 requires .wav container), then normalise via ffmpeg
    tmp_wav=$(mktemp -t say_vo).wav
    # Voice choice — "Daniel" is a calm male English voice. Override via SAY_VOICE env.
    voice="${SAY_VOICE:-Daniel}"
    rate="${SAY_RATE:-175}"   # wpm, default 175 (macOS default ~200)
    say -v "$voice" -r "$rate" -o "$tmp_wav" --data-format=LEI16@22050 "$text"
    ffmpeg -y -loglevel error -i "$tmp_wav" -ar 44100 -ac 1 "$out"
    rm -f "$tmp_wav"
    ;;
  *)
    echo "unknown engine: $engine" >&2
    exit 2
    ;;
esac
