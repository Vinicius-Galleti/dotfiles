#!/bin/bash
#
# Waybar GPU module — auto-detecta NVIDIA, AMD ou Intel.
# Em PC sem GPU dedicada, emite JSON vazio (módulo some).

if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi >/dev/null 2>&1; then
  # NVIDIA
  read -r usage temp mem_used mem_total <<< "$(nvidia-smi \
    --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total \
    --format=csv,noheader,nounits 2>/dev/null | tr ',' ' ')"

  class="normal"
  if [[ -n "$temp" && "$temp" -ge 80 ]]; then class="critical"
  elif [[ -n "$temp" && "$temp" -ge 70 ]]; then class="warning"; fi

  text="󰢮 ${usage}%  ${temp}°C"
  tooltip="GPU NVIDIA\nUso: ${usage}%\nTemp: ${temp}°C\nVRAM: ${mem_used}/${mem_total} MiB"
  echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\", \"class\": \"$class\"}"
  exit 0
fi

# AMD via /sys (kfd / amdgpu)
if [[ -d /sys/class/drm/card0/device ]] && [[ -e /sys/class/drm/card0/device/gpu_busy_percent ]]; then
  usage=$(cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null || echo "--")
  temp_file=$(find /sys/class/hwmon -name "temp1_input" -path "*amdgpu*" 2>/dev/null | head -1)
  if [[ -n "$temp_file" ]]; then
    temp=$(($(cat "$temp_file") / 1000))
  else
    temp="--"
  fi
  text="󰢮 ${usage}%  ${temp}°C"
  echo "{\"text\": \"$text\", \"tooltip\": \"GPU AMD\\nUso: ${usage}%\\nTemp: ${temp}°C\", \"class\": \"normal\"}"
  exit 0
fi

# Sem GPU dedicada detectada — esconde o módulo
echo '{"text": "", "tooltip": "", "class": "hidden"}'
