#!/usr/bin/env bash

input=$(cat)
query=$(echo "$input" | jq -r '.tool_input.query // empty')

jq -n --arg q "$query" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "ask",
    permissionDecisionReason: "🌐 Web Search\n\n  🔍 \($q)\n\n  ⚡ Tokens will be consumed — approve to continue."
  }
}'

exit 0