---
name: sync-configuration
version: 2.0.0
description: |
  Sync the live machine configuration into the dev-setup backup repo.
  Diffs all tracked config files (Claude, shell, git, nvim, vscode, atuin,
  gh, spicetify) between the live system and the repo, flags regressions,
  copies live → repo, updates DEV_SETUP.md, and commits the result.
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

## Step 2 — Detect REPO-ONLY files (regressions)

Before diffing, check for files that exist in the repo but NOT on the live machine. These may indicate intentional deletions or configuration cleanup — flag them for the user to confirm before removing.

```bash
REPO="$HOME/Projects/Personal/dev-setup"

echo "=== REPO-ONLY hooks ==="
for f in "$REPO/claude/hooks/"*; do
  fname=$(basename "$f")
  [ -e "$HOME/.claude/hooks/$fname" ] || echo "  REPO-ONLY: claude/hooks/$fname"
done

echo "=== REPO-ONLY agents ==="
for f in "$REPO/claude/agents/"*.md 2>/dev/null; do
  [ -e "$f" ] || continue
  fname=$(basename "$f")
  [ -e "$HOME/.claude/agents/$fname" ] || echo "  REPO-ONLY: claude/agents/$fname"
done

echo "=== REPO-ONLY rules ==="
find "$REPO/claude/rules" -type f -name "*.md" | while read f; do
  rel="${f#$REPO/claude/rules/}"
  [ -e "$HOME/.claude/rules/$rel" ] || echo "  REPO-ONLY: claude/rules/$rel"
done
```

Present any REPO-ONLY findings to the user and confirm whether to delete them from the repo before proceeding.

## Step 3 — Diff all tracked files

Run these diffs and collect a findings list. Report `[ok]` or `[DIFF]` for each file.

### Claude config

```bash
REPO="$HOME/Projects/Personal/dev-setup"
diff "$REPO/claude/CLAUDE.md"             "$HOME/.claude/CLAUDE.md"             > /dev/null && echo "[ok] CLAUDE.md"             || echo "[DIFF] CLAUDE.md"
diff "$REPO/claude/settings.json"         "$HOME/.claude/settings.json"         > /dev/null && echo "[ok] settings.json"         || echo "[DIFF] settings.json"
diff "$REPO/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh" > /dev/null && echo "[ok] statusline-command.sh" || echo "[DIFF] statusline-command.sh"
diff "$REPO/claude/RTK.md"               "$HOME/.claude/RTK.md"                > /dev/null && echo "[ok] RTK.md"               || echo "[DIFF] RTK.md"
diff "$REPO/claude/houtini-ref.md"       "$HOME/.claude/houtini-ref.md"        > /dev/null && echo "[ok] houtini-ref.md"       || echo "[DIFF] houtini-ref.md"
```

```bash
REPO="$HOME/Projects/Personal/dev-setup"
# Hooks: discover dynamically, include .sh, .json, .md, .mjs
for f in "$HOME/.claude/hooks/"*; do
  fname=$(basename "$f")
  repo_f="$REPO/claude/hooks/$fname"
  [ -e "$repo_f" ] && { diff "$repo_f" "$f" > /dev/null 2>&1 && echo "[ok] hooks/$fname" || echo "[DIFF] hooks/$fname"; } \
    || echo "[NEW] hooks/$fname (not in repo yet)"
done
```

```bash
REPO="$HOME/Projects/Personal/dev-setup"
# Agents: discover dynamically (directory may be empty)
shopt -s nullglob
for f in "$HOME/.claude/agents/"*.md; do
  fname=$(basename "$f")
  repo_f="$REPO/claude/agents/$fname"
  [ -e "$repo_f" ] && { diff "$repo_f" "$f" > /dev/null 2>&1 && echo "[ok] agents/$fname" || echo "[DIFF] agents/$fname"; } \
    || echo "[NEW] agents/$fname (not in repo yet)"
done
shopt -u nullglob
```

```bash
REPO="$HOME/Projects/Personal/dev-setup"
# Rules: discover dynamically
find "$HOME/.claude/rules" -type f -name "*.md" | while read f; do
  rel="${f#$HOME/.claude/rules/}"
  repo_f="$REPO/claude/rules/$rel"
  [ -e "$repo_f" ] && { diff "$repo_f" "$f" > /dev/null 2>&1 && echo "[ok] rules/$rel" || echo "[DIFF] rules/$rel"; } \
    || echo "[NEW] rules/$rel (not in repo yet)"
done
```

```bash
REPO="$HOME/Projects/Personal/dev-setup"
# Global memory files
for f in "$HOME/.claude/memory/"*.md; do
  fname=$(basename "$f")
  repo_f="$REPO/claude/memory/$fname"
  [ -e "$repo_f" ] && { diff "$repo_f" "$f" > /dev/null 2>&1 && echo "[ok] memory/$fname" || echo "[DIFF] memory/$fname"; } \
    || echo "[NEW] memory/$fname (not in repo yet)"
done
```

