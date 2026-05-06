---
name: sync-configuration
version: 1.0.0
description: |
  Sync the live machine configuration into the dev-setup backup repo.
  Diffs all tracked config files (Claude, shell, git, nvim, vscode, atuin,
  gh, spicetify) between the live system and the repo, reports what is out
  of sync, copies live → repo, and commits the result.
  Skip mise — this machine uses jenv and fnm.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
---

# sync-configuration

Sync the live machine state into the dev-setup backup repo. Run this periodically from the dev-setup repo to keep the backup current.

## Step 1 — Locate the repo

```bash
REPO="$HOME/Projects/Personal/dev-setup"
echo "Repo: $REPO"
ls "$REPO"
```

Confirm the repo exists. If not, stop and tell the user to clone it first.

## Step 2 — Diff all tracked files

Run these diffs in parallel and collect a findings list. For each file, report `[ok]` or `[DIFF]` with a short description of what changed.

### Claude config

```bash
REPO="$HOME/Projects/Personal/dev-setup"
diff "$REPO/claude/CLAUDE.md"             "$HOME/.claude/CLAUDE.md"             > /dev/null && echo "[ok] CLAUDE.md"             || echo "[DIFF] CLAUDE.md"
diff "$REPO/claude/settings.json"         "$HOME/.claude/settings.json"         > /dev/null && echo "[ok] settings.json"         || echo "[DIFF] settings.json"
diff "$REPO/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh" > /dev/null && echo "[ok] statusline-command.sh" || echo "[DIFF] statusline-command.sh"
diff "$REPO/claude/RTK.md"               "$HOME/.claude/RTK.md"                > /dev/null && echo "[ok] RTK.md"               || echo "[DIFF] RTK.md"
diff "$REPO/claude/houtini-ref.md"       "$HOME/.claude/houtini-ref.md"        > /dev/null && echo "[ok] houtini-ref.md"       || echo "[DIFF] houtini-ref.md"
diff "$REPO/claude/AGENTS.md"            "$HOME/.claude/AGENTS.md"             > /dev/null && echo "[ok] AGENTS.md"            || echo "[DIFF] AGENTS.md (snapshot)"
diff "$REPO/claude/README.md"            "$HOME/.claude/README.md"             > /dev/null && echo "[ok] README.md (claude)"   || echo "[DIFF] README.md (claude snapshot)"
diff "$REPO/claude/marketplace.json"     "$HOME/.claude/marketplace.json"      > /dev/null && echo "[ok] marketplace.json"     || echo "[DIFF] marketplace.json (snapshot)"
diff "$REPO/claude/plugin.json"          "$HOME/.claude/plugin.json"           > /dev/null && echo "[ok] plugin.json"          || echo "[DIFF] plugin.json (snapshot)"
diff "$REPO/claude/PLUGIN_SCHEMA_NOTES.md" "$HOME/.claude/PLUGIN_SCHEMA_NOTES.md" > /dev/null && echo "[ok] PLUGIN_SCHEMA_NOTES.md" || echo "[DIFF] PLUGIN_SCHEMA_NOTES.md (snapshot)"
```

```bash
REPO="$HOME/Projects/Personal/dev-setup"
for f in "$REPO/claude/hooks/"*.{sh,json,md}; do
  fname=$(basename "$f")
  diff "$f" "$HOME/.claude/hooks/$fname" > /dev/null 2>&1 && echo "[ok] hooks/$fname" || echo "[DIFF] hooks/$fname"
done
for f in "$REPO/claude/agents/"*.md; do
  fname=$(basename "$f")
  diff "$f" "$HOME/.claude/agents/$fname" > /dev/null 2>&1 && echo "[ok] agents/$fname" || echo "[DIFF] agents/$fname"
done
for f in $(find "$REPO/claude/rules" -type f -name "*.md"); do
  rel="${f#$REPO/claude/rules/}"
  diff "$f" "$HOME/.claude/rules/$rel" > /dev/null 2>&1 && echo "[ok] rules/$rel" || echo "[DIFF] rules/$rel"
done
```

```bash
REPO="$HOME/Projects/Personal/dev-setup"
for f in "$REPO/claude/memory/"*.md; do
  fname=$(basename "$f")
  if [ "$fname" = "MEMORY.md" ]; then
    diff "$f" "$HOME/.claude/MEMORY.md" > /dev/null 2>&1 && echo "[ok] memory/MEMORY.md (→ ~/.claude/MEMORY.md)" || echo "[DIFF] memory/MEMORY.md"
  else
    diff "$f" "$HOME/.claude/memory/$fname" > /dev/null 2>&1 && echo "[ok] memory/$fname" || echo "[DIFF] memory/$fname"
  fi
done
```

### Other configs

