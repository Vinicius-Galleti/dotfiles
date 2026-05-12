#!/usr/bin/env bash
secs=$(( $(date +%s) - $(date -d 'today 00:00' +%s) ))
total=86400
pct=$(( secs * 100 / total ))
filled=$(( secs * 40 / total ))
bar=""
for ((i=0; i<filled; i++)); do bar="${bar}█"; done
for ((i=filled; i<40; i++)); do bar="${bar}░"; done
printf "DIA  %s  %d%%" "$bar" "$pct"
