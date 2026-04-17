#!/usr/bin/env python3
"""Generate Kokoro TTS samples via kokoro-onnx (no PyTorch needed)."""
import sys
import soundfile as sf
from kokoro_onnx import Kokoro

TEXT = (
    "The man who knelt at the edge of the river had won everything. "
    "And yet. There was a hollowness behind his ribs that no achievement could fill. "
    "He closed his eyes. He asked the question he had been avoiding for twenty years. "
    "Who am I?"
)

MODEL = "kokoro-models/kokoro-v1.0.onnx"
VOICES = "kokoro-models/voices-v1.0.bin"


def synth(voice: str, out_path: str, speed: float = 0.9) -> None:
    k = Kokoro(MODEL, VOICES)
    samples, sample_rate = k.create(TEXT, voice=voice, speed=speed, lang="en-us")
    sf.write(out_path, samples, sample_rate)
    print(f"wrote {out_path} at {sample_rate}Hz")


if __name__ == "__main__":
    voice = sys.argv[1]
    out = sys.argv[2]
    speed = float(sys.argv[3]) if len(sys.argv) > 3 else 0.9
    synth(voice, out, speed)
