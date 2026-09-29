---
name: install-dev-setup
version: 2.0.0
description: |
  Interactive guide to install and configure the complete dev environment
  from the dev-setup repo. Runs setup.sh for automated steps, then walks
  through every manual step in order. Checks what's already installed and
  skips completed steps.
allowed-tools:
  - Bash
  - Read
---

# install-dev-setup

Interactive installation guide for the dev environment described in this repository. Run this skill from the root of the cloned `dev-setup` repo.

## Step 1 — Pre-flight check

Run these checks to understand the current state of the machine:

```bash
echo "=== System ===" && sw_vers -productVersion
echo "=== Homebrew ===" && command -v brew && brew --version | head -1 || echo "NOT INSTALLED"
echo "=== Git ===" && git --version
echo "=== Zsh ===" && zsh --version
echo "=== Oh My Zsh ===" && [ -d "$HOME/.oh-my-zsh" ] && echo "installed" || echo "NOT INSTALLED"
echo "=== mise ===" && mise --version 2>/dev/null || echo "NOT INSTALLED"
echo "=== Node ===" && node --version 2>/dev/null || echo "NOT INSTALLED"
echo "=== Java ===" && java -version 2>&1 | head -1 || echo "NOT INSTALLED"
echo "=== Python ===" && python3 --version 2>/dev/null || echo "NOT INSTALLED"
echo "=== Bun ===" && bun --version 2>/dev/null || echo "NOT INSTALLED"
echo "=== pipx ===" && pipx --version 2>/dev/null || echo "NOT INSTALLED"
echo "=== code-review-graph ===" && code-review-graph --version 2>/dev/null || echo "NOT INSTALLED"
echo "=== Claude Code ===" && claude --version 2>/dev/null || echo "NOT INSTALLED"
echo "=== VS Code ===" && code --version 2>/dev/null | head -1 || echo "NOT INSTALLED"
echo "=== gh ===" && gh --version | head -1 || echo "NOT INSTALLED"
echo "=== atuin ===" && atuin --version || echo "NOT INSTALLED"
echo "=== nvim ===" && nvim --version | head -1 || echo "NOT INSTALLED"
echo "=== lms (LM Studio) ===" && lms --version 2>/dev/null || echo "not installed"
echo "=== spicetify ===" && spicetify --version 2>/dev/null || echo "not installed"
echo "=== Docker ===" && docker --version 2>/dev/null || echo "NOT INSTALLED"
```

```bash
ls "$HOME/Projects/Personal/dev-setup" 2>/dev/null && echo "repo present" || echo "REPO NOT FOUND"
ls "$HOME/.claude.json" 2>/dev/null && echo "~/.claude.json exists" || echo "~/.claude.json missing"
```

Present a summary table of what is and isn't installed. Identify the REPO path (default: `~/Projects/Personal/dev-setup`).

If the repo is not present, stop and tell the user to clone it first:

```bash
mkdir -p ~/Projects/Personal
git clone git@github.com:atilio-ts/dev-setup ~/Projects/Personal/dev-setup
cd ~/Projects/Personal/dev-setup
```

## Step 2 — Run setup.sh

Run the automated setup script. This handles Homebrew, brew packages, shell, git, Neovim, nano, vim, atuin, gh, VS Code settings, Claude Code config, Spicetify, LaunchAgents, navi, macOS Dock, Claude skills, file-stash MCP, GitHub MCP, and claude-code-stats.

```bash
cd ~/Projects/Personal/dev-setup && bash setup.sh
```

This will take several minutes. Show output as it runs. After it completes, proceed to the manual steps below.

## Step 3 — Manual: update gitconfig

The repo gitconfig uses placeholder values. Update them now:

```bash
git config --global user.name "Atilio Villalba"
git config --global user.email "avillalba@fintech.works"
```

Verify:

```bash
git config --global user.name && git config --global user.email
```

## Step 4 — Manual: update settings.json absolute paths

The Claude Code `settings.json` was copied from the repo with `$HOME`-style paths. Update them to the actual username:

```bash
UNAME=$(whoami)
sed -i '' "s|\\\$HOME|/Users/$UNAME|g" "$HOME/.claude/settings.json"
grep -c "/Users/$UNAME" "$HOME/.claude/settings.json" && echo "paths updated"
```