```bash
REPO="$HOME/Projects/Personal/dev-setup"
diff "$REPO/shell/zshrc"            "$HOME/.zshrc"                                       > /dev/null && echo "[ok] zshrc"             || echo "[DIFF] zshrc"
diff "$REPO/shell/p10k.zsh"         "$HOME/.p10k.zsh"                                    > /dev/null && echo "[ok] p10k.zsh"          || echo "[DIFF] p10k.zsh"
diff "$REPO/shell/clipboard-cleaner.py" "$HOME/.local/bin/clipboard-cleaner.py"         > /dev/null && echo "[ok] clipboard-cleaner" || echo "[DIFF] clipboard-cleaner.py"
diff "$REPO/git/gitignore_global"   "$HOME/.gitignore_global"                            > /dev/null && echo "[ok] gitignore_global"  || echo "[DIFF] gitignore_global"
diff "$REPO/vscode/settings.json"   "$HOME/Library/Application Support/Code/User/settings.json" > /dev/null && echo "[ok] vscode/settings.json" || echo "[DIFF] vscode/settings.json"
diff "$REPO/atuin/config.toml"      "$HOME/.config/atuin/config.toml"                    > /dev/null && echo "[ok] atuin/config.toml" || echo "[DIFF] atuin/config.toml"
diff "$REPO/gh/config.yml"          "$HOME/.config/gh/config.yml"                        > /dev/null && echo "[ok] gh/config.yml"     || echo "[DIFF] gh/config.yml"
diff "$REPO/nvim/init.lua"          "$HOME/.config/nvim/init.lua"                        > /dev/null && echo "[ok] nvim/init.lua"     || echo "[DIFF] nvim/init.lua"
diff "$REPO/spicetify/config-xpui.ini" "$HOME/.config/spicetify/config-xpui.ini"       > /dev/null && echo "[ok] spicetify"         || echo "[DIFF] spicetify (likely version bump)"
```

Also check gitconfig for meaningful diffs (hash or new sections, ignoring name/email placeholders):

```bash
diff <(grep -v "name = YOUR\|email = YOUR" "$HOME/Projects/Personal/dev-setup/git/gitconfig") \
     <(grep -v "machineId\|name = \|email = " "$HOME/.gitconfig") > /dev/null \
  && echo "[ok] gitconfig (substantive)" || echo "[DIFF] gitconfig (substantive change)"
```

## Step 3 — Present findings

Show the complete findings list to the user. Group by section:
- **Claude** (CLAUDE.md, settings, hooks, agents, rules, memory, snapshots)
- **Shell** (zshrc, p10k, clipboard-cleaner)
- **Git** (gitconfig, gitignore_global)
- **Editors** (nvim, vscode)
- **Tools** (atuin, gh, spicetify)

If everything is `[ok]`, tell the user the repo is fully in sync and stop.

## Step 4 — Copy live → repo

For every file that shows `[DIFF]`, copy the live version to the repo. Run copies in parallel where possible.

### Claude config files

```bash
REPO="$HOME/Projects/Personal/dev-setup"
cp "$HOME/.claude/CLAUDE.md"             "$REPO/claude/CLAUDE.md"
cp "$HOME/.claude/settings.json"         "$REPO/claude/settings.json"
cp "$HOME/.claude/statusline-command.sh" "$REPO/claude/statusline-command.sh"
cp "$HOME/.claude/RTK.md"               "$REPO/claude/RTK.md"
cp "$HOME/.claude/houtini-ref.md"       "$REPO/claude/houtini-ref.md"
cp "$HOME/.claude/AGENTS.md"            "$REPO/claude/AGENTS.md"
cp "$HOME/.claude/README.md"            "$REPO/claude/README.md"
cp "$HOME/.claude/marketplace.json"     "$REPO/claude/marketplace.json"
cp "$HOME/.claude/plugin.json"          "$REPO/claude/plugin.json"
cp "$HOME/.claude/PLUGIN_SCHEMA_NOTES.md" "$REPO/claude/PLUGIN_SCHEMA_NOTES.md"
```

```bash
REPO="$HOME/Projects/Personal/dev-setup"
cp "$HOME/.claude/hooks/pre-bash.sh"           "$REPO/claude/hooks/pre-bash.sh"
cp "$HOME/.claude/hooks/pre-websearch.sh"      "$REPO/claude/hooks/pre-websearch.sh"
cp "$HOME/.claude/hooks/post-edit-encoding.sh" "$REPO/claude/hooks/post-edit-encoding.sh"
cp "$HOME/.claude/hooks/hooks.json"            "$REPO/claude/hooks/hooks.json"
cp "$HOME/.claude/hooks/README.md"             "$REPO/claude/hooks/README.md"
cp "$HOME/.claude/agents/"*.md                 "$REPO/claude/agents/"
cp "$HOME/.claude/rules/README.md"             "$REPO/claude/rules/README.md"
cp "$HOME/.claude/rules/common/"*.md           "$REPO/claude/rules/common/"
cp "$HOME/.claude/rules/kotlin/"*.md           "$REPO/claude/rules/kotlin/"
cp "$HOME/.claude/rules/python/"*.md           "$REPO/claude/rules/python/"
cp "$HOME/.claude/rules/typescript/"*.md       "$REPO/claude/rules/typescript/"
```

