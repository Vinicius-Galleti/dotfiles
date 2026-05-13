#!/bin/bash

read_cpu_times() {
  read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
  echo "$((user+nice+system+idle+iowait+irq+softirq+steal)) $((user+nice+system+irq+softirq+steal))"
}
read t1 b1 <<< "$(read_cpu_times)"
sleep 0.3
read t2 b2 <<< "$(read_cpu_times)"
dt=$((t2 - t1))
db=$((b2 - b1))
if [ "$dt" -gt 0 ]; then
  usage=$(( db * 100 / dt ))
else
  usage=0
fi

hwmon=""
for h in /sys/class/hwmon/hwmon*; do
  if [ "$(cat "$h/name" 2>/dev/null)" = "coretemp" ]; then
    hwmon="$h"
    break
  fi
done

if [ -z "$hwmon" ] || [ ! -r "$hwmon/temp1_input" ]; then
  temp="--"
else
  temp_raw=$(cat "$hwmon/temp1_input")
  temp=$((temp_raw / 1000))
fi

class="normal"
if [ "$temp" != "--" ]; then
  if [ "$temp" -ge 85 ]; then
    class="critical"
  elif [ "$temp" -ge 75 ]; then
    class="warning"
  fi
fi

text="󰻠 ${usage}%  ${temp}°C"
tooltip="CPU\nUso: ${usage}%\nTemp: ${temp}°C"

echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\", \"class\": \"$class\"}"