### Other configs

```bash
REPO="$HOME/Projects/Personal/dev-setup"
diff "$REPO/shell/zshrc"               "$HOME/.zshrc"                                              > /dev/null && echo "[ok] zshrc"             || echo "[DIFF] zshrc"
diff "$REPO/shell/p10k.zsh"            "$HOME/.p10k.zsh"                                           > /dev/null && echo "[ok] p10k.zsh"          || echo "[DIFF] p10k.zsh"
diff "$REPO/shell/clipboard-cleaner.py" "$HOME/.local/bin/clipboard-cleaner.py"                   > /dev/null && echo "[ok] clipboard-cleaner" || echo "[DIFF] clipboard-cleaner.py"
diff "$REPO/git/gitignore_global"      "$HOME/.gitignore_global"                                   > /dev/null && echo "[ok] gitignore_global"  || echo "[DIFF] gitignore_global"
diff "$REPO/vscode/settings.json"      "$HOME/Library/Application Support/Code/User/settings.json"> /dev/null && echo "[ok] vscode/settings"   || echo "[DIFF] vscode/settings.json"
diff "$REPO/atuin/config.toml"         "$HOME/.config/atuin/config.toml"                           > /dev/null && echo "[ok] atuin/config.toml" || echo "[DIFF] atuin/config.toml"
diff "$REPO/gh/config.yml"             "$HOME/.config/gh/config.yml"                               > /dev/null && echo "[ok] gh/config.yml"     || echo "[DIFF] gh/config.yml"
diff "$REPO/nvim/init.lua"             "$HOME/.config/nvim/init.lua"                               > /dev/null && echo "[ok] nvim/init.lua"     || echo "[DIFF] nvim/init.lua"
diff "$REPO/spicetify/config-xpui.ini" "$HOME/.config/spicetify/config-xpui.ini"                  > /dev/null && echo "[ok] spicetify"         || echo "[DIFF] spicetify (likely version bump)"
```

Gitconfig — exclude machine-specific noise before comparing:

```bash
diff <(grep -v "name = YOUR\|email = YOUR\|git-commit-alias\|machineId" "$HOME/Projects/Personal/dev-setup/git/gitconfig") \
     <(grep -v "name = \|email = \|git-commit-alias\|machineId" "$HOME/.gitconfig") > /dev/null \
  && echo "[ok] gitconfig (substantive)" || echo "[DIFF] gitconfig (substantive change)"
```

## Step 4 — Present findings

Show the complete findings list to the user, grouped:
- **Claude** (CLAUDE.md, settings, hooks, agents, rules, memory)
- **Shell** (zshrc, p10k, clipboard-cleaner)
- **Git** (gitconfig, gitignore_global)
- **Editors** (nvim, vscode)
- **Tools** (atuin, gh, spicetify)

Flag any `[NEW]` items (on live but not in repo) and any REPO-ONLY items confirmed in Step 2. Ask the user to confirm before removing REPO-ONLY files.

If everything is `[ok]`, tell the user the repo is fully in sync and stop.

## Step 5 — Copy live → repo

For every file that shows `[DIFF]` or `[NEW]`, copy the live version to the repo.

### Claude config files

```bash
REPO="$HOME/Projects/Personal/dev-setup"
cp "$HOME/.claude/CLAUDE.md"             "$REPO/claude/CLAUDE.md"
cp "$HOME/.claude/settings.json"         "$REPO/claude/settings.json"
cp "$HOME/.claude/statusline-command.sh" "$REPO/claude/statusline-command.sh"
cp "$HOME/.claude/RTK.md"               "$REPO/claude/RTK.md"
cp "$HOME/.claude/houtini-ref.md"       "$REPO/claude/houtini-ref.md"
```

Hooks — copy all files from live, preserving any new extensions (.mjs etc.):

```bash
REPO="$HOME/Projects/Personal/dev-setup"
for f in "$HOME/.claude/hooks/"*; do
  cp "$f" "$REPO/claude/hooks/$(basename "$f")"
done
```

Agents — only copy if the directory is non-empty on live:

```bash
REPO="$HOME/Projects/Personal/dev-setup"
shopt -s nullglob
agents=("$HOME/.claude/agents/"*.md)
if [ ${#agents[@]} -gt 0 ]; then
  cp "${agents[@]}" "$REPO/claude/agents/"
else
  echo "No agents on live machine — agents directory stays empty in repo"
fi
shopt -u nullglob
```

Rules — mirror directory structure:

