#!/usr/bin/env bash
CACHE="$HOME/.cache/hyprlock-pet"
mkdir -p "$CACHE"

date +%s > "$CACHE/last_pet"
count=$(cat "$CACHE/counter" 2>/dev/null || echo 0)
echo $(( count + 1 )) > "$CACHE/counter"
