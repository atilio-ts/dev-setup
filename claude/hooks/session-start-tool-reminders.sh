#!/usr/bin/env bash
# Reminds to use code-review-graph when the repo has one.
# SessionStart hook: emits additionalContext only for tools that actually apply this session.

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty')
[ -z "$cwd" ] && cwd="$PWD"

context=""

repo_root=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
fi

if [ -n "$repo_root" ] && { [ -d "$repo_root/.code-review-graph" ] || [ -d "$repo_root/.vscode/code-review-graph" ]; }; then
  context="${context}REMINDER: This project has a code-review-graph database. Per CLAUDE.md, use mcp__code-review-graph__* tools (query_graph_tool, semantic_search_nodes_tool, get_impact_radius_tool, etc.) as the primary navigation/impact tool BEFORE Glob or Grep.
"
fi


if [ -n "$context" ]; then
  jq -n --arg ctx "$context" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
fi
