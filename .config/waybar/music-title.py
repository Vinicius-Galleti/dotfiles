#!/usr/bin/env python3
import subprocess
import time

MAX = 50
POLL = 0.3
GRACE = 0.6


def pc(*args):
    try:
        return subprocess.check_output(
            ["playerctl", *args],
            stderr=subprocess.DEVNULL,
            timeout=0.3,
        ).decode().strip()
    except Exception:
        return ""


def label():
    s = pc("status")
    if s not in ("Playing", "Paused"):
        return ""
    artist = pc("metadata", "artist")
    title = pc("metadata", "title")
    if artist and title:
        out = f"{artist} — {title}"
    else:
        out = title or artist
    if len(out) > MAX:
        out = out[: MAX - 1] + "…"
    return out


last_emit = None
empty_since = None

while True:
    cur = label()
    if cur:
        empty_since = None
        if cur != last_emit:
            print(cur, flush=True)
            last_emit = cur
    else:
        if empty_since is None:
            empty_since = time.monotonic()
        if time.monotonic() - empty_since >= GRACE and last_emit != "":
            print("", flush=True)
            last_emit = ""
    time.sleep(POLL)
