---
name: sync-configuration
version: 2.0.0
description: |
  Sync the live machine configuration into the dev-setup backup repo.
  Diffs all tracked config files (Claude, shell, git, nvim, vscode, atuin,
  gh, spicetify) between the live system and the repo, flags regressions,
  copies live → repo, updates DEV_SETUP.md, and commits the result.
  Also the manual backup of ~/.claude/settings.json: the live file is a regular
  file and claude/settings.json is a copy refreshed here after a sensitive-data check.
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

echo "=== Claude config is symlinked: no REPO-ONLY check needed (see Step 3) ==="
```

```bash
echo "=== Global skills not yet tracked in repo ==="
for d in "$HOME/.claude/skills/"*/; do
  n=$(basename "$d")
  [ -L "${d%/}" ] && continue  # already a symlink, presumably into some repo — fine
  [ -e "$REPO/claude/skills/$n" ] || echo "  UNTRACKED real dir: ~/.claude/skills/$n (not a symlink, not in repo)"
done
```

Present any REPO-ONLY findings to the user and confirm whether to delete them from the repo before proceeding. `UNTRACKED real dir` findings are a different thing — see "Global skills" under Step 5.

## Step 3 — Diff all tracked files

Run these diffs and collect a findings list. Report `[ok]` or `[DIFF]` for each file.

### Claude config

`~/.claude` items are symlinks into `$REPO/claude/`, except `settings.json`, which is a regular file with a copy in the repo. Check the links, then diff `settings.json`:

```bash
REPO="$HOME/Projects/Personal/dev-setup"
for item in CLAUDE.md RTK.md statusline-command.sh rules hooks commands code-review-graph/languages.toml; do
  live="$HOME/.claude/$item"
  if [ -L "$live" ] && [ "$(readlink "$live")" = "$REPO/claude/$item" ]; then
    echo "[ok] $item"
  elif [ -e "$live" ]; then
    echo "[BROKEN LINK] $item is a regular file/dir — see Step 5"
  else
    echo "[MISSING] $item"
  fi
done
```

```bash
diff <(jq -S . "$HOME/.claude/settings.json") <(jq -S . "$REPO/claude/settings.json") > /dev/null && echo "[ok] settings.json" || echo "[DIFF] settings.json"
```

Before committing, confirm `claude/settings.json` has no organization-specific hosts, paths, or credentials (this repo is public):

```bash
rg -n -i '\.corp\.|\.internal\b|\.elb\.|amazonaws\.com|ghp_|ctx7sk|sk-ant-|Bearer ' "$HOME/Projects/Personal/dev-setup/claude/settings.json"
```

### Other configs

`zshrc` and `gitconfig` are hand-portabilized in the repo (`$HOME`, not `/Users/<user>/`) — see the warning under Step 5 before copying either. Diff them here just to detect that something changed, not to decide the copy is a straight `cp`.

```bash
REPO="$HOME/Projects/Personal/dev-setup"
diff "$REPO/shell/zshrc"               "$HOME/.zshrc"                                              > /dev/null && echo "[ok] zshrc"             || echo "[DIFF] zshrc"
diff "$REPO/shell/p10k.zsh"            "$HOME/.p10k.zsh"                                           > /dev/null && echo "[ok] p10k.zsh"          || echo "[DIFF] p10k.zsh"
diff "$REPO/git/gitignore_global"      "$HOME/.gitignore_global"                                   > /dev/null && echo "[ok] gitignore_global"  || echo "[DIFF] gitignore_global"
diff "$REPO/vscode/settings.json"      "$HOME/Library/Application Support/Code/User/settings.json"> /dev/null && echo "[ok] vscode/settings"   || echo "[DIFF] vscode/settings.json"
diff "$REPO/atuin/config.toml"         "$HOME/.config/atuin/config.toml"                           > /dev/null && echo "[ok] atuin/config.toml" || echo "[DIFF] atuin/config.toml"
diff "$REPO/gh/config.yml"             "$HOME/.config/gh/config.yml"                               > /dev/null && echo "[ok] gh/config.yml"     || echo "[DIFF] gh/config.yml"
diff "$REPO/nvim/init.lua"             "$HOME/.config/nvim/init.lua"                               > /dev/null && echo "[ok] nvim/init.lua"     || echo "[DIFF] nvim/init.lua"
diff "$REPO/spicetify/config-xpui.ini" "$HOME/.config/spicetify/config-xpui.ini"                  > /dev/null && echo "[ok] spicetify"         || echo "[DIFF] spicetify (likely version bump)"
diff "$REPO/tmux/tmux.conf"            "$HOME/.tmux.conf"                                          > /dev/null && echo "[ok] tmux.conf"         || echo "[DIFF] tmux.conf"
```

### Brewfile — installed-app manifest

```bash
REPO="$HOME/Projects/Personal/dev-setup"
brew bundle dump --force --file=/tmp/Brewfile.live
diff "$REPO/git/Brewfile" /tmp/Brewfile.live
```

> **Do not blindly copy this diff.** `mise`/`fnm`/`jenv` are a deliberate per-machine exception: this machine runs `fnm` + `jenv` instead of `mise` (see `DEV_SETUP.md` sections 6–7), but the repo's `Brewfile`/`setup.sh` intentionally keep `mise` as the default for *other* machines — never add `fnm`/`jenv` or remove `mise` from the tracked Brewfile because of a live diff on this machine. Everything else in the diff (new casks/formulae genuinely installed, taps, vscode extensions) is fair game to copy. Note also that `brew bundle dump` only lists leaves — a formula installed as someone else's dependency (like `tmux`, a dependency of `overmind`) won't show up even if you use it directly; check `brew info <name>` for `installed_on_request` before assuming it's missing.

### Terminal emulators & opencode

```bash
REPO="$HOME/Projects/Personal/dev-setup"
python3 -c "
import plistlib, json, subprocess
subprocess.run(['plutil','-convert','xml1','-o','/tmp/iterm_live.plist',
  '$HOME/Library/Preferences/com.googlecode.iterm2.plist'])
