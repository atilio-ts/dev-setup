#!/usr/bin/env bash

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Calculate next quota reset time from fixed schedule: 00:00, 04:00, 09:00, 14:00, 19:00
# NOTE: this schedule is hardcoded — verify at https://claude.ai/settings if resets feel off
now_h=$(date +%H)
now_m=$(date +%M)
now_minutes=$(( now_h * 60 + now_m ))
reset_hours=(0 4 9 14 19)
next_reset_minutes=-1
for rh in "${reset_hours[@]}"; do
  candidate=$(( rh * 60 ))
  if [ "$candidate" -gt "$now_minutes" ]; then
    next_reset_minutes=$candidate
    break
  fi
done
if [ "$next_reset_minutes" -eq -1 ]; then
  next_reset_minutes=$(( 24 * 60 ))
fi
diff=$(( next_reset_minutes - now_minutes ))
if [ "$diff" -le 30 ]; then
  reset_warn=" (!)"
else
  reset_warn=""
fi
diff_h=$(( diff / 60 ))
diff_m=$(( diff % 60 ))
if [ "$diff_h" -gt 0 ]; then
  next_reset_str="in ${diff_h}h ${diff_m}m"
else
  next_reset_str="in ${diff_m}m"
fi

sep="  |  "

# Cost
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$total_cost" ]; then
  cost_str=$(printf '$%.3f' "$total_cost")
else
  cost_str="-"
fi

# Duration
total_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
if [ -n "$total_ms" ]; then
  total_s=$(( total_ms / 1000 ))
  if [ "$total_s" -lt 60 ]; then
    duration_str="${total_s}s"
  elif [ "$total_s" -lt 3600 ]; then
    duration_str="$(( total_s / 60 ))m"
  else
    duration_str="$(( total_s / 3600 ))h $(( (total_s % 3600) / 60 ))m"
  fi
else
  duration_str="-"
fi

# Lines changed
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')
if [ -n "$lines_added" ] && [ -n "$lines_removed" ]; then
  lines_str="+${lines_added}/-${lines_removed}"
else
  lines_str="-"
fi

if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  bar_filled=$(( used_int / 5 ))
  bar_empty=$(( 20 - bar_filled ))
  bar="["
  for i in $(seq 1 $bar_filled); do bar="${bar}#"; done
  for i in $(seq 1 $bar_empty); do bar="${bar}."; done
  bar="${bar}]"
  printf "◆ %s%s● ctx: %s %d%%%s✦ reset: %s%s%s$ cost: %s%s⚡ session: %s%s~ lines: %s" \
    "$model" "$sep" \
    "$bar" "$used_int" "$sep" \
    "$next_reset_str" "$reset_warn" "$sep" \
    "$cost_str" "$sep" \
    "$duration_str" "$sep" \
    "$lines_str"
else
  printf "◆ %s%s● ctx: [....................] --%s%s✦ reset: %s%s%s$ cost: %s%s⚡ session: %s%s~ lines: %s" \
    "$model" "$sep" \
    "%" "$sep" \
    "$next_reset_str" "$reset_warn" "$sep" \
    "$cost_str" "$sep" \
    "$duration_str" "$sep" \
    "$lines_str"
fi