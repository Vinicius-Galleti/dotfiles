#!/usr/bin/env python3
import html
import json
import os
import subprocess
import threading
import time

LEVELS = "▁▂▃▄▅▆▇█"
N_BARS = 13
PAUSED_BARS = "▅" * N_BARS

CONF = os.path.expanduser("~/.config/waybar/cava.conf")
BASS_BARS = (0, 1)
BASS_THRESHOLD = 5
MAX_LABEL = 50

_lock = threading.Lock()
_status = ""
_artist = ""
_title = ""
_album = ""


def _playerctl(*args):
    try:
        return subprocess.check_output(
            ["playerctl", *args],
            stderr=subprocess.DEVNULL,
            timeout=0.3,
        ).decode().strip()
    except Exception:
        return ""


def metadata_loop():
    global _status, _artist, _title, _album
    last_good_t = 0.0
    GRACE = 0.6
    while True:
        s = _playerctl("status")
        if s in ("Playing", "Paused"):
            artist = _playerctl("metadata", "artist")
            title = _playerctl("metadata", "title")
            album = _playerctl("metadata", "album")
            with _lock:
                _status, _artist, _title, _album = s, artist, title, album
            last_good_t = time.monotonic()
        else:
            if time.monotonic() - last_good_t > GRACE:
                with _lock:
                    _status, _artist, _title, _album = s, "", "", ""
        time.sleep(0.3)


threading.Thread(target=metadata_loop, daemon=True).start()


def make_label(artist, title):
    if artist and title:
        s = f"{artist} — {title}"
    else:
        s = title or artist
    if len(s) > MAX_LABEL:
        s = s[: MAX_LABEL - 1] + "…"
    return s


cava = subprocess.Popen(
    ["cava", "-p", CONF],
    stdout=subprocess.PIPE,
    stderr=subprocess.DEVNULL,
    text=True,
)

for line in cava.stdout:
    line = line.strip().rstrip(";")
    if not line:
        continue
    try:
        bars = [int(x) for x in line.split(";")]
    except ValueError:
        continue
    if len(bars) < N_BARS:
        continue
    bars = bars[:N_BARS]

    with _lock:
        status, artist, title, album = _status, _artist, _title, _album

    if status == "Playing":
        bars_text = "".join(LEVELS[min(max(b, 0), len(LEVELS) - 1)] for b in bars)
        has_bass = any(bars[i] >= BASS_THRESHOLD for i in BASS_BARS)
        cls = "bass" if has_bass else "playing"
        tooltip = html.escape(f"{artist} — {title}\n{album}".strip())
        print(json.dumps({"text": bars_text, "class": cls, "tooltip": tooltip}), flush=True)
    elif status == "Paused":
        tooltip = html.escape(f"⏸  {artist} — {title}".strip())
        print(json.dumps({"text": PAUSED_BARS, "class": "paused", "tooltip": tooltip}), flush=True)
    else:
        bars_text = "".join(LEVELS[min(max(b, 0), len(LEVELS) - 1)] for b in bars)
        print(json.dumps({"text": bars_text, "class": "idle", "tooltip": ""}), flush=True)
