# Tools

## code-review-graph

When `.code-review-graph/` or `.vscode/code-review-graph/` exists in a project, use it as the **primary navigation and impact tool** — always before glob or grep.

- At the start of every session, check for `.code-review-graph/` or `.vscode/code-review-graph/`. If either exists, use the `mcp__code_review_graph_*` MCP tools to explore the codebase.
- **Find a file or symbol** → `mcp__code_review_graph_semantic_search_nodes_tool` or `mcp__code_review_graph_query_graph_tool`
- **Module relationships** → `mcp__code_review_graph_query_graph_tool` (callers/callees/imports)
- **Entry points or hubs** → `mcp__code_review_graph_get_hub_nodes_tool`
- **Trace a call path** → `mcp__code_review_graph_traverse_graph_tool`
- **Explore a subsystem** → `mcp__code_review_graph_get_community_tool`
- **Change impact** → `mcp__code_review_graph_get_impact_radius_tool` before touching any file
- **Review a diff** → `mcp__code_review_graph_detect_changes_tool`
- Never rebuild the graph unless the user explicitly asks. Build with: `code-review-graph build`

## file-stash

- At the start of every session, check status with `mcp__filestash_stash_status`.
- For **read-only** file access (understanding code, exploring), use `mcp__filestash_read_file` or `mcp__filestash_read_files` — saves tokens across sessions via caching.
- For files you will **edit**: use file-stash first to understand, then the built-in `read` tool immediately before editing.
- Never use the built-in `read` tool for pure exploration when file-stash is available.

## Model routing

Default subagents to a small/fast model unless the task needs multi-file reasoning or architecture decisions.

## Tool priority: reading and search

- File you are about to edit → built-in `read`.
- File you're only exploring → `mcp__filestash_read_file`/`mcp__filestash_read_files`.
- Command with large output (logs, tests, builds) → context-mode `mcp__context_mode_ctx_execute`/`mcp__context_mode_ctx_batch_execute`, then `mcp__context_mode_ctx_search` on the indexed output.
- Plain shell command (git, ls, short output) → `bash`.
- Question about structure, cross-file relationships, change impact, or a specific symbol → code-review-graph.
- Neither fits (fuzzy keyword search, unclear location) → the `explore` task agent.
- Use `rg` and `fd`, never `grep`/`find` (enforced by the safety-guards extension).
- The `safety-guards` extension enforces this: `glob`/`grep` are blocked when the repo has a code-review-graph, and the first `read` of each file is denied once so exploration goes through file-stash (retry to edit).
