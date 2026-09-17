#!/usr/bin/env bash
# Reminds/enforces use of code-review-graph, filestash, and houtini-lm per ~/.claude/CLAUDE.md.
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

context="${context}REMINDER: Per CLAUDE.md, check file-stash status now with mcp__filestash__stash_status, and prefer mcp__filestash__read_file / read_files over the built-in Read tool for read-only exploration this session.
"

if curl -s -o /dev/null --max-time 1 "http://192.168.0.13:1234/v1/models"; then
  context="${context}REMINDER: houtini-lm (local LM Studio) is reachable. Per CLAUDE.md, offload bounded single-message tasks under 4K tokens to mcp__houtini-lm__code_task/chat/custom_prompt instead of a Claude subagent.
"
fi

if [ -n "$context" ]; then
  jq -n --arg ctx "$context" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
fi
