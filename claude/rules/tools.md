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

## Search order

When the repo has a code-review-graph database, search in this order:

1. code-review-graph (`semantic_search_nodes_tool`, `query_graph_tool`, `get_impact_radius_tool`). `code-review-graph-guard.sh` blocks Glob/Grep, and blocks Bash `rg`/`fd`/`find` until a graph tool has been used in the session.
2. `rg` / `fd` / `find` for text, config and non-code files. The `rtk hook claude` hook rewrites `rg` and `find` to `rtk rg` and `rtk find` automatically, so output is already compacted; `fd` is not rewritten. Measured on this repo: `rtk rg` output is ~60% smaller than raw `rg`, `rtk find` ~65% smaller than raw `find` and ~70% smaller than `fd`, so prefer `rg`/`find` (rewritten) over `fd` unless plain paths are needed for piping.
3. `mcp__filestash__read_file(s)` for reading, native Read only right before an Edit.

## Context7

`context7-reminder.sh` (UserPromptSubmit) injects a reminder when the prompt names a library, framework or SDK and asks a how-to, config, migration, version or API question. Follow it: `resolve-library-id`, then `query-docs`, before answering from memory.
