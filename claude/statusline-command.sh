#!/usr/bin/env bash

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

sep="  |  "

# Cost
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$total_cost" ]; then
  cost_str=$(printf '$%.3f' "$total_cost")
else
  cost_str="-"
fi

# Tokens
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
total_tokens=$(( input_tokens + output_tokens ))
if [ "$total_tokens" -gt 0 ]; then
  if [ "$total_tokens" -ge 1000000 ]; then
    tokens_str="$(echo "scale=1; $total_tokens / 1000000" | bc)M"
  elif [ "$total_tokens" -ge 1000 ]; then
    tokens_str="$(echo "scale=1; $total_tokens / 1000" | bc)k"
  else
    tokens_str="${total_tokens}"
  fi
else
  tokens_str="-"
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

# Context quality score from token-optimizer (per-session cache, falls back to the global one)
session_id=$(echo "$input" | jq -r '.session_id // empty')
q_dir="$HOME/.claude/token-optimizer"
q_file="$q_dir/quality-cache-${session_id}.json"
[ -f "$q_file" ] || q_file="$q_dir/quality-cache.json"
q_score=$(jq -r '.score // empty' "$q_file" 2>/dev/null)
q_str=""
if [ -n "$q_score" ]; then
  q_int=$(printf "%.0f" "$q_score")
  q_str="${sep}◎ ctxQ: ${q_int}"
fi

cm_bin=$(ls -d "$HOME"/.claude/plugins/cache/context-mode/context-mode/*/bin/statusline.mjs 2>/dev/null | sort -V | tail -1)
if [ -n "$cm_bin" ]; then
  cm_out=$(echo "$input" | node "$cm_bin" 2>/dev/null)
  case "$cm_out" in
    ""|*"saves ~98%"*) ;;
    *) q_str="${q_str}${sep}${cm_out}" ;;
  esac
fi

if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  printf "◆ %s%s● ctx: %d%%%s$ cost: %s%s⬡ tokens: %s%s⚡ session: %s%s~ lines: %s%s" \
    "$model" "$sep" \
    "$used_int" "$sep" \
    "$cost_str" "$sep" \
    "$tokens_str" "$sep" \
    "$duration_str" "$sep" \
    "$lines_str" "$q_str"
else
  printf "◆ %s%s● ctx: --%s%s$ cost: %s%s⬡ tokens: %s%s⚡ session: %s%s~ lines: %s%s" \
    "$model" "$sep" \
    "%" "$sep" \
    "$cost_str" "$sep" \
    "$tokens_str" "$sep" \
    "$duration_str" "$sep" \
    "$lines_str" "$q_str"
fi