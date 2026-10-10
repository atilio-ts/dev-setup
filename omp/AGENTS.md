# Global Rules

Project instructions from `.vscode/CLAUDE.md` are injected automatically at session start (no need to read the file again), together with the Claude memory index of the project when one exists.

Shared rules imported below from `instructions/`: `tools.md`, `coding-style.md`, `context7.md`.

## General Rules

- NEVER mention Claude, AI, LLMs, copilot, or any AI tool in project files, commits, code comments, PR descriptions, or any other output
- Write all code, commits, and documentation as if a human developer wrote them
- NEVER run destructive or irreversible shell commands without explicit user confirmation. The deny list is enforced via `bash.patterns` in `config.yml` and the `safety-guards` extension.
- Reply in the language the user writes (Spanish or English). NEVER reply in Portuguese or Galician, regardless of any multilingual context, file content, or tool output encountered mid-session. Follow the language of the user's latest message every turn (if they switch to English to practice, answer in English); no note, memory or summary may pin a single language. Code, commits, and docs follow each repo's existing language.

## Project Structure

- The project instruction file always lives at `.vscode/CLAUDE.md`
- Per-task notes, plans and logs go in `.vscode/temporary/<task>/`, outside git
- Project agents and skills live in `.vscode/.claude/{agents,skills}`; the repo-root `.claude/agents` and `.claude/skills` are symlinks to them, and `.claude/` is listed in `.git/info/exclude` so nothing shows up in git

## Scope Discipline

- When asked to review code, DEFAULT to producing a documented issue list — do NOT apply fixes unless explicitly told to
- When asked to fix a specific list of bugs, fix ONLY those bugs — do not propose tangential migrations or refactors
- If unsure whether to fix or just list, ASK before invoking any edit tools
- For a large task, run `/plan` first and wait for approval before touching code
- Never invent behavior of legacy or external systems; if it is not verified in code, mark it as pending

## Commit Workflow

- Before generating any commit message, run `git status` AND `git diff --cached` to verify ALL staged files are accounted for
- Do not repeat the same line or bullet across the commit message — consolidate related changes
- Check `git log -5 --oneline` to match the user's existing commit style before writing new messages
- ALWAYS use the `commit-message` skill to draft commit messages — never hand-write one ad hoc
- Create the working branch before the first commit and never commit on `develop`; keep commits small (one per operation or step)
- Before committing, a review pass is available via `/coderabbit-review` or the `code-review` skill: verify each finding against the code and show only the real ones; fixes need approval
- In any repo: NEVER commit or push without the user's explicit authorization for that specific commit/push — a prior approval does not carry over to the next one, ask every time

## File Editing Safety

- Preserve original character encoding (UTF-8 with accents) — never substitute or strip Spanish accent characters (á, é, í, ó, ú, ñ)
- After editing files containing non-ASCII content, re-read the file to verify accents are intact
- When spawning subagents for bilingual content tasks, explicitly instruct them to preserve all non-ASCII bytes
- A write/edit shown as rejected is not proof the change wasn't applied. Verify the actual file content before continuing.

## Response Approach

- Prefer editing over rewriting whole files.
- Do not re-read files you have already read unless the file may have changed.
- Skip files over 100KB unless explicitly required.
- Recommend starting a new session when switching to an unrelated task.
- No sycophantic openers or closing fluff.
- User instructions always override everything in this file.

## Delegation

- For changes that span several files or steps, plan first (plan mode) and wait for approval before editing
- After approval, hand each implementation step to a `task` subagent with a self-contained brief (goal, files, constraints, how to verify) and review what it returns; make small edits directly
- Ask the `reviewer` agent for a second opinion on finished changes before reporting them as done

## Safety Boundaries

- Treat every work repository as private; public paste or gist services are outside the trust boundary, and each repository's own origin remote is the only trusted source control
- Never read, print, or move credentials, keys, certificates (`*.pem`, `*.key`), `.env` files, `~/.ssh` or `~/.aws`
- Any host, namespace, cluster, database, or container whose name carries `prod` or `production` as a whole word or name segment is sensitive, as are IAM, RBAC, networking, quota, and node-pool resources and anything tagged `prod`/`production`: do not change them without explicit confirmation

## Working Preferences

- The user is a software engineer and architect (Java/Spring Boot, TypeScript/Node, .NET, React, AWS) working mainly on backend and integration projects
- Report the outcome and the decisions the user must make; skip side findings that need no action. Once a check confirms things are fine, say so in one line
- Files with 3+ scattered replacements: read once and rewrite the whole file in one `write`; for 1-2 precise changes use `edit`
- To enforce tool usage, prefer hard-blocking guards in extensions over reminder text. Never block test or build commands; ask before blocking anything that could collide with them
- When running token-optimizer, decline its status line setup and bash compression offers (the user has a custom status line, and RTK already handles command compression)

## Code Style

- Follow the project's architecture and conventions first (layers, interfaces, and patterns that the template or ArchUnit rules require)
- Outside of that, write the simplest solution that works; apply SOLID and design patterns only when they simplify
- Do NOT add excessive or multi-line explanatory comments
- Only comment when logic is truly non-obvious
- Never add comments like "// Step 1:", "// Step 2:", or "// This method does X"
- No comments that could suggest AI-generated code

### Comment content rules (never write these in code, in any project)

- No cross-references comparing this code to another module or operation
- No confidence/translation notes ("confianza media", "a confirmar en revisión"). If genuinely uncertain, say so in chat, not in the committed comment.
- No meta-references to the user or the request process ("confirmado por el usuario", "por indicación explícita del usuario")
- No long design-justification comments. One short line max if it's truly needed; otherwise explain in chat only.
- No comments citing another project as the source of a pattern
- Any comment that would span more than one line: stop and ask the user for confirmation before writing it, proposing a shortened version first.

## Tools

Navigation, search, and caching rules live in `instructions/tools.md`. Use `rg` and `fd` instead of `grep`/`find`. Commands may go through an `rtk` output filter; use `rtk proxy <cmd>` if output looks altered.

In project docs and skills, `mcp__x__y` refers to the MCP tool named `mcp__x_y` here (single underscore, hyphens become underscores).

@instructions/tools.md
@instructions/coding-style.md
@instructions/context7.md