```bash
REPO="$HOME/Projects/Personal/dev-setup"
cp "$HOME/.claude/MEMORY.md"                        "$REPO/claude/memory/MEMORY.md"
cp "$HOME/.claude/memory/user_profile.md"           "$REPO/claude/memory/user_profile.md"
cp "$HOME/.claude/memory/feedback_filestash.md"     "$REPO/claude/memory/feedback_filestash.md"
cp "$HOME/.claude/memory/feedback_houtini.md"       "$REPO/claude/memory/feedback_houtini.md"
cp "$HOME/.claude/memory/feedback_file_editing.md"  "$REPO/claude/memory/feedback_file_editing.md"
```

### Other config files

```bash
REPO="$HOME/Projects/Personal/dev-setup"
cp "$HOME/.zshrc"                  "$REPO/shell/zshrc"
cp "$HOME/.p10k.zsh"               "$REPO/shell/p10k.zsh"
cp "$HOME/.local/bin/clipboard-cleaner.py" "$REPO/shell/clipboard-cleaner.py"
cp "$HOME/.gitignore_global"       "$REPO/git/gitignore_global"
cp "$HOME/.config/atuin/config.toml"        "$REPO/atuin/config.toml"
cp "$HOME/.config/gh/config.yml"            "$REPO/gh/config.yml"
cp "$HOME/.config/nvim/init.lua"            "$REPO/nvim/init.lua"
cp "$HOME/.config/nvim/lazy-lock.json"      "$REPO/nvim/lazy-lock.json"
cp "$HOME/.config/spicetify/config-xpui.ini" "$REPO/spicetify/config-xpui.ini"
cp "$HOME/Library/Application Support/Code/User/settings.json" "$REPO/vscode/settings.json"
```

For gitconfig: copy everything **except** the `[coderabbit]` section (machineId is machine-specific and should not be in the repo):

```bash
grep -v "^\[coderabbit\]" "$HOME/.gitconfig" | grep -v "machineId" > "$HOME/Projects/Personal/dev-setup/git/gitconfig.tmp" \
  && mv "$HOME/Projects/Personal/dev-setup/git/gitconfig.tmp" "$HOME/Projects/Personal/dev-setup/git/gitconfig"
```

Then restore the `YOUR_NAME` / `YOUR_EMAIL` placeholders in the repo copy (the real values stay in live only):

```bash
sed -i '' 's/^\tname = .*/\tname = YOUR_NAME/' "$HOME/Projects/Personal/dev-setup/git/gitconfig"
sed -i '' 's/^\temail = .*/\temail = YOUR_EMAIL/' "$HOME/Projects/Personal/dev-setup/git/gitconfig"
```

## Step 5 — Check for new memory files

Check if there are any `.md` files in `~/.claude/memory/` that are NOT yet in the repo:

```bash
for f in "$HOME/.claude/memory/"*.md; do
  fname=$(basename "$f")
  [ -f "$HOME/Projects/Personal/dev-setup/claude/memory/$fname" ] || echo "NEW memory file: $fname"
done
```

If new files are found, copy them to the repo as well.

## Step 6 — Verify git status

```bash
git -C "$HOME/Projects/Personal/dev-setup" status
```

Show the list of modified and untracked files. If nothing changed, tell the user everything was already in sync.

## Step 7 — Commit

Run the commit-message skill (`/commit-message`) to generate a commit message, or use this template:

```
chore(sync): sync live machine config to repo
```

With a body listing the sections that changed (e.g. `- claude: settings.json, statusline`, `- shell: zshrc`).

Then commit:

```bash
git -C "$HOME/Projects/Personal/dev-setup" add -A
git -C "$HOME/Projects/Personal/dev-setup" commit -m "<message>"
```

Ask the user if they want to push to the remote before running `git push`.

## Notes

- **Never** copy `~/.claude/stats-cache.json`, `history.jsonl`, session files, or anything under `~/.claude/cache/`, `sessions/`, `telemetry/` — these are runtime data, not config.
- **Skip mise** — this machine uses `jenv` and `fnm` for Java/Node version management.
- **gitconfig placeholders** — always restore `YOUR_NAME` / `YOUR_EMAIL` in the repo copy. The real values belong only in the live `~/.gitconfig`.
- **Spicetify diffs** are usually just version bumps from auto-updates — include them anyway to keep the snapshot current.
