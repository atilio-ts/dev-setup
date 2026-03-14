# Developer Setup — Atilio Villalba

> Last updated: 2026-03-14
> Goal: replicate this exact environment on a new macOS (Apple Silicon) machine from scratch.

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Homebrew](#2-homebrew)
3. [Shell — Zsh + Oh My Zsh + Powerlevel10k](#3-shell--zsh--oh-my-zsh--powerlevel10k)
4. [Terminal Tools & Aliases](#4-terminal-tools--aliases)
5. [Git](#5-git)
6. [Node.js — fnm + pnpm + bun](#6-nodejs--fnm--pnpm--bun)
7. [Java — jenv](#7-java--jenv)
8. [Neovim (LazyVim)](#8-neovim-lazyvim)
9. [Docker](#9-docker)
10. [JetBrains IDEs](#10-jetbrains-ides)
11. [VS Code](#11-vs-code)
12. [iTerm2](#12-iterm2)
13. [macOS Apps & System Config](#13-macos-apps--system-config)
14. [Claude Code](#14-claude-code)

---

## 1. System Overview

- **OS:** macOS (Apple Silicon — arm64)
- **Shell:** `/bin/zsh`
- **Default editor:** `nvim`
- **Package manager:** Homebrew (`/opt/homebrew`)

---

## 2. Homebrew

### Install

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Taps

```bash
brew tap lucassabreu/tap
brew tap sheeki03/tap
```

### Brewfile — one-command restore

A `~/Brewfile` is kept at the home directory. On a new machine, after installing Homebrew and adding taps, run:

```bash
brew bundle install --file=~/Brewfile
```

This installs all formulas and casks at once. To update the Brewfile after installing new packages:

```bash
brew bundle dump --file=~/Brewfile --force
```

> **Note:** `brew bundle dump` only captures explicitly installed packages, not those installed as dependencies. The manual formula list below is the authoritative reference — use it to cross-check after a bundle restore. Known gaps in the Brewfile: `python@3.13`, `python@3.14`, `tmux`, `bash`, `gradle-completion`, `openjdk` (25).

### Formulas

```bash
brew install \
  act \
  asimov \
  atuin \
  awscli \
  bash \
  bat \
  btop \
  cowsay \
  direnv \
  dive \
  eza \
  fd \
  fnm \
  fortune \
  fx \
  fzf \
  gh \
  git \
  git-delta \
  git-lfs \
  git-open \
  gnupg \
  gradle \
  gradle-completion \
  groovy \
  gum \
  hyperfine \
  jenv \
  jq \
  kubernetes-cli \
  lazydocker \
  lazygit \
  maven \
  minikube \
  mole \
  nano \
  navi \
  neovim \
  openjdk \
  openjdk@21 \
  overmind \
  powerlevel10k \
  python@3.13 \
  python@3.14 \
  ripgrep \
  spicetify-cli \
  telnet \
  tirith \
  tmux \
  tokei \
  trash \
  vcprompt \
  viddy \
  xh \
  yazi \
  zellij \
  zoxide \
  zsh-autosuggestions
```

> `zsh-syntax-highlighting` is installed as an Oh My Zsh custom plugin — see shell section.

After installing `git-lfs`, initialize it:
```bash
git lfs install
```

### Casks

```bash
brew install --cask \
  appcleaner \
  aws-vault-binary \
  claude-code \
  clockify-cli \
  font-meslo-for-powerlevel10k \
  itsycal \
  stats
```

---

## 3. Shell — Zsh + Oh My Zsh + Powerlevel10k

### Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Custom plugins (clone into `~/.oh-my-zsh/custom/plugins/`)

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

> Both plugins are also available as brew formulas (`brew install zsh-autosuggestions`), but the Oh My Zsh plugin versions are used here — loaded via the `plugins=()` array in `.zshrc`. Don't mix both sources.

### `~/.zshrc`

```zsh
# Powerlevel10k instant prompt — must stay near the top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ARM Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_COLORIZE_STYLE="colorful"

# Docker CLI completions (must be before oh-my-zsh)
fpath=(/Users/atilio/.docker/completions $fpath)

plugins=(
  git
  aws
  battery
  branch
  colored-man-pages
  colorize
  command-not-found
  copyfile
  docker
  docker-compose
  git-commit
  git-extras
  github
  gitignore
  gradle
  iterm2
  jira
  jsontools
  macos
  mvn
  node
  npm
  python
  sudo
  tldr
  vscode
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# fnm (Node version manager)
eval "$(fnm env --use-on-cd --shell zsh)"

# fzf shell integration
source <(fzf --zsh)

# zoxide (smart cd)
eval "$(zoxide init zsh)"

# pnpm
export PNPM_HOME="/Users/atilio/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/Users/atilio/.bun/_bun" ] && source "/Users/atilio/.bun/_bun"

# Default editor
export EDITOR=nvim
export VISUAL=nvim

# Python — prefer 3.13 (3.14 is pre-release)
export PATH="/opt/homebrew/opt/python@3.13/libexec/bin:$PATH"

# PATH extras
PATH=~/.console-ninja/.bin:$PATH
export PATH=/Users/atilio/.opencode/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"

# direnv
eval "$(direnv hook zsh)"

# atuin (shell history)
eval "$(atuin init zsh)"

# tirith
eval "$(tirith init --shell zsh)"

# navi (interactive cheatsheet — Ctrl+G)
eval "$(navi widget zsh)"

# Aliases — better defaults
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias cat='bat --paging=never'
alias watch='viddy'
alias lg='lazygit'
alias lzd='lazydocker'
```

> Adjust username-specific paths (`/Users/atilio/`) to the new machine's username.

### Powerlevel10k

The theme is configured with the **rainbow** style, **Nerd Fonts** (`MesloLGS NF`), powerline separators, 1-line compact prompt, and the following segment layout:

- **Left:** `os_icon` → `dir` → `vcs`
- **Right:** `status`, `command_execution_time`, `background_jobs`, `direnv`, `jenv`, `kubecontext`, `aws`, `context`, `time`

After installing, run the wizard to regenerate `~/.p10k.zsh`:

```bash
p10k configure
```

Or copy the existing `~/.p10k.zsh` file directly from the old machine — it is self-contained.

**Font:** Install `font-meslo-for-powerlevel10k` (already in brew casks above), then set the terminal font to `MesloLGS NF`.

---

## 4. Terminal Tools & Aliases

| Alias | Replaces | Package |
|-------|----------|---------|
| `ls` | `ls` | `eza --icons --group-directories-first` |
| `ll` | `ls -la` | `eza -la --icons --group-directories-first --git` |
| `cat` | `cat` | `bat --paging=never` |
| `watch` | `watch` | `viddy` |

### Other notable tools

| Tool | Purpose |
|------|---------|
| `atuin` | Shell history with sync (v18.13.2) — run `atuin login` to sync history across machines. Non-default config in `~/.config/atuin/config.toml`: `enter_accept = true`, `workspaces = true` |
| `bat` | Syntax-highlighted `cat` |
| `btop` | Resource monitor |
| `direnv` | Per-directory environment variables |
| `eza` | Modern `ls` with icons and git status |
| `fd` | Fast `find` alternative |
| `fzf` | Fuzzy finder (shell integration enabled) |
| `fx` | Terminal JSON viewer |
| `gh` | GitHub CLI (v2.88.1) |
| `git-delta` | Side-by-side diff pager |
| `git-open` | Open repo in browser |
| `gum` | Interactive shell scripts |
| `jq` | JSON processor |
| `lazygit` | Terminal git UI (v0.60.0) — alias `lg` |
| `mole` | SSH tunnel manager |
| `overmind` | Process manager (Procfile-based) |
| `ripgrep` | Fast grep (`rg`) |
| `tirith` | Policy engine CLI |
| `trash` | Safe `rm` (moves to trash) |
| `viddy` | Modern `watch` |
| `xh` | Friendly HTTP client |
| `yazi` | Terminal file manager |
| `zellij` | Terminal multiplexer |
| `zoxide` | Smart `cd` with frecency |
| `act` | Run GitHub Actions workflows locally |
| `dive` | Inspect Docker image layers |
| `lazydocker` | Docker TUI — alias `lzd` |
| `hyperfine` | Benchmark shell commands |
| `tokei` | Count lines of code by language |
| `navi` | Interactive cheatsheet (`Ctrl+G` in shell) — run `navi repo add denisidoro/cheats` to populate with community cheatsheets |
| `git-lfs` | Git Large File Storage — must run `git lfs install` after setup |
| `gh copilot` | Built into `gh` — explains shell commands (`gh copilot explain`) |

---

## 5. Git

### `~/.gitconfig`

```ini
[user]
    name = Atilio Villalba
    email = avillalba@fintech.works

[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true
    side-by-side = true
    line-numbers = true
    syntax-theme = Monokai Extended
    hyperlinks = true

[merge]
    conflictstyle = diff3

[diff]
    colorMoved = default

[filter "lfs"]
    clean = git-lfs clean -- %f
    smudge = git-lfs smudge -- %f
    process = git-lfs filter-process
    required = true

[init]
    defaultBranch = main

[credential]
    helper = osxkeychain
```

### `~/.gitignore_global`

Register it with git (required — not automatic):

```bash
git config --global core.excludesfile ~/.gitignore_global
```

Contents:

```
# macOS
.DS_Store
._.DS_Store
**/.DS_Store
**/._.DS_Store

# Environment / secrets
.env
.env.local
.env.*.local
*.pem
*.key

# Logs
*.log
logs/

# Editor / IDE
.idea/
*.iml
.vscode/
*.swp
*.swo
*~

# direnv
.direnv/

# OS temp files
Thumbs.db
```

The config also contains **Conventional Commits git aliases** (`feat`, `fix`, `refactor`, `docs`, `style`, `test`, `perf`, `build`, `ci`, `chore`, `wip`, `rev`) that accept `-s <scope>` and `-a` (attention/breaking) flags. These come from the `git-commit` Oh My Zsh plugin setup — copy the `[alias]` section from the old `~/.gitconfig` directly.

---

## 6. Node.js — mise + pnpm + bun

### Current versions

| Tool | Version |
|------|---------|
| Node.js | `v24.13.1` (default) |
| npm | `11.8.0` |
| pnpm | `10.12.4` |
| bun | `1.3.10` |

### Setup with mise

```bash
# Install mise
curl https://mise.run | sh
echo 'eval "$($HOME/.local/bin/mise activate zsh)"' >> ~/.zshrc

# Install Node
mise install node@24.13.1
mise use --global node@24.13.1

# Install pnpm globally
npm install -g pnpm

# Install bun
curl -fsSL https://bun.sh/install | bash
```

---

## 7. Java — mise

### Installed JDKs (Amazon Corretto via mise)

| Version | Status |
|---------|--------|
| `corretto-21.0.10` | installed |
| `corretto-24.0.2` | installed ← **global default** |

Also installed via brew: `openjdk@21` (21.0.10).

### Setup with mise

```bash
mise install java@corretto-21
mise install java@corretto-24
mise use --global java@corretto-24
```

---

## 8. Neovim (LazyVim)

### Install

```bash
brew install neovim
```

### Config: LazyVim (default install, no custom plugins)

```bash
# Clone LazyVim starter
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

The config is a **stock LazyVim install** with no custom plugin overrides (the `lua/plugins/` directory only has the example file). Options and keymaps files are also empty — all defaults.

#### Installed plugins (from `lazy-lock.json`)

- `LazyVim` — distro framework
- `blink.cmp` — completion
- `bufferline.nvim` — buffer tabs
- `catppuccin` — color scheme (alternative)
- `conform.nvim` — auto-formatting
- `flash.nvim` — fast navigation
- `friendly-snippets` — snippet library
- `gitsigns.nvim` — git decorations
- `grug-far.nvim` — find & replace
- `lazy.nvim` — plugin manager
- `lazydev.nvim` — Lua dev tools
- `lualine.nvim` — status line
- `mason.nvim` + `mason-lspconfig.nvim` — LSP installer
- `mini.ai`, `mini.icons`, `mini.pairs` — mini utilities
- `noice.nvim` + `nui.nvim` — UI improvements
- `nvim-lint` — linting
- `nvim-lspconfig` — LSP configs
- `nvim-treesitter` + textobjects + autotag — syntax
- `persistence.nvim` — session management
- `plenary.nvim` — utility library
- `snacks.nvim` — various QoL snacks
- `todo-comments.nvim` — highlight TODOs
- `tokyonight.nvim` — color scheme (default)
- `trouble.nvim` — diagnostics panel
- `ts-comments.nvim` — treesitter comments
- `which-key.nvim` — keybinding hints

---

## 9. Docker

**Docker Desktop** is used (not Docker Engine standalone).

- Version: `29.2.1`
- Architecture: `aarch64`
- Install from: https://www.docker.com/products/docker-desktop/

No custom daemon config. Docker Compose is bundled with Docker Desktop.

Docker CLI completions are added in `.zshrc`:
```zsh
fpath=(/Users/atilio/.docker/completions $fpath)
```

---

## 10. JetBrains IDEs

Installed via **JetBrains Toolbox** (recommended for managing updates):

| IDE | Purpose |
|-----|---------|
| IntelliJ IDEA | Java / Kotlin / general JVM |
| Rider | .NET / C# |
| WebStorm | JavaScript / TypeScript |

Install JetBrains Toolbox first, then install each IDE from it:
https://www.jetbrains.com/toolbox-app/

---

## 11. VS Code

Installed at `/Applications/Visual Studio Code.app`. The `code` CLI is not in PATH — fix that first:

```
Cmd+Shift+P → "Shell Command: Install 'code' command in PATH"
```

### Key settings (`~/Library/Application Support/Code/User/settings.json`)

| Setting | Value |
|---------|-------|
| Font | Fira Code, size 18, ligatures enabled |
| Terminal font | 14px, opens in iTerm |
| Theme | Gatito Theme |
| Icon theme | vscode-icons |
| Sidebar | Right side |
| Formatter (JS/TS/HTML/JSON) | Prettier |
| Default formatter | trunk.io |
| Tab width (Prettier) | 4 |
| Auto save | afterDelay |
| Bracket pair colorization | enabled |
| Copilot | enabled (except plaintext) |
| Claude Code | panel location |

### Extensions

Install all at once:

```bash
code --install-extension aaron-bond.better-comments
code --install-extension alefragnani.bookmarks
code --install-extension anthropic.claude-code
code --install-extension bradlc.vscode-tailwindcss
code --install-extension chakrounanas.turbo-console-log
code --install-extension christian-kohler.npm-intellisense
code --install-extension christian-kohler.path-intellisense
code --install-extension coderabbit.coderabbit-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension docker.docker
code --install-extension donjayamanne.githistory
code --install-extension dsznajder.es7-react-js-snippets
code --install-extension eamodio.gitlens
code --install-extension editorconfig.editorconfig
code --install-extension esbenp.prettier-vscode
code --install-extension ethansk.restore-terminals
code --install-extension formulahendry.auto-close-tag
code --install-extension formulahendry.auto-rename-tag
code --install-extension formulahendry.code-runner
code --install-extension github.copilot-chat
code --install-extension github.vscode-github-actions
code --install-extension github.vscode-pull-request-github
code --install-extension gruntfuggly.todo-tree
code --install-extension hediet.vscode-drawio
code --install-extension ionutvmi.path-autocomplete
code --install-extension johnpapa.vscode-peacock
code --install-extension mhutchie.git-graph
code --install-extension mikestead.dotenv
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-dotnettools.csdevkit
code --install-extension ms-dotnettools.csharp
code --install-extension ms-dotnettools.vscode-dotnet-runtime
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-vscode.cpptools
code --install-extension naumovs.color-highlight
code --install-extension oderwat.indent-rainbow
code --install-extension oracle.oracle-java
code --install-extension pawelgrzybek.gatito-theme
code --install-extension pkief.material-icon-theme
code --install-extension prisma.prisma
code --install-extension redhat.java
code --install-extension redhat.vscode-xml
code --install-extension redhat.vscode-yaml
code --install-extension redis.redis-for-vscode
code --install-extension ritwickdey.liveserver
code --install-extension rvest.vs-code-prettier-eslint
code --install-extension shd101wyy.markdown-preview-enhanced
code --install-extension sonarsource.sonarlint-vscode
code --install-extension usernamehw.errorlens
code --install-extension vmware.vscode-spring-boot
code --install-extension vscjava.vscode-gradle
code --install-extension vscjava.vscode-java-debug
code --install-extension vscjava.vscode-java-pack
code --install-extension vscjava.vscode-maven
code --install-extension vscjava.vscode-spring-boot-dashboard
code --install-extension vscjava.vscode-spring-initializr
code --install-extension vscode-icons-team.vscode-icons
code --install-extension wallabyjs.console-ninja
code --install-extension wix.vscode-import-cost
code --install-extension yoavbls.pretty-ts-errors
code --install-extension yzhang.markdown-all-in-one
code --install-extension ziyasal.vscode-open-in-github
```

> Alternatively, enable **Settings Sync** (`Cmd+Shift+P` → "Settings Sync: Turn On") and sign in with the same GitHub account — extensions, settings, and keybindings will sync automatically.

---

## 12. iTerm2

iTerm2 is the primary terminal emulator (`/Applications/iTerm.app`).

### Install

Download from https://iterm2.com/ or install via brew:

```bash
brew install --cask iterm2
```

### Profile settings (Default profile)

| Setting | Value |
|---------|-------|
| Font | MesloLGS NF Regular, 15pt |
| Non-ASCII font | Monaco 12 (disabled — "Use Non-ASCII Font" = off) |
| Bold | enabled |
| Italic | enabled |
| Scrollback lines | 1000 |
| Unlimited scrollback | off |
| Transparency | 0 (opaque) |

> The font must be installed first — it comes from the `font-meslo-for-powerlevel10k` brew cask.

### Restore settings

iTerm2 settings can be exported from **Preferences → General → Preferences → Load preferences from a custom folder**. Export the plist from the old machine and import on the new one, or reconfigure manually using the values above.

---

## 13. macOS Apps & System Config

### Window Management

| App | Purpose | Config |
|-----|---------|--------|
| **Rectangle** | Keyboard-driven window snapping | Launch on login, `allowAnyShortcut = true`, `alternateDefaultShortcuts = true`, cursor moves across displays |
| **Maccy** | Clipboard manager | Default config |

Both launch on login. Install:

```bash
# Rectangle — open source window manager
brew install --cask rectangle

# Maccy — clipboard history
brew install --cask maccy
```

### Dock

```bash
# Position on the left, auto-hide, tile size 66
defaults write com.apple.dock orientation left
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 66
killall Dock
```

### Productivity & Communication Apps

Install these manually from their websites or the Mac App Store:

| App | Purpose |
|-----|---------|
| Obsidian | Notes / knowledge base |
| Postman | API testing |
| DBeaver | Universal database GUI |
| Redis Insight | Redis GUI |
| OpenVPN Connect | VPN client |
| Mattermost | Team chat |
| AnythingLLM | Local LLM interface |
| OpenCode | AI coding in terminal |
| Sublime Text | Lightweight text editor |
| KeyStore Explorer | JKS / keystore management |
| GitHub Desktop | Git GUI |
| Logi Options+ | Logitech mouse/keyboard config |
| VLC | Media player |
| Telegram / WhatsApp | Messaging |
| Zoom | Video calls |
| Rectangle | Window management (see above) |
| Maccy | Clipboard manager (see above) |

### Time Machine — `asimov`

`asimov` automatically excludes development dependency directories (like `node_modules`, `.build`, virtual envs) from Time Machine backups. It runs daily as a user-level LaunchAgent.

```bash
brew install asimov

# Copy the LaunchAgent plist (from this repo: launchagents/homebrew.asimov.plist)
cp launchagents/homebrew.asimov.plist ~/Library/LaunchAgents/homebrew.asimov.plist
launchctl load ~/Library/LaunchAgents/homebrew.asimov.plist
```

> `sudo brew services start asimov` fails on macOS Sequoia (bootstrap domain error). The user-level LaunchAgent approach works without sudo.

### Minikube

Local Kubernetes for development. Installed via brew, configured with a single `minikube` cluster context.

```bash
brew install minikube kubernetes-cli
minikube start
```

The kubectl context is named `minikube` and is set as the current context automatically on first start.

---

## 14. Claude Code

### Install

```bash
brew install --cask claude-code
# or via npm:
npm install -g @anthropic-ai/claude-code
```

### Global config — `~/.claude/CLAUDE.md`

Create `~/.claude/CLAUDE.md` on the new machine with the following rules (the `.vscode/CLAUDE.md` project convention is specific to this machine and should not be carried over):

```markdown
# Global Claude Code Rules

## General Rules

- NEVER mention Claude, AI, LLMs, copilot, or any AI tool in project files, commits,
  code comments, PR descriptions, or any other output
- Write all code, commits, and documentation as if a human developer wrote them
- NEVER run destructive or irreversible shell commands — this includes but is not limited
  to: `rm -rf`, `git reset --hard`, `git push --force`, `git clean -f`, `git branch -D`,
  `git checkout .`, `git restore .`, `DROP TABLE`, or any command that overwrites, deletes,
  or discards work without explicit user confirmation

## Commit Message Guidelines

Always follow the Conventional Commits specification:

### Format
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]

### Rules
- The first line (type + description) must not exceed 50 characters
- Leave a blank line between the description and the body
- NEVER include "Co-Authored-By" or any AI attribution in footers

### When writing a commit message
1. Always run `git log` to read the full commit history
2. Extract the team's real formatting patterns from that history
3. Use those patterns as the primary style guide, falling back to Conventional Commits

### Types
feat, fix, refactor, docs, style, test, perf, build, ci, chore

## Memory

- At the start of every conversation, check the project memory file if one exists
- Update memory after resolving non-obvious bugs, making architectural decisions,
  or discovering patterns that will recur
- Keep entries concise and factual — no speculation, no session-specific state

## Code Style

- Follow SOLID principles, clean code practices, and appropriate design patterns
- Do NOT add excessive or multi-line explanatory comments
- Only comment when logic is truly non-obvious
- Never add comments like "// Step 1:", "// Step 2:", or "// This method does X"
```

### Settings — `~/.claude/settings.json`

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash /Users/atilio/.claude/statusline-command.sh"
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash /Users/atilio/.claude/hooks/pre-bash.sh",
            "timeout": 5
          }
        ]
      },
      {
        "matcher": "WebSearch",
        "hooks": [
          {
            "type": "command",
            "command": "bash /Users/atilio/.claude/hooks/pre-websearch.sh",
            "timeout": 10
          }
        ]
      }
    ]
  },
  "permissions": {
    "allow": [
      "mcp__cachebro__read_file",
      "mcp__cachebro__read_files",
      "Read",
      "Glob",
      "Grep",
      "WebFetch",
      "WebSearch",
      "Bash(cat *)",
      "Bash(head *)",
      "Bash(tail *)",
      "Bash(which *)",
      "Bash(bat *)",
      "Bash(eza *)",
      "Bash(ls *)",
      "Bash(tree *)",
      "Bash(fd *)",
      "Bash(rg *)",
      "Bash(git log*)",
      "Bash(git diff*)",
      "Bash(git status*)",
      "Bash(git show*)",
      "Bash(git branch*)",
      "Bash(git fetch*)",
      "Bash(git remote*)"
    ]
  }
}
```

> Update the username in all paths before copying.

### Status Line — `~/.claude/statusline-command.sh`

A custom shell script that displays a rich status bar inside Claude Code with:

- **Model name** (`◆ model-name`)
- **Context window usage** bar `[####.....]` with percentage
- **Next quota reset** countdown (fixed schedule: 00:00, 04:00, 09:00, 14:00, 19:00) with `(!)` warning when ≤30 min away
- **Session cost** in USD (`$ 0.042`)
- **Session duration** (`⚡ 3m`)
- **Lines changed** (`~ +42/-7`)

Copy `~/.claude/statusline-command.sh` to the new machine verbatim.

### Hooks

Two `PreToolUse` hooks are active:

#### `~/.claude/hooks/pre-bash.sh`

Blocks destructive shell commands before they run. Checked patterns:

```
git reset --hard
git push --force / git push -f
git clean -f
git branch -D
git checkout .
git restore .
rm -rf /  rm -rf *  rm -rf $  rm -rf ~
```

Returns exit code `2` to block, `0` to allow.

#### `~/.claude/hooks/pre-websearch.sh`

Intercepts `WebSearch` tool calls and surfaces an approval prompt showing the query before consuming tokens.

Copy both files to `~/.claude/hooks/` on the new machine.

### Skills / Plugins

Two skill sources are active:

**gstack** — installed under `~/.claude/skills/gstack/` (repo: github.com/garrytan/gstack):
- `browse` — headless browser for QA
- `gstack-upgrade` — upgrade gstack itself
- `plan-ceo-review` — CEO-mode plan review
- `plan-eng-review` — Eng manager-mode plan review
- `qa` — systematic QA testing
- `retro` — weekly engineering retrospective
- `review` — pre-landing PR review
- `setup-browser-cookies` — import browser cookies
- `ship` — ship workflow (merge → test → PR)

**fullstack-dev-skills** — plugin from github.com/jeffallan/claude-skills, installed under `~/.agents/skills/`. Active skills:
- `find-skills`
- `nestjs-expert`
- `spring-boot-engineer`
- `typescript-pro`
- `vercel-composition-patterns`
- `vercel-react-best-practices`
- `vercel-react-native-skills`
- `web-design-guidelines`

#### Reinstall skills on new machine

```bash
# gstack suite (installs directly as files under ~/.claude/skills/)
claude plugins install gstack

# jeffallan/claude-skills marketplace + plugin
claude plugins marketplace add jeffallan/claude-skills
claude plugins install fullstack-dev-skills@fullstack-dev-skills
```

> The marketplace and enabledPlugins entries are already in `settings.json` — they will be applied when the file is copied.

### MCP Server — cachebro

**cachebro** (github.com/glommer/cachebro) is a Claude Code MCP tool that caches file reads by content hash. On repeated reads it returns "unchanged" or a compact diff instead of the full file, saving significant tokens.

It is pre-authorized in `settings.json` (`mcp__cachebro__read_file`, `mcp__cachebro__read_files`). The MCP server config lives in `~/.claude.json` (not `settings.json`) — it is added automatically by the init command.

```bash
npx cachebro init
```

Then restart Claude Code. The `mcpServers` block it adds to `~/.claude.json`:

```json
"mcpServers": {
  "cachebro": {
    "command": "npx",
    "args": ["cachebro", "serve"]
  }
}
```

### Memory System

Claude uses a file-based memory system at `~/.claude/projects/<project-path>/memory/`. Each project gets its own `MEMORY.md` index that is auto-loaded when Claude opens in that directory. Memory entries are markdown files with frontmatter specifying type (`user`, `feedback`, `project`, `reference`).

#### Memory types

| Type | What it stores |
|------|---------------|
| `user` | Who you are — role, skills, preferences, background |
| `feedback` | Corrections you've given Claude — what to do/avoid and why |
| `project` | Ongoing work context, decisions, deadlines, architecture |
| `reference` | Pointers to external systems (Linear boards, Grafana, Slack channels) |

#### Seed user profile on new machine

Create this file immediately after setup so Claude knows who you are in every conversation:

**`~/.claude/projects/-Users-<username>-Projects/memory/MEMORY.md`**
```markdown
# Memory Index

- [user_profile.md](user_profile.md) — Who Atilio is: role, background, tech stack, personal interests
```

**`~/.claude/projects/-Users-<username>-Projects/memory/user_profile.md`**
```markdown
---
name: Atilio's profile
description: Who Atilio is — role, background, skills, and personal interests
type: user
---

**Name**: Atilio José Villalba Giubi (goes by Atilio)
**Location**: Asunción, Paraguay
**Role**: Software Engineer & Architect at fintech.works (Integration Team)
**Experience**: 6+ years across fintech, automation, CRM

**Tech stack**: Java/Spring Boot, TypeScript/Node.js, C#/.NET, React, AWS (ECS, Lambda,
CloudWatch), Docker, Kafka, RabbitMQ, Clean/Hexagonal Architecture, Microservices

**Previous companies**: Wind River (remote, US), MicrotechPy, Fiweex, MentorMate

**Personal interests**: Vinyl records, live music/concerts, travel, game development
(hobby since COVID lockdowns)
```

> Adjust the path to match the actual username on the new machine. The path mirrors the filesystem: `/Users/<username>/Projects` → `-Users-<username>-Projects`.

#### Global feedback to recreate

These feedback memories apply broadly and should be seeded manually or will rebuild naturally over time:

- **No AI attribution** — never include Co-Authored-By, Claude, AI, LLM in any output
- **cachebro first** — always use cachebro `read_file` MCP tool instead of built-in Read tool for file reads (saves tokens via hash-based caching)
- **Concise responses** — lead with action, no preamble, no trailing summary of what was just done
- **No unsolicited docs** — never create README or documentation files unless explicitly asked

### Preferences & Behavior (learned across sessions)

- Write all code and commits **as a human developer** — never reference AI tools
- Follow **SOLID** and clean code principles; avoid over-engineering
- No excessive comments — only comment truly non-obvious logic
- Prefer **editing existing files** over creating new ones
- Never create documentation files unless explicitly asked
- Responses should be **concise and direct** — lead with the action, skip preamble
- Never summarize what was just done at the end of a response
- Always read `git log` before writing commit messages

---

## 15. Spicetify

Spicetify is a CLI tool that customizes the Spotify client (themes, extensions, custom apps). It's installed via brew and runs on top of the Spotify desktop app.

### Install

```bash
brew install spicetify-cli
# Then apply (Spotify must be installed first):
spicetify backup apply
```

### Current config (`~/.config/spicetify/config-xpui.ini`)

| Setting | Value |
|---------|-------|
| Theme | `marketplace` |
| Custom apps | `reddit`, `new-releases`, `marketplace`, `lyrics-plus` |
| Inject CSS | enabled |
| Replace colors | enabled |
| Inject theme JS | enabled |
| Experimental features | enabled |

Restore on new machine:

```bash
# 1. Install Spotify first, then:
brew install spicetify-cli
spicetify backup apply

# 2. Install Spicetify Marketplace (provides the marketplace theme + app):
curl -fsSL https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh | sh

# 3. Re-apply
spicetify apply
```

### Usage

```bash
spicetify apply      # apply changes after editing config
spicetify restore    # revert to stock Spotify
spicetify upgrade    # update spicetify itself
```

> After every Spotify update, run `spicetify backup apply` again — Spotify updates overwrite the patches.

---

## Appendix: Quick Replication Checklist

```
[ ] Install Homebrew + add taps (lucassabreu/tap, sheeki03/tap)
[ ] Run: brew bundle install --file=~/Brewfile
[ ] git lfs install  (after brew install)
[ ] Create ~/.gitignore_global and register: git config --global core.excludesfile ~/.gitignore_global
[ ] Install Oh My Zsh
[ ] Clone zsh-autosuggestions and zsh-syntax-highlighting into OMZ custom plugins
[ ] Copy ~/.zshrc (update username in paths)
[ ] Copy ~/.p10k.zsh  OR  run `p10k configure`
[ ] Copy ~/.gitconfig (update name/email, keep delta + lfs config)
[ ] Install iTerm2, set font to MesloLGS NF 15pt
[ ] Install mise (curl https://mise.run | sh) and set up Node 24.13.1
[ ] Install pnpm (npm install -g pnpm) and bun (curl -fsSL https://bun.sh/install | bash)
[ ] Install Java JDKs via mise: mise install java@corretto-21 && mise install java@corretto-24
[ ] Install Docker Desktop
[ ] Install JetBrains Toolbox → IntelliJ IDEA, WebStorm
[ ] Install VS Code, add 'code' to PATH (Cmd+Shift+P → Shell Command), install extensions or enable Settings Sync
[ ] Install asimov LaunchAgent: cp launchagents/homebrew.asimov.plist ~/Library/LaunchAgents/ && launchctl load ~/Library/LaunchAgents/homebrew.asimov.plist
[ ] Install Neovim + LazyVim
[ ] Set atuin config: enter_accept = true, workspaces = true
[ ] Log in: gh auth login, atuin login
[ ] Run: navi repo add denisidoro/cheats
[ ] Install Spotify + run: spicetify backup apply + install Marketplace
[ ] Install Claude Code (brew cask or npm)
[ ] Create ~/.claude/CLAUDE.md (see section 14)
[ ] Copy ~/.claude/settings.json
[ ] Copy ~/.claude/statusline-command.sh
[ ] Create ~/.claude/hooks/ and copy pre-bash.sh + pre-websearch.sh
[ ] Install Claude Code skills (see section 14 for commands)
[ ] Install and configure cachebro MCP server (see section 14)
[ ] Seed user profile memory files under ~/.claude/projects/.../memory/
[ ] Install remaining GUI apps (Obsidian, Postman, DBeaver, Redis Insight, etc.)
```