bm = plistlib.load(open('/tmp/iterm_live.plist','rb'))['New Bookmarks'][0]
allow = ('Ansi ','Background Color','Foreground Color','Cursor','Selection',
  'Bold Color','Link Color','Match Color','Badge Color','Tab Color',
  'Normal Font','Non Ascii Font','ASCII','Ambiguous','Use Bold','Use Bright',
  'Horizontal Spacing','Vertical Spacing','Blink','Minimum Contrast',
  'Cursor Boost','Unlimited Scrollback','Scrollback Lines','Silence Bell',
  'Visual Bell','Flashing Bell','Option Key Sends','Right Option')
safe = {k:v for k,v in bm.items() if k.startswith(allow)}
safe['Name'] = 'dev-setup'
safe['Guid'] = 'com.atilio.dev-setup.default'
json.dump({'Profiles':[safe]}, open('/tmp/iterm_live_profile.json','w'), indent=2, sort_keys=True)
"
diff "$REPO/iterm2/dynamic-profile.json" /tmp/iterm_live_profile.json > /dev/null && echo "[ok] iterm2/dynamic-profile.json" || echo "[DIFF] iterm2/dynamic-profile.json"
```

> **Never widen this to a full-domain plist export.** `defaults export com.googlecode.iterm2 -` (or converting the whole file with `plutil -convert json`) carries recent-directory and command history alongside the colors — always regenerate through the allowlist above, never `cp` the raw plist.

Terminal.app has no equivalent export path — `terminal/apply-terminal-theme.sh` is hand-maintained, only touch it when the theme itself changes, not on every sync.

opencode:

```bash
REPO="$HOME/Projects/Personal/dev-setup"
diff "$REPO/opencode/opencode.json" "$HOME/.config/opencode/opencode.json" > /dev/null && echo "[ok] opencode/opencode.json" || echo "[DIFF] opencode/opencode.json"
diff -rq "$REPO/opencode/commands" "$HOME/.config/opencode/commands" 2>&1
diff -rq "$REPO/opencode/agents"   "$HOME/.config/opencode/agents"   2>&1
diff -rq "$REPO/opencode/skills"   "$HOME/.config/opencode/skills"   2>&1
diff -rq "$REPO/opencode/plugins"  "$HOME/.config/opencode/plugins"  2>&1
```

> Never copy `~/.config/opencode/node_modules/`, `bun.lock`, `package-lock.json`, `.caveman-opencode-ownership.json`, or `opencode.json.bak` — generated/regenerable, not config.

Gitconfig — exclude machine-specific noise before comparing:

```bash
diff <(grep -v "name = YOUR\|email = YOUR\|git-commit-alias\|machineId" "$HOME/Projects/Personal/dev-setup/git/gitconfig") \
     <(grep -v "name = \|email = \|git-commit-alias\|machineId" "$HOME/.gitconfig") > /dev/null \
  && echo "[ok] gitconfig (substantive)" || echo "[DIFF] gitconfig (substantive change)"
