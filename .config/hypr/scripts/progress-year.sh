#!/usr/bin/env bash
year=$(date +%Y)
secs=$(( $(date +%s) - $(date -d "${year}-01-01 00:00" +%s) ))
total=$(( $(date -d "$((year+1))-01-01 00:00" +%s) - $(date -d "${year}-01-01 00:00" +%s) ))
pct=$(( secs * 100 / total ))
filled=$(( secs * 40 / total ))
bar=""
for ((i=0; i<filled; i++)); do bar="${bar}█"; done
for ((i=filled; i<40; i++)); do bar="${bar}░"; done
printf "ANO  %s  %d%%" "$bar" "$pct"