## Step 5 — Manual: authenticate CLI tools

Run these sequentially (each requires interactive login):

```bash
gh auth login
```

```bash
atuin login
```

## Step 6 — Manual: version management with mise

This machine uses **mise** for both Node and Java version management.

Install mise if not present:

```bash
curl https://mise.run | sh
```

Install Node LTS:

```bash
mise install node@lts
mise use --global node@lts
node --version
```

Install Java (Amazon Corretto 21 and 24):

```bash
mise install java@corretto-21
mise install java@corretto-24
mise use --global java@corretto-21
java -version
```

## Step 7 — Manual: Python (mise)

Install the current Python version via mise:

```bash
mise install python@latest
mise use --global python@latest
python3 --version
```

## Step 8 — Manual: VS Code PATH command

Open VS Code, then:
`Cmd+Shift+P` → type `Shell Command: Install code command in PATH` → Enter

Verify:

```bash
code --version
```

## Step 9 — Manual: Claude Code setup

### Install Claude Code (if not installed)

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

### Log in

```bash
claude login
```

### Install Claude Code plugins

After first login, install the active plugins from the marketplace:

1. **coderabbit** — `coderabbit@claude-plugins-official`
2. **context-mode** — `context-mode@context-mode`
3. **token-optimizer** — `token-optimizer@alexgreensh-token-optimizer`
4. **caveman** — `caveman@caveman`
5. **ponytail** — `ponytail@ponytail`

### Set GITHUB_TOKEN for GitHub MCP

Add to `~/.zshrc` (if not already there):

```bash
export GITHUB_TOKEN="ghp_your_token_here"
```

Get a token at: GitHub → Settings → Developer settings → Personal access tokens

### Verify hooks are executable

```bash
chmod +x ~/.claude/hooks/*.sh
ls -la ~/.claude/hooks/
```

There should be 8 hooks: `pre-bash.sh`, `pre-websearch.sh`, `post-edit-encoding.sh`, `context-mode-cache-heal.mjs`, `code-review-graph-guard.sh`, `file-stash-guard.sh`, `prefer-search-tools-guard.sh`, `session-start-tool-reminders.sh`.

`settings.json` also wires most events (Notification, PermissionRequest, PostToolUse, Stop, etc.) to two third-party local tools — `~/.pixel-agents/hooks/claude-hook.js` and `~/.orca/agent-hooks/claude-hook.sh` — plus an iTerm2 status script. These aren't installed by this repo's `setup.sh`; both hook scripts no-op safely (`exit 0`) if the tool isn't present, so leaving them in `settings.json` is harmless on a machine that doesn't have `pixel-agents`/`orca`/iTerm2 installed. Install those tools separately only if you want the integration.

### Verify skills are linked

```bash
ls -la ~/.claude/skills/
```

