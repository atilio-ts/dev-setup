# Global Claude Code Rules

At the start of every conversation, check if `.vscode/CLAUDE.md` exists in the current project and read it for project-specific instructions.

## General Rules

- NEVER mention Claude, AI, LLMs, copilot, or any AI tool in project files, commits, code comments, PR descriptions, or any other output
- Write all code, commits, and documentation as if a human developer wrote them
- NEVER run destructive or irreversible shell commands without explicit user confirmation. Blocked commands include:
  - **Filesystem**: `rm -rf`, `rm -fr`, `shred`, `wipe`, `truncate`, `mkfs`, `dd if=`, `dd of=`, overwrites to `/etc/`, `/usr/`, `/bin/`
  - **Permissions**: `chmod 777`, `chown root`, `sudo chmod`, `sudo chown`
  - **Git — history rewrite**: `git reset --hard`, `git push --force`, `git push -f`, `git push --force-with-lease`, `git rebase -i`, `git rebase --onto`, `git filter-branch`, `git filter-repo`, `git commit --amend`
  - **Git — discard changes**: `git clean -f`, `git checkout .`, `git restore .`, `git checkout -- <file>`
  - **Git — delete**: `git branch -D`, `git branch -d`, `git tag -d`, `git push --delete`, `git push --prune`, `git remote remove`
  - **Git — reflog / config**: `git reflog delete`, `git reflog expire`, `git config --global`, `git config --system`
  - **Database**: `DROP TABLE`, `DROP DATABASE`, `DROP SCHEMA`, `TRUNCATE`, `DELETE FROM` without a restrictive WHERE clause
  - **Processes**: `kill -9`, `pkill`, `killall`
  - **Arbitrary code from network**: `curl * | sh`, `curl * | bash`, `wget * | sh`, `wget * | bash`
  - **Publishing**: `npm publish`, `pip publish`, `twine upload`, `cargo publish`, `gem push`
  - **Privilege escalation**: `sudo su`, `sudo -i`, `sudo bash`, `sudo sh`

## Project Structure

- The `CLAUDE.md` for a project always lives at `.vscode/CLAUDE.md`
- The `.claude/` folder with settings also lives inside `.vscode/`

## Commit Message Guidelines

Follow Conventional Commits with the project-specific rules below.

### Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Line length rules

- First line (type + description): max **50 characters**
- Body bullet points: max **80 characters** each
- Never wrap a bullet with an indented continuation — split into a new bullet instead

### When writing a commit message

1. Always run `git log` to read the full commit history including bodies and footers
2. Extract the team's real formatting patterns from that history
3. Use those patterns as the primary style guide, falling back to these rules only where the history gives no signal
4. Never mention Claude, AI, copilot, or any AI tool in the message
5. NEVER include "Co-Authored-By" or any AI attribution in footers

### Types

- `feature` — a new feature (use `feature`, NOT `feat`)
- `fix` — a bug fix
- `refactor` — code change that neither fixes a bug nor adds a feature
- `docs` — documentation changes only
- `style` — formatting, whitespace, missing semicolons (no logic change)
- `test` — adding or updating tests
- `perf` — performance improvements
- `build` — changes to build system or dependencies
- `ci` — changes to CI/CD configuration
- `chore` — other changes that don't affect src or tests

### Breaking Changes

- Append `!` after the type/scope: `feature!: drop support for Node 8`
- Or add `BREAKING CHANGE: <description>` in the footer

### Examples

```
feature(auth): add OAuth2 login support

fix: prevent race condition on request queue

feature: wire tokenizer skip into workflow

- CybersourceTokenizerDriver skips when brand is disabled
- returns DriverResult.skipped() instead of NOT_UPDATED per presentment
- CheckContinue supports next-step-when-skipped to route on skip

feature!: remove deprecated v1 endpoints

BREAKING CHANGE: /api/v1/presentments removed, use /api/v2
```

## Memory

- At the start of every conversation, check the project memory file if one exists and use it as context
- Update memory after resolving non-obvious bugs, making architectural decisions, or discovering patterns that will recur
- Keep entries concise and factual — no speculation, no session-specific state
- Remove or correct entries that turn out to be wrong; stale memory is worse than no memory

