---
name: install-dev-setup
version: 1.0.0
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

Run these checks in parallel to understand the current state of the machine:

```bash
echo "=== System ===" && sw_vers -productVersion
echo "=== Homebrew ===" && command -v brew && brew --version | head -1 || echo "NOT INSTALLED"
echo "=== Git ===" && git --version
echo "=== Zsh ===" && zsh --version
echo "=== Oh My Zsh ===" && [ -d "$HOME/.oh-my-zsh" ] && echo "installed" || echo "NOT INSTALLED"
echo "=== Node ===" && node --version 2>/dev/null || echo "NOT INSTALLED"
echo "=== fnm ===" && fnm --version 2>/dev/null || echo "not installed"
echo "=== jenv ===" && jenv --version 2>/dev/null || echo "not installed"
echo "=== pipx ===" && pipx --version 2>/dev/null || echo "NOT INSTALLED"
echo "=== code-review-graph ===" && code-review-graph --version 2>/dev/null || echo "NOT INSTALLED"
echo "=== Claude Code ===" && claude --version 2>/dev/null || echo "NOT INSTALLED"
echo "=== VS Code ===" && code --version 2>/dev/null | head -1 || echo "NOT INSTALLED"
echo "=== gh ===" && gh --version | head -1 || echo "NOT INSTALLED"
echo "=== atuin ===" && atuin --version || echo "NOT INSTALLED"
echo "=== nvim ===" && nvim --version | head -1 || echo "NOT INSTALLED"
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

## Step 6 — Manual: Node version management

This machine uses **fnm** (Fast Node Manager). Install and activate the current LTS:

```bash
fnm install --lts
fnm use lts-latest
fnm default lts-latest
node --version
```

If the machine uses **mise** instead:

```bash
curl https://mise.run | sh
mise install node@lts
```

## Step 7 — Manual: Java version management

This machine uses **jenv** with Corretto JDKs. Download from:
- [Amazon Corretto 21](https://docs.aws.amazon.com/corretto/latest/corretto-21-ug/downloads-list.html)
- [Amazon Corretto 24](https://docs.aws.amazon.com/corretto/latest/corretto-24-ug/downloads-list.html)

After installing the `.pkg` files:

```bash
jenv add /Library/Java/JavaVirtualMachines/amazon-corretto-21.jdk/Contents/Home
jenv add /Library/Java/JavaVirtualMachines/amazon-corretto-24.jdk/Contents/Home
jenv versions
jenv global 21
java -version
```

## Step 8 — Manual: VS Code PATH command

Open VS Code, then:
`Cmd+Shift+P` → type `Shell Command: Install code command in PATH` → Enter

Verify:

```bash
code --version
```

## Step 9 — Manual: clipboard cleaner daemon

Install the clipboard cleaner Python script and LaunchAgent:

```bash
mkdir -p ~/.local/bin
cp ~/Projects/Personal/dev-setup/shell/clipboard-cleaner.py ~/.local/bin/clipboard-cleaner.py
chmod +x ~/.local/bin/clipboard-cleaner.py
cp ~/Projects/Personal/dev-setup/launchagents/local.clipboard-cleaner.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/local.clipboard-cleaner.plist
```

Verify:

```bash
launchctl list | grep clipboard
```

## Step 10 — Manual: Claude Code setup

### Install Claude Code (if not installed)

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

### Log in

```bash
claude login
```

### Set GITHUB_TOKEN for GitHub MCP

Add to `~/.zshrc` (if not already there):

```bash
export GITHUB_TOKEN="ghp_your_token_here"
```

Get a token at: GitHub → Settings → Developer settings → Personal access tokens

### Verify skills are linked

```bash
ls ~/.claude/skills/
```

Should include: `sync-configuration`, `install-dev-setup`, and all skills from `claude-skills` repo.

## Step 11 — Manual: pipx tools

```bash
pipx install code-review-graph
code-review-graph --version
```

## Step 12 — Manual: apps to install manually

These require manual download and installation. Check and note which are missing:

```bash
echo "Docker Desktop:"; [ -d "/Applications/Docker.app" ] && echo "  installed" || echo "  MISSING — https://www.docker.com/products/docker-desktop/"
echo "JetBrains Toolbox:"; [ -d "/Applications/JetBrains Toolbox.app" ] && echo "  installed" || echo "  MISSING — https://www.jetbrains.com/toolbox-app/"
echo "Obsidian:"; [ -d "/Applications/Obsidian.app" ] && echo "  installed" || echo "  MISSING — https://obsidian.md/"
echo "Postman:"; [ -d "/Applications/Postman.app" ] && echo "  installed" || echo "  MISSING — https://www.postman.com/downloads/"
echo "Spotify:"; [ -d "/Applications/Spotify.app" ] && echo "  installed" || echo "  MISSING — https://www.spotify.com/download/"
```

## Step 13 — Terminal font for Powerlevel10k

If the prompt is showing garbled characters, install MesloLGS NF font:

```bash
brew install --cask font-meslo-lg-nerd-font
```

Then set your terminal (iTerm2 / Terminal.app / VS Code integrated terminal) to use **MesloLGS NF** and run:

```bash
p10k configure
```

## Step 14 — Final verification

```bash
echo "=== Shell ===" && echo $SHELL && echo $ZSH_VERSION
echo "=== Git user ===" && git config --global user.name && git config --global user.email
echo "=== Claude ===" && claude --version && ls ~/.claude/agents/ | wc -l | xargs echo "agents:"
echo "=== Node ===" && node --version && npm --version
echo "=== Java ===" && java -version 2>&1 | head -1
echo "=== pipx ===" && pipx list
echo "=== MCPs ===" && cat ~/.claude.json 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(list(d.get('mcpServers',{}).keys()))"
```

Present a final summary: what's configured, what still needs manual attention.

## Notes

- **mise**: Skipped by default on this machine — uses `jenv` (Java) and `fnm` (Node) instead. Only use mise if setting up a machine that doesn't have jenv/fnm.
- **Spicetify**: Requires Spotify to be installed first. Theme (Comfy) needs to be installed via Spicetify Marketplace after first launch.
- **claude-code-stats**: Config file at `~/Projects/Github/claude-code-stats/config.json` — update `display_name` and `plan_history` after install.
- **GITHUB_TOKEN**: Required for the GitHub MCP server. Without it, the MCP loads but API calls fail.
- **atuin login**: Requires an atuin account. History sync is optional — atuin works offline without login.