```

## Step 4 — Present findings

Show the complete findings list to the user, grouped:
- **Claude** (CLAUDE.md, settings, hooks, agents, rules, memory)
- **Shell** (zshrc, p10k)
- **Git** (gitconfig, gitignore_global)
- **Editors** (nvim, vscode)
- **Tools** (atuin, gh, spicetify)

Flag any `[NEW]` items (on live but not in repo) and any REPO-ONLY items confirmed in Step 2. Ask the user to confirm before removing REPO-ONLY files.

If everything is `[ok]`, tell the user the repo is fully in sync and stop.

## Step 5 — Copy live → repo

For every file that shows `[DIFF]` or `[NEW]`, copy the live version to the repo.

**Exception — `zshrc` and `gitconfig`: never blind-copy.** The repo copies of these two files have hardcoded `/Users/<user>/` paths hand-rewritten to `$HOME` (portability — see repo memory `feedback_portable_paths`). Live's raw files use hardcoded paths in several spots. A straight `cp` regresses that. Instead: diff live against the *previous* live snapshot (or just read both) to find the *substantive* lines that changed (new tool block added/removed, version bumped, PATH addition) and hand-edit only those into the repo copy, keeping every path in `$HOME` form. Do the same in reverse for `gitconfig` — restore the `YOUR_NAME`/`YOUR_EMAIL` placeholders and `$HOME`-form `excludesfile` regardless of what live currently has.

### Global skills

Some personal skills under `~/.claude/skills/` are real directories rather than symlinks — meaning their content isn't backed up in any repo yet. For each one found by the Step 2 "Global skills not yet tracked" check:

```bash
REPO="$HOME/Projects/Personal/dev-setup"
mkdir -p "$REPO/claude/skills/<name>"
cp -r "$HOME/.claude/skills/<name>/"* "$REPO/claude/skills/<name>/" 2>/dev/null
# if the source dir is empty, at least track it:
touch "$REPO/claude/skills/<name>/.gitkeep"

