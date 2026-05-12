#!/usr/bin/env bash
CACHE="$HOME/.cache/hyprlock-pet"
mkdir -p "$CACHE"

LAST_PET="$CACHE/last_pet"
COUNTER="$CACHE/counter"
[ -f "$COUNTER" ] || echo 0 > "$COUNTER"
[ -f "$LAST_PET" ] || date +%s > "$LAST_PET"

now=$(date +%s)
last=$(cat "$LAST_PET" 2>/dev/null || echo "$now")
count=$(cat "$COUNTER" 2>/dev/null || echo 0)
diff=$(( now - last ))

if   [ "$diff" -lt 4 ];   then state="happy"
elif [ "$diff" -lt 10 ];  then state="nominal"
elif [ "$diff" -lt 180 ]; then
    frame=$(( now / 4 % 4 ))
    case "$frame" in
        0) state="idle" ;;
        1) state="standby" ;;
        2) state="hmm" ;;
        3) state="idle" ;;
    esac
elif [ "$diff" -lt 900 ]; then state="standby"
else                            state="lost"
fi

case "$state" in
    happy)    printf '[ ✦ _ ✦ ]\nSYS: %s\n' "$count" ;;
    nominal)  printf '[ ◉ _ ◉ ]\nSYS: %s\n' "$count" ;;
    idle)     printf '[ ◉ _ ◉ ]\nSYS: %s\n' "$count" ;;
    scan)     printf '[ ▸ _ ◂ ]\nSYS: %s\n' "$count" ;;
    hmm)      printf '[ ◔ _ ◔ ]\nSYS: %s\n' "$count" ;;
    blink)    printf '[ • _ • ]\nSYS: %s\n' "$count" ;;
    standby)  printf '[ ─ _ ─ ]\nSYS: %s\n' "$count" ;;
    lost)     printf '[ × _ × ]\nSYS: %s\n' "$count" ;;
esac
