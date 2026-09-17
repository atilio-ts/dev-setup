#!/usr/bin/env bash
# Nudges Read toward mcp__filestash__read_file for exploration, without breaking
# the Edit tool (which requires a prior native Read on the same file).
# First Read of a given path this session is denied; an immediate retry is allowed,
# so an edit-bound Read still succeeds after one extra round-trip.

[ -d "$HOME/.file-stash" ] || exit 0

input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name // empty')
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
session_id=$(echo "$input" | jq -r '.session_id // "default"')
[ -z "$file_path" ] && exit 0

state_file="/tmp/claude-filestash-guard-${session_id}.txt"
touch "$state_file"

if grep -Fxq "$file_path" "$state_file" 2>/dev/null; then
  exit 0
fi

echo "$file_path" >> "$state_file"
echo "Bloqueado (primer intento): usa mcp__filestash__read_file para exploracion de '$file_path'. Si vas a editar este archivo ahora, repite $tool y continua con Edit." >&2
exit 2
