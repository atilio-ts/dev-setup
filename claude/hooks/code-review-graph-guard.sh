#!/usr/bin/env bash
# Forces code-review-graph first when the current repo has a real database.
# Glob/Grep: always blocked. Bash rg/fd/find/ag: blocked until a code-review-graph tool
# has been used this session (code-review-graph-mark.sh records it), unless every absolute/~ path
# in the command points outside the repo.
# Only fires for an actual git repo with .code-review-graph (or .vscode/code-review-graph)
# at its root — avoids the $HOME false positive (global ~/.code-review-graph isn't a project graph).

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty')
[ -z "$cwd" ] && cwd="$PWD"
tool=$(echo "$input" | jq -r '.tool_name // empty')
session_id=$(echo "$input" | jq -r '.session_id // "default"')

git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
[ -z "$repo_root" ] && exit 0

[ -d "$repo_root/.code-review-graph" ] || [ -d "$repo_root/.vscode/code-review-graph" ] || exit 0

if [ "$tool" = "Bash" ]; then
  [ -f "/tmp/claude-crg-used-${session_id}" ] && exit 0
  cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
  # An absolute/~ path in the command that is all outside this repo means the search targets something else.
  outside=0
  for tok in $(echo "$cmd" | tr -d "'\"" | tr -s '[:space:]' '\n' | grep -E '^(/|~|\$HOME)'); do
    tok="${tok/#\~/$HOME}"; tok="${tok/#\$HOME/$HOME}"
    case "$tok" in "$repo_root"|"$repo_root"/*) outside=0; break ;; *) outside=1 ;; esac
  done
  [ "$outside" -eq 1 ] && exit 0
  source "$(dirname "$0")/strip-quoted.sh"
  check=$(strip_quoted "$cmd" | sed -E 's/(&&|\|\||;)/\n/g')
  if echo "$check" | grep -qE '(^|[(`]|\$\()[[:space:]]*(rtk[[:space:]]+)?(rg|fd|fdfind|find|ag|ack)([[:space:]]|$)'; then
    echo "Bloqueado: este repo tiene code-review-graph. Consulta primero mcp__code-review-graph__semantic_search_nodes_tool / query_graph_tool / get_impact_radius_tool; despues de usar una, rg/fd/find quedan permitidos en esta sesion." >&2
    exit 2
  fi
  exit 0
fi

echo "Bloqueado: este repo tiene code-review-graph. Usa mcp__code-review-graph__query_graph_tool / semantic_search_nodes_tool / get_impact_radius_tool en vez de $tool." >&2
exit 2
