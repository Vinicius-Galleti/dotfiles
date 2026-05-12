#!/usr/bin/env bash
mode="${1:-uptime}"
case "$mode" in
  uptime)
    up=$(uptime -p | sed -e 's/up //' -e 's/years/y/' -e 's/year/y/' -e 's/months/mo/' -e 's/month/mo/' -e 's/weeks/w/' -e 's/week/w/' -e 's/days/d/' -e 's/day/d/' -e 's/hours/h/' -e 's/hour/h/' -e 's/minutes/m/' -e 's/minute/m/' -e 's/, / /g')
    printf "  %s" "$up"
    ;;
  kernel)
    printf "  %s" "$(uname -r)"
    ;;
  mem)
    free -h --si | awk '/^Mem/ { printf "  %s / %s", $3, $2 }'
    ;;
  host)
    printf "  %s@%s" "$(whoami)" "$(hostname)"
    ;;
esac
