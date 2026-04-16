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
# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
- If `graphify-out/graph.json` exists in the current project, use it to navigate the codebase — query it instead of doing blind file searches. Never rebuild the graph unless the user explicitly asks.

## cachebro

- At the start of every session, check cachebro status with `mcp__cachebro__cache_status`.
- Always use `mcp__cachebro__read_file` or `mcp__cachebro__read_files` instead of the built-in Read tool when reading project files. This saves tokens across sessions via caching.
- Never use the built-in Read tool for project files when cachebro is available.
