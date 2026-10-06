# Tools

## code-review-graph

When `.code-review-graph/` or `.vscode/code-review-graph/` exists in a project, use it as the **primary navigation and impact tool** — always before Glob or Grep. Newer setups (via `--data-dir`) keep the database at `.vscode/code-review-graph/` instead of the repo root — check both.

- At the start of every session, check for `.code-review-graph/` or `.vscode/code-review-graph/` with Glob. If either exists, use code-review-graph MCP tools to explore the codebase.
- **Find a file or symbol** → `mcp__code-review-graph__semantic_search_nodes_tool` or `mcp__code-review-graph__query_graph_tool` before reaching for Glob/Grep
- **Understand module relationships** → `mcp__code-review-graph__query_graph_tool` (callers/callees/imports)
- **Find entry points or hubs** → `mcp__code-review-graph__get_hub_nodes_tool` to identify high-degree nodes
- **Trace a call path** → `mcp__code-review-graph__traverse_graph_tool` with BFS/DFS
- **Explore a subsystem** → `mcp__code-review-graph__get_community_tool` to find related files
- **Assess change impact** → `mcp__code-review-graph__get_impact_radius_tool` before touching any file
- **Review a PR or diff** → `mcp__code-review-graph__detect_changes_tool` for risk-scored impact analysis
- Never rebuild the graph unless the user explicitly asks. Build with: `code-review-graph build`

## file-stash

- At the start of every session, check file-stash status with `mcp__filestash__stash_status`.
- For **read-only** file access (understanding code, exploring), always use `mcp__filestash__read_file` or `mcp__filestash__read_files` — saves tokens across sessions via caching.
- For files you will **edit**: use file-stash first to understand, then call the built-in Read tool immediately before editing (the Edit tool requires a prior built-in Read).
- Never use the built-in Read tool for pure exploration when file-stash is available.

## Model routing

Default subagents to `model="haiku"` unless the task needs multi-file reasoning (Sonnet) or architecture decisions (Opus).

## Tool priority: reading and search

code-review-graph, file-stash, and context-mode each claim "use me first" for overlapping jobs. Resolve by job, not by which tool asked loudest:

- File you are about to Edit → native Read (Edit requires it in context anyway).
- File you're only exploring, not editing → file-stash `read_file`/`read_files`.
- Large generated output (logs, command results, API responses, anything that would flood context) → context-mode `ctx_execute`/`ctx_batch_execute`.
- Plain shell command (git, ls, cat, short output) → Bash/rtk as-is.
- Question about structure, cross-file relationships, change impact, or a specific symbol (definition, callers, references) → code-review-graph.
- Neither of the above fits (fuzzy keyword search, unclear location) → Explore agent.

Do not re-derive this priority per call — follow the list above.