Should include the project skills `sync-configuration`, `install-dev-setup` (discovered from this repo's `skills/` dir, not symlinked), plus symlinks for personal global skills — `context7-mcp` and `learned` should point into `dev-setup/claude/skills/`, matching the pattern used for skills like `commit-message` (which point into the sibling `claude-skills` repo). Re-create any missing symlink:

```bash
REPO="$HOME/Projects/Personal/dev-setup"
ln -s "$REPO/claude/skills/context7-mcp" "$HOME/.claude/skills/context7-mcp"
ln -s "$REPO/claude/skills/learned" "$HOME/.claude/skills/learned"
```

## Step 11 — Manual: pipx tools

```bash
pipx install code-review-graph
code-review-graph --version
```

## Step 12 — Manual: LM Studio CLI

If using LM Studio for local LLM inference (houtini-lm):

```bash
# Download LM Studio from https://lmstudio.ai/
# After installing, enable the CLI from LM Studio settings
lms --version
```

The `lms` binary should be at `~/.lmstudio/bin/lms`. The zshrc already adds this to PATH.

## Step 13 — Manual: apps that need a password prompt, and true manual installs

Docker Desktop, IntelliJ IDEA, Rider, WebStorm, LM Studio, Obsidian, Postman, Spotify and the rest of the GUI apps are all in the Brewfile now (Step 2's `brew bundle install` gets them — no JetBrains Toolbox, install each IDE cask directly). A handful of casks run a privileged `.pkg`/installer post-install step that needs `sudo` — these fail silently if Step 2 ran headless/non-interactively, so re-run them here from an interactive terminal if they're missing:

```bash
brew install --cask docker-desktop logitech-g-hub logi-options+ openvpn-connect realvnc-connect-viewer windows-app microsoft-teams
```

Verify:

```bash
for app in "Docker" "IntelliJ IDEA" "Rider" "WebStorm" "LM Studio" "Obsidian" "Postman" "Spotify" "Logitech G HUB" "Logi Options+" "OpenVPN Connect" "RealVNC Connect Viewer" "Windows App" "Microsoft Teams"; do
  [ -d "/Applications/$app.app" ] && echo "  installed: $app" || echo "  MISSING: $app"
done
```

Truly manual (no cask exists — download from vendor):

```bash
echo "FineTune:"; [ -d "/Applications/FineTune.app" ] && echo "  installed" || echo "  MISSING — https://www.finetuneapp.com"
echo "DBeaver Community:"; [ -d "/Applications/DBeaver.app" ] && echo "  installed" || echo "  MISSING — https://dbeaver.io/download/ (or brew install --cask dbeaver-community)"
```

## Step 14 — Terminal font for Powerlevel10k

If the prompt is showing garbled characters, install MesloLGS NF font:

```bash
brew install --cask font-meslo-lg-nerd-font
```

Then set your terminal (iTerm2 / Terminal.app / VS Code integrated terminal) to use **MesloLGS NF** and run:

```bash
p10k configure
```

## Step 15 — Final verification

```bash
echo "=== Shell ===" && echo $SHELL && echo $ZSH_VERSION
echo "=== Git user ===" && git config --global user.name && git config --global user.email
echo "=== Claude ===" && claude --version
echo "=== Agents ===" && ls ~/.claude/agents/ 2>/dev/null | wc -l | xargs echo "agents (expect 0):"
echo "=== Hooks ===" && ls ~/.claude/hooks/
echo "=== Node ===" && node --version && npm --version
echo "=== Java ===" && java -version 2>&1 | head -1
echo "=== Python ===" && python3 --version
echo "=== mise runtimes ===" && mise list
echo "=== pipx ===" && pipx list
echo "=== MCPs ===" && cat ~/.claude.json 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(list(d.get('mcpServers',{}).keys()))"
```

Present a final summary: what's configured, what still needs manual attention.

## Notes

- **mise**: Used for all runtime version management — Node, Java, and Python. No jenv or fnm on this machine.
- **Agents**: No custom agents are installed. The `~/.claude/agents/` directory should be empty.
- **Plugins**: 5 active plugins: `coderabbit`, `context-mode`, `token-optimizer`, `caveman`, `ponytail`. No ECC or fullstack-dev-skills.
- **Hooks**: 8 hooks total — `pre-bash.sh` (safety guards), `pre-websearch.sh` (search guard), `post-edit-encoding.sh` (encoding check), `context-mode-cache-heal.mjs` (SessionStart, fixes plugin cache path bug), `code-review-graph-guard.sh` (nudges toward code-review-graph over Glob/Grep), `file-stash-guard.sh` (nudges toward file-stash reads), `prefer-search-tools-guard.sh` (nudges toward rg/fd over grep/find), `session-start-tool-reminders.sh` (SessionStart, prints tool-priority reminders). `settings.json` additionally wires `pixel-agents`/`orca`/iTerm2 integrations — see "Verify hooks are executable" above.
- **Spicetify**: Requires Spotify to be installed first. Theme (Comfy) needs to be installed via Spicetify Marketplace after first launch.
- **claude-code-stats**: Config file at `~/Projects/Github/claude-code-stats/config.json` — update `display_name` and `plan_history` after install.
- **GITHUB_TOKEN**: Required for the GitHub MCP server. Without it, the MCP loads but API calls fail.
- **atuin login**: Requires an atuin account. History sync is optional — atuin works offline without login.
- **LM Studio**: Powers the `houtini-lm` MCP tool for local LLM inference. Start the local server in LM Studio before using houtini tools in Claude Code.
