#!/usr/bin/env bash

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')

destructive_patterns=(
  "git reset --hard"
  "git push --force"
  "git push -f "
  "git push -f$"
  "git clean -f"
  "git branch -D"
  "git checkout \."
  "git restore \."
  "rm -rf /"
  "rm -rf \*"
  "rm -rf \$"
  "rm -rf ~"
)

for pattern in "${destructive_patterns[@]}"; do
  if echo "$cmd" | grep -qE "$pattern"; then
    echo "Destructive command blocked: $cmd" >&2
    exit 2
  fi
done

exit 0