```bash
REPO="$HOME/Projects/Personal/dev-setup"
find "$HOME/.claude/rules" -type f -name "*.md" | while read f; do
  rel="${f#$HOME/.claude/rules/}"
  dest="$REPO/claude/rules/$rel"
  mkdir -p "$(dirname "$dest")"
  cp "$f" "$dest"
done
```

Memory files:

```bash
REPO="$HOME/Projects/Personal/dev-setup"
for f in "$HOME/.claude/memory/"*.md; do
  cp "$f" "$REPO/claude/memory/$(basename "$f")"
done
```

### Other config files

```bash
REPO="$HOME/Projects/Personal/dev-setup"
cp "$HOME/.zshrc"                                                            "$REPO/shell/zshrc"
cp "$HOME/.p10k.zsh"                                                         "$REPO/shell/p10k.zsh"
cp "$HOME/.local/bin/clipboard-cleaner.py"                                   "$REPO/shell/clipboard-cleaner.py"
cp "$HOME/.gitignore_global"                                                 "$REPO/git/gitignore_global"
cp "$HOME/.config/atuin/config.toml"                                         "$REPO/atuin/config.toml"
cp "$HOME/.config/gh/config.yml"                                             "$REPO/gh/config.yml"
cp "$HOME/.config/nvim/init.lua"                                             "$REPO/nvim/init.lua"
cp "$HOME/.config/nvim/lazy-lock.json"                                       "$REPO/nvim/lazy-lock.json"
cp "$HOME/.config/spicetify/config-xpui.ini"                                 "$REPO/spicetify/config-xpui.ini"
cp "$HOME/Library/Application Support/Code/User/settings.json"               "$REPO/vscode/settings.json"
```

Gitconfig — strip machine-specific sections and restore placeholders:

```bash
REPO="$HOME/Projects/Personal/dev-setup"
# Remove coderabbit section and machine-specific fields
awk '/^\[coderabbit\]/{skip=1} /^\[/ && !/^\[coderabbit\]/{skip=0} !skip' "$HOME/.gitconfig" \
  | grep -v "machineId\|git-commit-alias" \
  > "$REPO/git/gitconfig.tmp" \
  && mv "$REPO/git/gitconfig.tmp" "$REPO/git/gitconfig"

# Restore name/email placeholders
sed -i '' 's/^\tname = .*/\tname = YOUR_NAME/'   "$REPO/git/gitconfig"
sed -i '' 's/^\temail = .*/\temail = YOUR_EMAIL/' "$REPO/git/gitconfig"
```

## Step 6 — Update DEV_SETUP.md

After copying files, update `DEV_SETUP.md` to reflect the current state:
- Update the **date** at the top to today
- Update any plugin/tool lists if they changed (enabled plugins, hooks, etc.)
- Update the **Reinstall script** section if new tools were added or removed
- If agents were removed, update the Agents section to say "No custom agents configured"

Read the current file first, then edit only the sections that are out of date.

## Step 7 — Verify git status

```bash
git -C "$HOME/Projects/Personal/dev-setup" status
```

Show the list of modified and untracked files. If nothing changed, tell the user everything was already in sync.

## Step 8 — Commit

Use this commit message template:

```
chore(sync): sync live machine config to repo
```

With a body listing the sections that changed (e.g. `- claude: settings.json, hooks/context-mode-cache-heal.mjs`, `- shell: zshrc`).

Stage and commit:

```bash
git -C "$HOME/Projects/Personal/dev-setup" add -A
git -C "$HOME/Projects/Personal/dev-setup" commit -m "<message>"
```

Ask the user if they want to push to the remote before running `git push`.

## Notes

- **Never** copy `~/.claude/stats-cache.json`, `history.jsonl`, session files, or anything under `~/.claude/cache/`, `sessions/`, `telemetry/` — these are runtime data, not config.
- **gitconfig noise**: always strip `[oh-my-zsh] git-commit-alias` (plugin version hash) and `[coderabbit] machineId` — both are machine-specific and have no restore value.
- **gitconfig placeholders** — always restore `YOUR_NAME` / `YOUR_EMAIL` in the repo copy. The real values belong only in the live `~/.gitconfig`.
- **Empty agents dir** — if the live machine has no agents, leave `claude/agents/` empty in the repo (do not copy the directory itself, just ensure it's tracked).
- **REPO-ONLY files** — always check Step 2 before copying. Files in the repo that no longer exist locally usually mean the user intentionally removed them. Confirm before deleting.
- **Spicetify diffs** are usually just version bumps from auto-updates — include them anyway to keep the snapshot current.
- **settings.json unicode escapes** — if the Edit tool fails to match text in settings.json, the file may contain JSON unicode escapes (`&` for `&`, `>` for `>`). Use the Write tool to rewrite the whole file in that case.
