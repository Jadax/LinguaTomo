"""Generate original LinguaTomo feedback sound effects as WAV files.

These are synthesized from scratch (sine/triangle oscillators with simple
envelopes), so they are original work with no third-party licensing concerns.
They intentionally play a very short, gentle sound suitable for a calm,
child-friendly language app.

Output: assets/sounds/*.wav  (16-bit PCM mono)
"""

import math
import os
import struct
import wave

SR = 44100


def write_wav(path, samples):
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767)) for s in samples))


def env(n, total, attack=0.01, release=0.3):
    t = n / SR
    dur = total / SR
    a = min(1.0, t / attack) if attack > 0 else 1.0
    r = max(0.0, 1.0 - max(0.0, (t - (dur - release)) / release)) if release > 0 else 1.0
    return a * r


def tone_seq(freqs, dur_per=0.18, total=0.9, kind="sine"):
    N = int(total * SR)
    seg = int(dur_per * SR)
    out = []
    for n in range(N):
        idx = (n // seg) % len(freqs)
        f = freqs[idx]
        if kind == "triangle":
            ph = (n * f / SR) % 1.0
            s = 2.0 * abs(2.0 * (ph - math.floor(ph + 0.5))) - 1.0
        else:
            s = math.sin(2 * math.pi * f * n / SR)
        out.append(s * env(n, N))
    return out


def blip(freq, total=0.12):
    N = int(total * SR)
    out = []
    for n in range(N):
        s = math.sin(2 * math.pi * freq * n / SR)
        out.append(s * env(n, N, attack=0.002, release=total))
    return out


def main():
    out_dir = os.path.join(os.path.dirname(__file__), "..", "assets", "sounds")
    os.makedirs(out_dir, exist_ok=True)

    # Correct: gentle ascending major arpeggio (C5 E5 G5 C6).
    write_wav(os.path.join(out_dir, "correct.wav"),
              tone_seq([523.25, 659.25, 783.99, 1046.50], dur_per=0.14, total=0.72))

    # Wrong: soft low gentle tone, not harsh.
    write_wav(os.path.join(out_dir, "wrong.wav"),
              tone_seq([220.0, 174.61], dur_per=0.16, total=0.5, kind="triangle"))

    # Achievement: bright celebratory rising arpeggio.
    write_wav(os.path.join(out_dir, "achievement_chime.wav"),
              tone_seq([523.25, 659.25, 783.99, 1046.50, 1318.51], dur_per=0.16, total=1.0))

    # Lesson complete: warm fanfare.
    write_wav(os.path.join(out_dir, "lesson_complete.wav"),
              tone_seq([392.0, 523.25, 659.25, 783.99, 1046.50], dur_per=0.18, total=1.1))

    # Tap: tiny neutral click.
    write_wav(os.path.join(out_dir, "tap.wav"), blip(880.0, 0.08))

    # Page turn / open: gentle two-note bounce.
    write_wav(os.path.join(out_dir, "open.wav"),
              tone_seq([523.25, 659.25], dur_per=0.09, total=0.26))

    print("Generated sound effects in", out_dir)
    for f in sorted(os.listdir(out_dir)):
        if f.endswith(".wav"):
            full = os.path.join(out_dir, f)
            print(f"  {f}: {os.path.getsize(full)} bytes")


if __name__ == "__main__":
    main()
