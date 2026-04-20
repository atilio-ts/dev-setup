# Global Claude Code Rules

At the start of every conversation, check if `.vscode/CLAUDE.md` exists in the current project and read it for project-specific instructions.

## General Rules

- NEVER mention Claude, AI, LLMs, copilot, or any AI tool in project files, commits, code comments, PR descriptions, or any other output
- Write all code, commits, and documentation as if a human developer wrote them
- NEVER run destructive or irreversible shell commands without explicit user confirmation. The full deny list is enforced via settings.json.

## Project Structure

- The `CLAUDE.md` for a project always lives at `.vscode/CLAUDE.md`
- The `.claude/` folder with settings also lives inside `.vscode/`

## Memory

- At the start of every conversation, check the project memory file if one exists and use it as context
- Update memory after resolving non-obvious bugs, making architectural decisions, or discovering patterns that will recur
- Keep entries concise and factual — no speculation, no session-specific state
- Remove or correct entries that turn out to be wrong; stale memory is worse than no memory

## Response Approach

- Think before acting. Read existing files before writing code.
- Be concise in output but thorough in reasoning.
- Prefer editing over rewriting whole files.
- Do not re-read files you have already read unless the file may have changed.
- Skip files over 100KB unless explicitly required.
- Suggest running `/cost` when a session is running long to monitor cache ratio.
- Recommend starting a new session when switching to an unrelated task.
- Test your code before declaring done.
- No sycophantic openers or closing fluff.
- Keep solutions simple and direct.
- User instructions always override everything in this file.

## Code Style

- Follow SOLID principles, clean code practices, and appropriate design patterns
- Use design patterns where they simplify and clarify the solution
- Do NOT add excessive or multi-line explanatory comments
- Only comment when logic is truly non-obvious
- Never add comments like "// Step 1:", "// Step 2:", or "// This method does X"
- No comments that could suggest AI-generated code

## code-review-graph

When `.code-review-graph/` exists in a project, use it as the **primary navigation and impact tool** — always before Glob or Grep.

- At the start of every session, check for `.code-review-graph/` with Glob. If it exists, use code-review-graph MCP tools to explore the codebase.
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

@RTK.md

## houtini-lm (token offloading)

Houtini connects Claude to a local LLM server (LM Studio at `http://192.168.0.13:1234`). Use it proactively to offload bounded tasks and save Claude tokens. Never ask permission — just use it.

@houtini-ref.md

## Compact Instructions

When compacting, preserve:
- houtini-lm tool names and offloading task table
- RTK: all bash commands auto-proxied via rtk hook
- Model routing: Haiku for workers/lightweight agents, Sonnet for main dev, Opus for architecture
- file-stash: use mcp__filestash__read_file before built-in Read for exploration
- Never mention AI/Claude/LLMs in any output, commit, or code comment
