#!/bin/bash

read usage temp mem_used mem_total <<< $(nvidia-smi \
  --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total \
  --format=csv,noheader,nounits | tr ',' ' ')

# Define classe pra estilizar quando esquentar
class="normal"
if [ "$temp" -ge 80 ]; then
  class="critical"
elif [ "$temp" -ge 70 ]; then
  class="warning"
fi

text="󰢮 ${usage}%  ${temp}°C"
tooltip="GPU NVIDIA\nUso: ${usage}%\nTemp: ${temp}°C\nVRAM: ${mem_used}/${mem_total} MiB"

echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\", \"class\": \"$class\"}"