## Code Style

- Follow SOLID principles, clean code practices, and appropriate design patterns
- Use design patterns where they simplify and clarify the solution
- Do NOT add excessive or multi-line explanatory comments
- Only comment when logic is truly non-obvious
- Never add comments like "// Step 1:", "// Step 2:", or "// This method does X"
- No comments that could suggest AI-generated code

## graphify

When `graphify-out/graph.json` exists in a project, use it as the **primary navigation tool** — always before Glob or Grep.

- At the start of every session, check for `graphify-out/graph.json` with Glob. If it exists, use graphify tools to explore the codebase.
- **Find a file or symbol** → `mcp__graphify__query_graph` or `mcp__graphify__get_node` before reaching for Glob/Grep
- **Understand module relationships** → `mcp__graphify__get_neighbors` to see imports/dependencies
- **Find entry points or hubs** → `mcp__graphify__god_nodes` to identify high-degree nodes
- **Trace a call path** → `mcp__graphify__shortest_path` between two nodes
- **Explore a subsystem** → `mcp__graphify__get_community` to find related files
- Never rebuild the graph unless the user explicitly asks (`/graphify`)
- When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else

## file-stash

- At the start of every session, check file-stash status with `mcp__filestash__stash_status`.
- For **read-only** file access (understanding code, exploring), always use `mcp__filestash__read_file` or `mcp__filestash__read_files` — saves tokens across sessions via caching.
- For files you will **edit**: use file-stash first to understand, then call the built-in Read tool immediately before editing (the Edit tool requires a prior built-in Read).
- Never use the built-in Read tool for pure exploration when file-stash is available.

## houtini-lm (token offloading)

Houtini connects Claude to a local LLM server (LM Studio at `http://192.168.0.13:1234`). Use it proactively to offload bounded tasks and save Claude tokens. Never ask permission — just use it.

### Offload these tasks to houtini

| Task | Tool to use |
|------|-------------|
| Draft commit messages | `mcp__houtini-lm__chat` |
| Explain a function or module | `mcp__houtini-lm__code_task` |
| Code review of a single file | `mcp__houtini-lm__code_task` |
| Generate test stubs | `mcp__houtini-lm__code_task` |
| Write type definitions | `mcp__houtini-lm__code_task` |
| Generate mock/fixture data | `mcp__houtini-lm__chat` |
| Format conversion (JSON↔YAML, etc.) | `mcp__houtini-lm__chat` |
| Brainstorm approaches (non-committing) | `mcp__houtini-lm__chat` |
| Structured JSON output tasks | `mcp__houtini-lm__chat` with `json_schema` |
| Code analysis with full source | `mcp__houtini-lm__custom_prompt` |

### Keep on Claude

- Architectural decisions and planning
- Reading/writing/editing files (use file-stash + built-in tools)
- Running tests and interpreting results
- Multi-file refactoring
- Any task that requires calling other tools

### How to use

**`mcp__houtini-lm__code_task`** — best for code analysis:
- `code`: full source, never truncate
- `task`: "Find bugs", "Write tests for this", "Explain this function"
- `language`: "typescript", "python", etc.

**`mcp__houtini-lm__chat`** — general workhorse:
- Be explicit about output format
- Set `temperature: 0.1` for code, `0.3` for analysis, `0.7` for creative
- Use `json_schema` to force structured output

**`mcp__houtini-lm__custom_prompt`** — best for code review and analysis with context:
- `system`: short persona ("Senior TypeScript developer")
- `context`: full data to analyse
- `instruction`: what to produce, under 50 words

### Limits & concurrency

- **Max context per request: 4096 tokens** — never send more; truncate or summarise input if needed
- **One request at a time** — never fire parallel houtini calls; the local machine cannot handle concurrent LLM inference. Queue them sequentially
- Send complete code within the 4096-token budget — never truncate with `...`
- State output format explicitly ("Return a JSON array", "Bullet points only")
- Include imports and types as surrounding context for code generation
- Use `mcp__houtini-lm__discover` if unsure the server is available
- Use `mcp__houtini-lm__list_models` to see what models are loaded and their capabilities
