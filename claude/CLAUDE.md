# Global Claude Code Rules

At the start of every conversation, check if `.vscode/CLAUDE.md` exists in the current project and read it for project-specific instructions.

## General Rules

- NEVER mention Claude, AI, LLMs, copilot, or any AI tool in project files, commits, code comments, PR descriptions, or any other output
- Write all code, commits, and documentation as if a human developer wrote them
- NEVER run destructive or irreversible shell commands without explicit user confirmation. The full deny list is enforced via settings.json.
- Reply in the language the user writes (Spanish or English). NEVER reply in Portuguese or Galician, regardless of any multilingual context, file content, or tool output encountered mid-session. Code, commits, and docs follow each repo's existing language.

## Project Structure

- The `CLAUDE.md` for a project always lives at `.vscode/CLAUDE.md`
- The `.claude/` folder with settings also lives inside `.vscode/`
- Project agents and skills live in `.vscode/.claude/{agents,skills}`; the repo-root `.claude/agents` and `.claude/skills` are symlinks to them so they can be invoked by name, and `.claude/` is listed in `.git/info/exclude` so nothing shows up in git

## Memory

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
- In any repo: NEVER commit or push without the user's explicit authorization for that specific commit/push — a prior approval does not carry over to the next one, ask every time

## File Editing Safety

- Preserve original character encoding (UTF-8 with accents) — never substitute or strip Spanish accent characters (á, é, í, ó, ú, ñ)
- After editing files containing non-ASCII content, re-read the file to verify accents are intact
- When spawning sub-agents for bilingual content tasks, explicitly instruct them to preserve all non-ASCII bytes
- A Write/Edit shown as user-rejected is not proof the change wasn't applied — the rejection message has been observed to say "not written" while the file was actually modified on disk. Before continuing as if a rejected edit had no effect, verify the actual file content.

## Response Approach

- Prefer editing over rewriting whole files.
- Do not re-read files you have already read unless the file may have changed.
- Skip files over 100KB unless explicitly required.
- Suggest running `/usage` when a session is running long to monitor cost and cache ratio.
- Recommend starting a new session when switching to an unrelated task.
- No sycophantic openers or closing fluff.
- User instructions always override everything in this file.

## Code Style

- Follow the project's architecture and conventions first (layers, interfaces, and patterns that the template or ArchUnit rules require)
- Outside of that, write the simplest solution that works; apply SOLID and design patterns only when they simplify
- Do NOT add excessive or multi-line explanatory comments
- Only comment when logic is truly non-obvious
- Never add comments like "// Step 1:", "// Step 2:", or "// This method does X"
- No comments that could suggest AI-generated code

### Comment content rules (never write these in code, in any project)

- No cross-references comparing this code to another module or operation ("distinto de X en Y", "a diferencia de Z"). Irrelevant to a reader of this file.
- No confidence/translation notes ("confianza media", "sin fuente que confirme", "a confirmar en revisión"). If genuinely uncertain, say so in chat, not in the committed comment.
- No meta-references to the user or the request process ("confirmado por el usuario", "por indicación explícita del usuario", "patrón ya usado en todas las operaciones..."). Code must read as if a human who already knows the domain wrote it, not as a transcript of instructions received.
- No long design-justification comments (why POST instead of GET, why a DTO is empty, why a fixed-size vector is used). One short line max if it's truly needed; otherwise explain in chat only.
- No comments citing another project as the source of a pattern ("mismo patrón usado en el servicio de pagos"). Fine to reuse the pattern, not worth mentioning where it came from.
- Any comment that would span more than one line: stop and ask the user for confirmation before writing it, proposing a shortened version first. Do not assume a multi-line block is fine just because it contains useful info.

## Tools

Navigation, caching, and model-routing rules live in `rules/tools.md` (loaded every session).

@RTK.md