# then re-link so it's never duplicated again:
mv "$HOME/.claude/skills/<name>" "$HOME/.claude/skills/.pre-symlink-backup/<name>"  # reversible, don't rm -rf
ln -s "$REPO/claude/skills/<name>" "$HOME/.claude/skills/<name>"
```

This matches the convention already used for skills like `commit-message`, `estimate`, etc., which symlink into the sibling `~/Projects/Personal/claude-skills` repo — the point is content lives in exactly one repo, `~/.claude/skills/<name>` is always just a pointer. `install-dev-setup` should set up the same symlinks on a fresh machine (see that skill).

### Claude config files

Copy `settings.json` if Step 3 reported `[DIFF]`, then run the sensitive-data check from Step 3:

```bash
cp "$HOME/.claude/settings.json" "$HOME/Projects/Personal/dev-setup/claude/settings.json"
```

The other items are symlinks, so the repo already holds the live files. Only repair a link reported as `[BROKEN LINK]` in Step 3 — move the live version into the repo, then re-link it:

```bash
REPO="$HOME/Projects/Personal/dev-setup"
item="CLAUDE.md"   # the item reported as broken
mv "$HOME/.claude/$item" "$REPO/claude/$item"
ln -s "$REPO/claude/$item" "$HOME/.claude/$item"
```

### Other config files

```bash
REPO="$HOME/Projects/Personal/dev-setup"
cp "$HOME/.zshrc"                                                            "$REPO/shell/zshrc"
cp "$HOME/.p10k.zsh"                                                         "$REPO/shell/p10k.zsh"
cp "$HOME/.gitignore_global"                                                 "$REPO/git/gitignore_global"
cp "$HOME/.config/atuin/config.toml"                                         "$REPO/atuin/config.toml"
cp "$HOME/.config/gh/config.yml"                                             "$REPO/gh/config.yml"
cp "$HOME/.config/nvim/init.lua"                                             "$REPO/nvim/init.lua"
cp "$HOME/.config/nvim/lazy-lock.json"                                       "$REPO/nvim/lazy-lock.json"
cp "$HOME/.config/spicetify/config-xpui.ini"                                 "$REPO/spicetify/config-xpui.ini"
cp "$HOME/Library/Application Support/Code/User/settings.json"               "$REPO/vscode/settings.json"
cp "$HOME/.tmux.conf"                                                        "$REPO/tmux/tmux.conf"
```

Brewfile — after reviewing the diff per the mise/fnm/jenv exception above:

```bash
REPO="$HOME/Projects/Personal/dev-setup"
cp /tmp/Brewfile.live "$REPO/git/Brewfile"
# then hand-restore the mise-vs-fnm/jenv lines if `brew bundle dump` picked up this
# machine's fnm/jenv formulae or dropped mise — see the note in Step 3.
```

iTerm2 dynamic profile and opencode config, generated/diffed in Step 3:

```bash
REPO="$HOME/Projects/Personal/dev-setup"
cp /tmp/iterm_live_profile.json "$REPO/iterm2/dynamic-profile.json"
cp "$HOME/.config/opencode/opencode.json" "$REPO/opencode/opencode.json"
cp "$HOME/.config/opencode/AGENTS.md"     "$REPO/opencode/AGENTS.md"
cp "$HOME/.config/opencode/package.json"  "$REPO/opencode/package.json"
for d in agents commands skills plugins; do
  rsync -a --delete "$HOME/.config/opencode/$d/" "$REPO/opencode/$d/" 2>/dev/null
done
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
- **Never track `~/.aws/credentials`, `~/.aws/config`, `~/.kube/config`, or anything under `~/.gnupg/`** — even when a file looks secret-free (e.g. `~/.aws/config` holding only profile names/regions), profile names have carried institutional/client identifiers before. Treat them the same as OCA/institutional repo paths: excluded from the GitHub remote, no exceptions. Document their existence in `DEV_SETUP.md` as prose (tool name, install command, one-time manual step like `aws-vault add <profile>`), never as a tracked file.
- **mise vs. fnm/jenv is a per-machine exception, not drift to fix.** See the Brewfile note in Step 3 — don't "fix" the live machine to match the repo, and don't change the repo to match a machine that's deliberately using the alternative.
- **gitconfig noise**: always strip `[oh-my-zsh] git-commit-alias` (plugin version hash) and `[coderabbit] machineId` — both are machine-specific and have no restore value.
- **gitconfig placeholders** — always restore `YOUR_NAME` / `YOUR_EMAIL` in the repo copy. The real values belong only in the live `~/.gitconfig`.
- **REPO-ONLY files** — always check Step 2 before copying. Files in the repo that no longer exist locally usually mean the user intentionally removed them. Confirm before deleting.
- **Spicetify diffs** are usually just version bumps from auto-updates — include them anyway to keep the snapshot current.
- **settings.json unicode escapes** — if the Edit tool fails to match text in settings.json, the file may contain JSON unicode escapes (`&` for `&`, `>` for `>`). Use the Write tool to rewrite the whole file in that case.
- **Third-party tool hooks in settings.json** (e.g. `~/.pixel-agents/...`, `~/.orca/...`) — copy as-is, they're a faithful machine snapshot and both are written to no-op safely when their server/registry is absent. Note in DEV_SETUP.md that these are optional integrations tied to tools this repo's `setup.sh` doesn't install — a new machine's owner decides independently whether to set them up.
