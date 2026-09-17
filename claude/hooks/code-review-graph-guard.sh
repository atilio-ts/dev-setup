#!/usr/bin/env bash
# Hard-blocks Glob/Grep when the current repo has a real code-review-graph database.
# Only fires for an actual git repo with .code-review-graph (or .vscode/code-review-graph)
# at its root — avoids the $HOME false positive (global ~/.code-review-graph isn't a project graph).

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty')
[ -z "$cwd" ] && cwd="$PWD"
tool=$(echo "$input" | jq -r '.tool_name // empty')

git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
[ -z "$repo_root" ] && exit 0

if [ -d "$repo_root/.code-review-graph" ] || [ -d "$repo_root/.vscode/code-review-graph" ]; then
  echo "Bloqueado: este repo tiene code-review-graph. Usa mcp__code-review-graph__query_graph_tool / semantic_search_nodes_tool / get_impact_radius_tool en vez de $tool." >&2
  exit 2
fi

exit 0
