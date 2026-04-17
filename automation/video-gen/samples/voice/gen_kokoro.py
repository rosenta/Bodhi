#!/usr/bin/env python3
"""Generate Kokoro TTS samples."""
import sys
import soundfile as sf
from kokoro import KPipeline

TEXT = (
    "The man who knelt at the edge of the river had won everything. "
    "And yet. There was a hollowness behind his ribs that no achievement could fill. "
    "He closed his eyes. He asked the question he had been avoiding for twenty years. "
    "Who am I?"
)

def synth(voice: str, out_path: str) -> None:
    pipeline = KPipeline(lang_code="a")  # 'a' = American English
    generator = pipeline(TEXT, voice=voice, speed=0.9)
    chunks = []
    for _i, (_gs, _ps, audio) in enumerate(generator):
        chunks.append(audio)
    import numpy as np
    full = np.concatenate(chunks) if len(chunks) > 1 else chunks[0]
    sf.write(out_path, full, 24000)
    print(f"wrote {out_path}")

if __name__ == "__main__":
    voice = sys.argv[1]
    out = sys.argv[2]
    synth(voice, out)
