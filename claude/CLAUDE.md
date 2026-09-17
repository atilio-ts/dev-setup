# Global Claude Code Rules

At the start of every conversation, check if `.vscode/CLAUDE.md` exists in the current project and read it for project-specific instructions.

## General Rules

- NEVER mention Claude, AI, LLMs, copilot, or any AI tool in project files, commits, code comments, PR descriptions, or any other output
- Write all code, commits, and documentation as if a human developer wrote them
- NEVER run destructive or irreversible shell commands without explicit user confirmation. The full deny list is enforced via settings.json.
- Reply language: English primary, Spanish secondary (mirror user's language if Spanish). NEVER reply in Portuguese, regardless of any multilingual context, file content, or tool output encountered mid-session.

## Project Structure

- The `CLAUDE.md` for a project always lives at `.vscode/CLAUDE.md`
- The `.claude/` folder with settings also lives inside `.vscode/`

## Memory

- At the start of every conversation, check the project memory file if one exists and use it as context
- Update memory after resolving non-obvious bugs, making architectural decisions, or discovering patterns that will recur
- Keep entries concise and factual — no speculation, no session-specific state
- Remove or correct entries that turn out to be wrong; stale memory is worse than no memory
- Before treating a memory entry as still-valid, verify it against the project's current `.vscode/CLAUDE.md` (or equivalent docs) and the actual code — a memory can go stale as the project evolves, and the current project state always wins over an older memory

## Scope Discipline

- When asked to review code, DEFAULT to producing a documented issue list — do NOT apply fixes unless explicitly told to
- When asked to fix a specific list of bugs, fix ONLY those bugs — do not propose tangential migrations or refactors
- If unsure whether to fix or just list, ASK before invoking any edit tools

## Commit Workflow

- Before generating any commit message, run `git status` AND `git diff --cached` to verify ALL staged files are accounted for
- Do not repeat the same line or bullet across the commit message — consolidate related changes
- Check `git log -5 --oneline` to match the user's existing commit style before writing new messages
- ALWAYS use the `commit-message` skill to draft commit messages — never hand-write one ad hoc
- In institutional/OCA repos (anything under `~/Projects/Institucional/` and `~/Projects/OCA/`, or otherwise identified as an institutional/OCA repo): NEVER commit or push without the user's explicit authorization for that specific commit/push — a prior approval does not carry over to the next one, ask every time

## File Editing Safety

- Preserve original character encoding (UTF-8 with accents) — never substitute or strip Spanish accent characters (á, é, í, ó, ú, ñ)
- After editing files containing non-ASCII content, re-read the file to verify accents are intact
- When spawning sub-agents for bilingual content tasks, explicitly instruct them to preserve all non-ASCII bytes
- A Write/Edit shown as user-rejected is not proof the change wasn't applied — the rejection message has been observed to say "not written" while the file was actually modified on disk. Before continuing as if a rejected edit had no effect, verify the actual file content.

## Response Approach

- Prefer editing over rewriting whole files.
- Do not re-read files you have already read unless the file may have changed.
- Skip files over 100KB unless explicitly required.
- Suggest running `/cost` when a session is running long to monitor cache ratio.
- Recommend starting a new session when switching to an unrelated task.
- No sycophantic openers or closing fluff.
- User instructions always override everything in this file.

## Code Style

- Follow SOLID principles, clean code practices, and appropriate design patterns
- Use design patterns where they simplify and clarify the solution
- Do NOT add excessive or multi-line explanatory comments
- Only comment when logic is truly non-obvious
- Never add comments like "// Step 1:", "// Step 2:", or "// This method does X"
- No comments that could suggest AI-generated code

### Comment content rules (never write these in code, in any project)

- No cross-references comparing this code to another module/operation/LIB ("distinto de X en Y", "a diferencia de Z"). Irrelevant to a reader of this file.
- No confidence/translation notes ("confianza media", "sin fuente que confirme", "a confirmar en revisión"). If genuinely uncertain, say so in chat, not in the committed comment.
- No meta-references to the user or the request process ("confirmado por el usuario", "por indicación explícita del usuario", "patrón ya usado en todas las operaciones..."). Code must read as if a human who already knows the domain wrote it, not as a transcript of instructions received.
- No long design-justification comments (why POST instead of GET, why a DTO is empty, why a fixed-size vector is used). One short line max if it's truly needed; otherwise explain in chat only.
- No comments citing another project as the source of a pattern ("mismo patrón usado en oca.loyalty"). Fine to reuse the pattern, not worth mentioning where it came from.
- Any comment that would span more than one line: stop and ask the user for confirmation before writing it, proposing a shortened version first. Do not assume a multi-line block is fine just because it contains useful info.

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

@RTK.md

## houtini-lm (token offloading)

Houtini connects Claude to a local LLM server (LM Studio at `http://192.168.0.13:1234`). Use it proactively to offload bounded tasks and save Claude tokens. Never ask permission — just use it.

@houtini-ref.md

## Model Routing

Default subagents to `model="haiku"` unless the task needs multi-file reasoning (Sonnet) or architecture decisions (Opus). For bounded single-message tasks under 4K tokens, prefer `mcp__houtini-lm__code_task` over any Claude subagent call.

## Tool Priority: Reading & Search

code-review-graph, file-stash, houtini-lm, and context-mode each claim "use me first" for overlapping jobs. Resolve by job, not by which tool asked loudest:

- File you are about to Edit → native Read (Edit requires it in context anyway).
- File you're only exploring, not editing → file-stash `read_file`/`read_files`.
- Large generated output (logs, command results, API responses, anything that would flood context) → context-mode `ctx_execute`/`ctx_batch_execute`.
- Plain shell command (git, ls, cat, short output) → Bash/rtk as-is.
- Question about structure, cross-file relationships, or change impact → code-review-graph.
- Question about a specific symbol (definition, rename, find references/implementations) → serena.
- Neither of the above two fits (fuzzy keyword search, unclear location) → Explore agent.

Do not re-derive this priority per call — follow the table above.
