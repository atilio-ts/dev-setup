# Tools

## code-review-graph

When `.code-review-graph/` or `.vscode/code-review-graph/` exists in a project, use it as the **primary navigation and impact tool** — always before glob or grep.

- At the start of every session, check for `.code-review-graph/` or `.vscode/code-review-graph/`. If either exists, use the `code-review-graph_*` MCP tools to explore the codebase.
- **Find a file or symbol** → `code-review-graph_semantic_search_nodes_tool` or `code-review-graph_query_graph_tool`
- **Module relationships** → `code-review-graph_query_graph_tool` (callers/callees/imports)
- **Entry points or hubs** → `code-review-graph_get_hub_nodes_tool`
- **Trace a call path** → `code-review-graph_traverse_graph_tool`
- **Explore a subsystem** → `code-review-graph_get_community_tool`
- **Change impact** → `code-review-graph_get_impact_radius_tool` before touching any file
- **Review a diff** → `code-review-graph_detect_changes_tool`
- Never rebuild the graph unless the user explicitly asks. Build with: `code-review-graph build`

## file-stash

- At the start of every session, check status with `filestash_stash_status`.
- For **read-only** file access (understanding code, exploring), use `filestash_read_file` or `filestash_read_files` — saves tokens across sessions via caching.
- For files you will **edit**: use file-stash first to understand, then the built-in `read` tool immediately before editing.
- Never use the built-in `read` tool for pure exploration when file-stash is available.

## Model routing

Default subagents to a small/fast model unless the task needs multi-file reasoning or architecture decisions.

## Tool priority: reading and search

- File you are about to edit → built-in `read`.
- File you're only exploring → `filestash_read_file`/`filestash_read_files`.
- Command with large output (logs, tests, builds) → context-mode `ctx_execute`/`ctx_batch_execute`, then `ctx_search` on the indexed output.
- Plain shell command (git, ls, short output) → `bash`.
- Question about structure, cross-file relationships, change impact, or a specific symbol → code-review-graph.
- Neither fits (fuzzy keyword search, unclear location) → the `explore` subagent.
- Use `rg` and `fd`, never `grep`/`find` (enforced by the safety-guards plugin).
- The `safety-guards` plugin enforces this: `glob`/`grep` are blocked when the repo has a code-review-graph, and the first `read` of each file is denied once so exploration goes through file-stash (retry to edit).
