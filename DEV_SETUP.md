# Developer Setup — Atilio Villalba

> Last updated: 2026-04-14
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
9. [Terminal Editors — nano & vim](#9-terminal-editors--nano--vim)
10. [Docker](#10-docker)
11. [JetBrains IDEs](#11-jetbrains-ides)
12. [VS Code](#12-vs-code)
13. [iTerm2](#13-iterm2)
14. [macOS Apps & System Config](#14-macos-apps--system-config)
15. [Claude Code](#15-claude-code)
16. [Spicetify](#16-spicetify)
17. [Claude Code Stats](#17-claude-code-stats)

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

> **Note:** `brew bundle dump` only captures explicitly installed packages, not those installed as dependencies. The manual formula list below is the authoritative reference — use it to cross-check after a bundle restore. Known gaps in the Brewfile: `python@3.14`, `tmux`, `bash`, `gradle-completion`, `openjdk`.

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
  pipx \
  powerlevel10k \
  python@3.13 \
  python@3.14 \
  ripgrep \
  spicetify-cli \
  telnet \
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

### `~/.zprofile`

Runs before `.zshrc` on login shells. Only one line — initializes Homebrew so it's available to everything that follows:

```zsh
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Copy to new machine:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' > ~/.zprofile
```

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

# Python
export PATH="/opt/homebrew/opt/python@3.14/libexec/bin:$PATH"

# PATH extras
PATH=~/.console-ninja/.bin:$PATH
export PATH=/Users/atilio/.opencode/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"

# direnv
eval "$(direnv hook zsh)"

# atuin (shell history)
eval "$(atuin init zsh)"

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

### Python tools — pipx

`pipx` installs Python CLI tools in isolated environments and exposes them on `$PATH` via `~/.local/bin`. Installed via brew.

```bash
brew install pipx
```

| Tool | Version | Install |
|------|---------|---------|
| `graphify` | 0.4.13 | `pipx install graphifyy` |

> Note: the pip package name is `graphifyy` (double y) but the command is `graphify`.
>
> `~/.local/bin` must be in `$PATH` (already in `.zshrc`).

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

### `~/.config/git/ignore`

A second global gitignore (separate from `~/.gitignore_global`) used for tool-specific patterns that shouldn't live in the main file:

```
**/.claude/settings.local.json
```

Register it with git:

```bash
git config --global core.excludesfile ~/.config/git/ignore
```

> Both `~/.gitignore_global` and `~/.config/git/ignore` are active simultaneously — git checks both. The `.config/git/ignore` path is git's XDG default location and is picked up automatically on some systems without explicit registration.

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

## 9. Terminal Editors — nano & vim

Both `nano` and `vim` are available for quick terminal edits. `nvim` (LazyVim) is the primary editor for real work; these cover fast one-liners, server edits, or situations where nvim isn't available.

### nano

**Install:** `brew install nano` (already in Brewfile)

Config lives at `~/.nanorc`. A custom TypeScript syntax file lives at `~/.nano/typescript.nanorc`.

#### `~/.nanorc`

```
## Appearance
set linenumbers
set numbercolor yellow,normal
set titlecolor brightwhite,blue
set statuscolor brightwhite,green
set errorcolor brightwhite,red
set selectedcolor brightwhite,magenta
set stripecolor ,yellow

## Editor behaviour
set autoindent
set tabsize 2
set tabstospaces
set softwrap
set atblanks
set mouse
set constantshow
set smarthome
set zap

## Search
set casesensitive

## History & undo
set historylog
set positionlog

## Brackets
set matchbrackets "(<[{)>]}"

## Syntax highlighting — bundled
include "/opt/homebrew/share/nano/*.nanorc"
include "/opt/homebrew/share/nano/extra/*.nanorc"

## Syntax highlighting — user-defined
include "~/.nano/typescript.nanorc"
```

#### `~/.nano/typescript.nanorc`

Custom syntax highlighting for `.ts` and `.tsx` files. Covers: keywords, built-in types, common built-ins, decorators, strings (including template literals), numbers (decimal + hex), line/block comments, and JSX tags.

Restore on a new machine:

```bash
mkdir -p ~/.nano
cp nano/nanorc ~/.nanorc
cp nano/typescript.nanorc ~/.nano/typescript.nanorc
```

---

### vim

**Install:** Ships with macOS at `/usr/bin/vim` — no extra install needed. The system vim is used (no Homebrew override).

Config lives at `~/.vimrc`.

#### `~/.vimrc`

| Section | Settings |
|---------|---------|
| Basics | `nocompatible`, filetype plugin/indent, syntax on, `utf-8` |
| Appearance | Line numbers + relative numbers, cursor line, color column at 120, `habamax` colorscheme, `laststatus=2`, wildmenu, `scrolloff=8` |
| Editing | 4-space tabs (`expandtab`), `autoindent`, `smartindent`, mouse enabled, clipboard = system (`unnamed`) |
| Search | `hlsearch`, `incsearch`, `ignorecase`, `smartcase` |
| Files | `noswapfile`, `nobackup`, `autoread` |
| Key remaps | `jj` → `<Esc>` in insert mode · `<CR>` → `:nohlsearch` · `Ctrl+S` → `:w` |

Restore on a new machine:

```bash
cp vim/vimrc ~/.vimrc
```

---

## 10. Docker

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

## 11. JetBrains IDEs

Installed via **JetBrains Toolbox** (recommended for managing updates):

| IDE | Purpose |
|-----|---------|
| IntelliJ IDEA | Java / Kotlin / general JVM |
| Rider | .NET / C# |
| WebStorm | JavaScript / TypeScript |

Install JetBrains Toolbox first, then install each IDE from it:
https://www.jetbrains.com/toolbox-app/

---

## 12. VS Code

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

## 13. iTerm2

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

### iTermAI

A companion AI assistant window that runs alongside iTerm2. Installed separately as `/Applications/iTermAI.app` (v1.1). Config lives at `~/.config/iterm2/` (symlinked to `~/Library/Application Support/iTerm2`).

Download from https://iterm2.com/ — iTermAI ships as a separate download from the main iTerm2 app. No additional configuration needed beyond install.

---

## 14. macOS Apps & System Config

### System Preferences

All commands below can be run as a block on a new machine to restore settings. Requires logging out or killing the relevant process (noted inline) to take effect.

#### Appearance

```bash
# Dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Graphite highlight color
defaults write NSGlobalDomain AppleHighlightColor -string "0.847059 0.847059 0.862745 Graphite"

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Show all file extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
```

#### Trackpad

```bash
# Disable tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false

# Tracking speed (0–3, default 1 — set to 0.875, slightly below medium)
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 0.875

# Disable natural (reverse) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Click pressure: medium (0 = light, 1 = medium, 2 = firm)
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 1
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 1
```

#### Keyboard

```bash
# Key repeat rate: 2 (fastest usable — range 1–15, lower = faster)
defaults write NSGlobalDomain KeyRepeat -int 2

# Delay before repeat starts: 15 (short — range 15–120, lower = shorter)
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable auto-correct, smart quotes, smart dashes
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
```

#### Finder

```bash
# Show path bar and status bar
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Default view: list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# New Finder windows open to home folder
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

killall Finder
```

#### Dock

```bash
# Left side, auto-hide, size 66, hide recent apps
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 66
defaults write com.apple.dock show-recents -bool false

killall Dock
```

#### Mission Control

```bash
# Don't rearrange Spaces based on recent use
defaults write com.apple.dock mru-spaces -bool false

# When switching to an app, switch to its Space
defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -bool true

killall Dock
```

#### Accessibility

```bash
# Reduce motion (disables parallax and animated transitions)
defaults write com.apple.universalaccess reduceMotion -bool true

# Reduce transparency (solid backgrounds in menu bar, Dock, sidebars)
defaults write com.apple.universalaccess reduceTransparency -bool true
```

#### Energy

```bash
# Never sleep (display and system) — useful on a MacBook used as desktop
sudo pmset -a sleep 0
sudo pmset -a displaysleep 0
sudo pmset -a disksleep 10
sudo pmset -a powernap 1
```

> These settings are machine-state only and don't persist to a plist — re-run `pmset` after setup.

#### Mouse

```bash
# Tracking speed
defaults write NSGlobalDomain com.apple.mouse.scaling -float 1

# Disable natural scrolling for mouse (already disabled via trackpad setting above)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
```

---

### Displays

| Display | Resolution | Notes |
|---------|-----------|-------|
| Primary | 1920 × 1080 (1080p) | Main display |
| Secondary | 1080 × 1920 (portrait) | Rotated secondary monitor |

---

### Menu Bar Apps

#### Itsycal `v0.15.10` — `brew install --cask itsycal`

Compact calendar in the menu bar. Replaces the system clock date display.

| Setting | Value |
|---------|-------|
| Show day of week in icon | yes |
| Show month in icon | yes |
| Show events | 7 days ahead |
| Icon type | date-based |

No restore command needed — configure manually after install. Connect calendars via System Settings → Internet Accounts.

#### Stats `v2.12.4` — `brew install --cask stats`

System resource monitor in the menu bar. Launch at login enabled, telemetry disabled.

**Enabled modules and widgets:**

| Module | Widget |
|--------|--------|
| CPU | mini |
| RAM | mini |
| Disk | mini |
| Network | speed |
| Battery | battery + mini |

Battery low-level notification is active. No high-level notification set. Configure by opening Stats → each module's settings panel.

#### FineTune `v1.0` — manual install from https://www.finetuneapp.com

System-wide audio equalizer. Runs as a menu bar app and applies per-app EQ profiles over macOS's audio stack. No config files to back up — EQ presets are stored internally by the app.

---

### Window Management & Clipboard

#### Rectangle `v0.92` — `brew install --cask rectangle`

Keyboard-driven window snapping and tiling.

| Setting | Value |
|---------|-------|
| Launch at login | yes |
| `allowAnyShortcut` | true |
| `alternateDefaultShortcuts` | true — uses Spectacle-compatible shortcuts |
| `moveCursorAcrossDisplays` | true |
| `hideMenubarIcon` | true |
| Double-click title bar | maximize |
| Auto-update | enabled |

Apply with:

```bash
defaults write com.knollsoft.Rectangle allowAnyShortcut -bool true
defaults write com.knollsoft.Rectangle alternateDefaultShortcuts -bool true
defaults write com.knollsoft.Rectangle moveCursorAcrossDisplays -bool true
defaults write com.knollsoft.Rectangle launchOnLogin -bool true
defaults write com.knollsoft.Rectangle hideMenubarIcon -bool true
```

#### Maccy `v2.5.1` — `brew install --cask maccy`

Clipboard history manager. Popup shortcut: `Cmd+Shift+V`.

| Setting | Value |
|---------|-------|
| Launch at login | yes |
| Popup shortcut | `Cmd+Shift+V` |
| Paste by default | yes (single click pastes) |
| Remove formatting by default | yes |
| Show search bar | yes |
| Show title | yes |
| Show footer | yes |
| Suppress clear alert | yes |
| Show in status bar | no (icon hidden) |
| Supported types | plain text, images (PNG/TIFF), HTML, RTF, file URLs |
| Ignored types | 1Password, KeeWeb, TypeIt4Me (password manager clipboards) |

Apply:

```bash
defaults write org.p0deje.Maccy pasteByDefault -bool true
defaults write org.p0deje.Maccy removeFormattingByDefault -bool true
defaults write org.p0deje.Maccy suppressClearAlert -bool true
defaults write org.p0deje.Maccy showInStatusBar -bool false
```

---

### App Maintenance

#### AppCleaner `v3.6.8` — `brew install --cask appcleaner`

Removes apps and all their associated files (preferences, caches, support files). Enable **SmartDelete** in Preferences to automatically prompt for cleanup whenever you drag an app to the Trash.

No automated config — open the app, go to Preferences → SmartDelete → enable.

---

### Developer Tools

#### Postman `v11.86.1` — https://www.postman.com/downloads/

API development and testing client. Collections and environments sync automatically through a Postman account — sign in after install to restore workspaces.

#### DBeaver Community `v25.3.5` — https://dbeaver.io/download/

Universal database GUI. Supports PostgreSQL, MySQL, SQLite, Oracle, SQL Server, and more.

Config and connection data live at `~/Library/DBeaverData/workspace6/`. No automated restore — reconnect to databases manually after install. Connection passwords are stored in the system keychain.

#### Redis Insight `v2.70.1` — https://redis.io/redis-insight/

Redis GUI for browsing keys, running commands, and profiling. Config at `~/Library/Application Support/RedisInsight/config.json`.

| Setting | Value |
|---------|-------|
| Window size | 1300 × 860 px |

Databases are stored in the app's internal config — re-add connections manually after install.

#### Obsidian `v1.12.4` — https://obsidian.md/

Markdown-based knowledge management and note-taking. Vaults are plain folders of `.md` files — back them up separately (e.g., iCloud, Dropbox, or a dedicated git repo). No Obsidian-specific config to restore beyond re-opening the vault folder.

#### Sublime Text `Build 4200` — https://www.sublimetext.com/

Lightweight editor used for quick file viewing and edits that don't warrant opening a full IDE. No custom packages installed — used out of the box.

#### KeyStore Explorer `v5.5.3` — https://keystore-explorer.org/

GUI for managing Java keystores, truststores, and certificates (JKS, PKCS12). No config to restore — open `.jks` / `.p12` files directly.

#### GitHub Desktop `v3.5.4` — https://desktop.github.com/

Git GUI for visual diffs, branch management, and PR workflows. Sign in with GitHub account after install to restore repository access.

---

### Communication

| App | Version | Install | Notes |
|-----|---------|---------|-------|
| Zoom | 6.1.6 | https://zoom.us/download | Work video calls |
| Microsoft Teams | 26032.605 | https://www.microsoft.com/teams | Work meetings |
| Telegram | 12.5 | Mac App Store or https://telegram.org | Messaging |
| WhatsApp | 26.9.75 | Mac App Store or https://www.whatsapp.com | Messaging |

---

### Remote Access

| App | Version | Install | Notes |
|-----|---------|---------|-------|
| OpenVPN Connect | 3.8.1 | https://openvpn.net/client/ | VPN — import `.ovpn` profile after install |
| Windows App | 11.3.3 | Mac App Store | Microsoft Remote Desktop — add PC connections manually |

---

### Media

| App | Version | Install | Notes |
|-----|---------|---------|-------|
| VLC | 3.0.21 | `brew install --cask vlc` | Universal media player |
| Stremio | — | https://www.stremio.com/downloads | Streaming platform — sign in to restore add-ons |

---

### Other Utilities

#### macOS InstantView `v3.22` — https://www.smi-inc.com/

Display management driver for SMI (Silicon Motion) external displays. Enables extended/mirror mode for monitors connected over USB-C/DisplayLink. Install from the SMI website; no configuration needed beyond connecting the display.

#### iTermAI `v1.1` — companion to iTerm2

Standalone AI assistant window that integrates with the iTerm2 terminal. Installed separately from iTerm2 itself.

#### Pinta `v2.1.2` — https://www.pinta-project.com/ or Mac App Store

Simple raster image editor (similar to MS Paint). Used for quick image annotations and crops. No configuration needed.

---

### Time Machine — `asimov`

`asimov` automatically excludes development dependency directories (`node_modules`, `.build`, virtual envs, etc.) from Time Machine backups. Runs daily as a user-level LaunchAgent.

```bash
brew install asimov

# Copy the LaunchAgent plist (from this repo: launchagents/homebrew.asimov.plist)
cp launchagents/homebrew.asimov.plist ~/Library/LaunchAgents/homebrew.asimov.plist
launchctl load ~/Library/LaunchAgents/homebrew.asimov.plist
```

> `sudo brew services start asimov` fails on macOS Sequoia (bootstrap domain error). The user-level LaunchAgent approach works without sudo.

---

### Minikube

Local Kubernetes for development. Installed via brew, configured with a single `minikube` cluster context.

```bash
brew install minikube kubernetes-cli
minikube start
```

The kubectl context is named `minikube` and is set as the current context automatically on first start.

---

## 15. Claude Code

### Install

```bash
brew install --cask claude-code
# or via npm:
npm install -g @anthropic-ai/claude-code
```

### Global config — `~/.claude/CLAUDE.md`

Create `~/.claude/CLAUDE.md` on the new machine with the following rules (the `.vscode/CLAUDE.md` project convention is specific to this machine and should not be carried over):

See `claude/CLAUDE.md` in this repo — copy it verbatim to `~/.claude/CLAUDE.md` on the new machine.

Key rules it enforces:
- Never mention AI tools in any output (code, commits, docs, PRs)
- Never run destructive commands without explicit confirmation (full blocked list inside)
- Commit type is `feature` (not `feat`), max 50 chars first line, max 80 chars per body bullet
- Always read `git log` before writing a commit message
- Memory system: check project memory at conversation start, update after architectural decisions

### Settings — `~/.claude/settings.json`

See `claude/settings.json` in this repo — copy it verbatim to `~/.claude/settings.json`, then update the username in all hardcoded paths (`/Users/atilio/` → `/Users/<username>/`).

Key blocks it contains:
- `statusLine` — wires the custom statusline script
- `permissions.allow` — pre-approves read-only tools and safe git/bash commands (includes `Bash(curl *)`)
- `permissions.deny` — blocks all destructive commands at the permission layer
- `hooks.PreToolUse` — Bash safety hook, WebSearch approval prompt, strategic-compact suggestion on Edit/Write
- `hooks.PreCompact`, `SessionStart`, `SessionEnd` — everything-claude-code plugin lifecycle hooks
- `enabledPlugins` + `extraKnownMarketplaces` — fullstack-dev-skills and everything-claude-code marketplace plugins

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

The following skill sources are active:

**gstack** — installed under `~/.claude/skills/gstack/` (repo: https://github.com/garrytan/gstack).
Active sub-skills: `autoplan`, `benchmark`, `careful`, `checkpoint`, `codex`, `document-release`,
`freeze`, `health`, `investigate`, `learn`, `openclaw`, `pair-agent`, `plan-ceo-review`,
`plan-eng-review`, `qa`, `qa-only`, `retro`, `review`, `unfreeze`

Symlinked from `~/.claude/skills/`: `plan-ceo-review`, `plan-eng-review`, `qa`, `retro`, `review`

> Deleted sub-skills (not needed): design-*, browse, gstack-upgrade, setup-browser-cookies, ship,
> canary, cso, guard, devex-review, plan-devex-review, land-and-deploy, setup-deploy, office-hours

**fullstack-dev-skills** — plugin from marketplace. Install via Claude Code plugin system.
Active skills (33): `api-designer`, `architecture-designer`, `cloud-architect`, `code-documenter`,
`code-reviewer`, `csharp-developer`, `database-optimizer`, `debugging-wizard`, `devops-engineer`,
`dotnet-core-expert`, `embedded-systems`, `fullstack-guardian`, `game-developer`, `java-architect`,
`javascript-pro`, `legacy-modernizer`, `microservices-architect`, `monitoring-expert`, `nestjs-expert`,
`nextjs-developer`, `postgres-pro`, `prompt-engineer`, `react-expert`, `react-native-expert`,
`secure-code-guardian`, `security-reviewer`, `spring-boot-engineer`, `sql-pro`, `sre-engineer`,
`terraform-engineer`, `test-master`, `typescript-pro`, `websocket-engineer`

**vercel-labs/agent-skills** — installed via `npx skills` CLI from https://github.com/vercel-labs/agent-skills.
Lives in `~/.agents/skills/`, symlinked into `~/.claude/skills/`. Active skills:
- `vercel-react-best-practices`
- `vercel-composition-patterns`
- `vercel-react-native-skills`
- `web-design-guidelines`

**caveman** — installed via `npx skills` CLI from https://github.com/JuliusBrussee/caveman.
Lives in `~/.agents/skills/`, symlinked into `~/.claude/skills/`. Skills:
- `caveman` — ultra-compressed output mode (~65-75% token reduction)
- `caveman-compress` — compresses CLAUDE.md/memory files (~45% input token reduction)

**everything-claude-code** — marketplace plugin. Active skills (28): `agentic-engineering`,
`ai-first-engineering`, `api-design`, `article-writing`, `autonomous-loops`, `blueprint`,
`carrier-relationship-management`, `claude-api`, `continuous-agent-loop`, `cost-aware-llm-pipeline`,
`database-migrations`, `deep-research`, `deployment-patterns`, `docker-patterns`, `e2e-testing`,
`enterprise-agent-ops`, `eval-harness`, `frontend-patterns`, `jpa-patterns`, `market-research`,
`plankton-code-quality`, `postgres-patterns`, `prompt-optimizer`, `regex-vs-llm-structured-text`,
`search-first`, `security-review`, `security-scan`, `springboot-security`

**coderabbit** — marketplace plugin. Skills: `autofix`, `code-review`

**Personal skills** — stored at https://github.com/atilio-ts/claude-skills, cloned to
`~/Projects/Personal/claude-skills/` and symlinked into `~/.claude/skills/`:

- `commit-message` — generates conventional commit messages reading git diff and project history
- `estimate` — technical analysis and effort estimation (Spanish/English), auto-selects decomposition strategy
- `user-story` — writes user stories and Jira tasks
- `sync-configuration` — syncs dev-setup and claude-skills repos with the live machine state
- `update-skills` — updates all installed skills and plugins (vercel-labs, caveman, Claude plugins)

#### Reinstall skills on new machine

```bash
# 1. gstack (installs as plugin, lives under ~/.claude/skills/gstack/)
claude plugin install gstack

# After install, delete unused sub-skills:
GSTACK="$HOME/.claude/skills/gstack"
for skill in design-consultation design-html design-review design-shotgun plan-design-review \
  browse open-gstack-browser office-hours land-and-deploy setup-deploy ship \
  canary cso guard devex-review plan-devex-review gstack-upgrade; do
  rm -rf "$GSTACK/$skill"
done
# Remove symlinks that pointed to deleted sub-skills:
rm -f ~/.claude/skills/{browse,gstack-upgrade,setup-browser-cookies,ship}

# 2. Claude plugins (run inside Claude Code or via CLI)
claude plugin marketplace add jeffallan/claude-skills
claude plugin install fullstack-dev-skills@fullstack-dev-skills
claude plugin install everything-claude-code@everything-claude-code
claude plugin install coderabbit@claude-plugins-official

# After installing fullstack-dev-skills, delete unused skills:
BASE_FS="$HOME/.claude/plugins/cache/fullstack-dev-skills/fullstack-dev-skills/$(ls ~/.claude/plugins/cache/fullstack-dev-skills/fullstack-dev-skills/)/skills"
for skill in angular-architect atlassian-mcp chaos-engineer cli-developer cpp-pro django-expert \
  fastapi-expert fine-tuning-expert flutter-expert golang-pro graphql-architect kotlin-specialist \
  kubernetes-specialist laravel-specialist mcp-developer ml-pipeline pandas-pro php-pro \
  playwright-expert python-pro rag-architect rails-expert react-native-expert rust-engineer \
  salesforce-developer shopify-expert spark-engineer spec-miner swift-expert the-fool \
  vue-expert vue-expert-js wordpress-pro feature-forge; do
  rm -rf "$BASE_FS/$skill"
done

# After installing everything-claude-code, delete unused skills:
BASE_ECC="$HOME/.claude/plugins/cache/everything-claude-code/everything-claude-code/$(ls ~/.claude/plugins/cache/everything-claude-code/everything-claude-code/)/skills"
for skill in android-clean-architecture coding-standards compose-multiplatform-patterns configure-ecc \
  content-engine content-hash-cache-pattern continuous-learning continuous-learning-v2 \
  cpp-coding-standards cpp-testing crosspost customs-trade-compliance django-patterns django-security \
  django-tdd django-verification dmux-workflows energy-procurement fal-ai-media \
  foundation-models-on-device frontend-patterns frontend-slides golang-patterns golang-testing \
  inventory-demand-planning investor-materials investor-outreach iterative-retrieval \
  java-coding-standards kotlin-coroutines-flows kotlin-exposed-patterns kotlin-ktor-patterns \
  kotlin-patterns kotlin-testing liquid-glass-design logistics-exception-management nanoclaw-repl \
  nutrient-document-processing perl-patterns perl-security perl-testing production-scheduling \
  project-guidelines-example python-patterns python-testing quality-nonconformance \
  ralphinho-rfc-pipeline returns-reverse-logistics skill-stocktake springboot-patterns springboot-tdd \
  springboot-verification strategic-compact swift-actor-persistence swift-concurrency-6-2 \
  swift-protocol-di-testing swiftui-patterns tdd-workflow verification-loop video-editing \
  videodb visa-doc-translate x-api agent-harness-construction backend-patterns; do
  rm -rf "$BASE_ECC/$skill"
done

# 3. vercel-labs/agent-skills (installs to ~/.agents/skills/, symlinked into ~/.claude/skills/)
npx skills add vercel-labs/agent-skills -g -s vercel-react-best-practices
npx skills add vercel-labs/agent-skills -g -s vercel-composition-patterns
npx skills add vercel-labs/agent-skills -g -s vercel-react-native-skills
npx skills add vercel-labs/agent-skills -g -s web-design-guidelines

# 4. caveman (installs to ~/.agents/skills/, symlinked into ~/.claude/skills/)
npx skills add JuliusBrussee/caveman -g
# Create symlinks for Claude Code:
ln -sf ../../.agents/skills/caveman ~/.claude/skills/caveman
ln -sf ../../.agents/skills/caveman-compress ~/.claude/skills/caveman-compress

# 5. Personal skills (clone repo and create symlinks)
git clone https://github.com/atilio-ts/claude-skills ~/Projects/Personal/claude-skills
for skill in commit-message estimate user-story sync-configuration update-skills; do
  ln -sf ~/Projects/Personal/claude-skills/$skill ~/.claude/skills/$skill
done
```

> The marketplace and enabledPlugins entries are already in `settings.json` — they will be applied when the file is copied.

### MCP Server — cachebro

**cachebro** (https://github.com/glommer/cachebro) is a Claude Code MCP tool that caches file reads by content hash. On repeated reads it returns "unchanged" or a compact diff instead of the full file, saving significant tokens.

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

## 16. Spicetify

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

## 17. Claude Code Stats

A local analytics tool that parses Claude Code session transcripts and generates an interactive HTML dashboard showing usage, token consumption, and hypothetical API costs. Runs as a background cron job, updating every 10 minutes.

**Repo:** https://github.com/AeternaLabsHQ/claude-code-stats

### Install

```bash
git clone https://github.com/AeternaLabsHQ/claude-code-stats.git ~/Projects/Github/claude-code-stats
cd ~/Projects/Github/claude-code-stats
```

No external dependencies — Python 3.8+ (standard library only).

### Configure

```bash
cp config.example.json config.json
```

Edit `config.json` to set your subscription plan details:

```json
{
  "language": "en",
  "plan_history": [
    {
      "plan": "Max",
      "start": "2026-01-23",
      "end": null,
      "cost_eur": 87.61,
      "cost_usd": 93.00,
      "billing_day": 23
    }
  ]
}
```

- `end: null` means the plan is currently active
- `billing_day` defines the cost cycle boundary (day of month billing resets)
- `migration` block available to import data from a previous machine (see repo README)

> ⚠️ The dashboard contains sensitive data (conversations, file paths, source code). Keep `public/` local — do not deploy or share it.

### Run manually

```bash
python3 extract_stats.py
open public/index.html
```

### Automate with cron

```bash
crontab -e
```

Add:

```
*/10 * * * * cd /Users/atilio/Projects/Github/claude-code-stats && python3 extract_stats.py 2>&1 >> update.log
```

This keeps the dashboard up to date in the background. Open `public/index.html` in any browser to view — it reads `dashboard_data.json` which is regenerated on each run.

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
[ ] Copy nano config: cp nano/nanorc ~/.nanorc && mkdir -p ~/.nano && cp nano/typescript.nanorc ~/.nano/typescript.nanorc
[ ] Copy vim config: cp vim/vimrc ~/.vimrc
[ ] Set atuin config: enter_accept = true, workspaces = true
[ ] Log in: gh auth login, atuin login
[ ] Run: navi repo add denisidoro/cheats
[ ] Install Spotify + run: spicetify backup apply + install Marketplace
[ ] Install Claude Code (brew cask or npm)
[ ] Create ~/.claude/CLAUDE.md (see section 14)
[ ] Copy ~/.claude/settings.json
[ ] Copy ~/.claude/statusline-command.sh
[ ] Create ~/.claude/hooks/ and copy pre-bash.sh + pre-websearch.sh
[ ] Install Claude Code skills: gstack + fullstack-dev-skills + vercel-labs/agent-skills + everything-claude-code (see section 14)
[ ] Install and configure cachebro MCP server (see section 14)
[ ] Seed user profile memory files under ~/.claude/projects/.../memory/
[ ] Apply macOS system preferences (see section 14 — Appearance, Trackpad, Keyboard, Finder, Dock, Mission Control, Accessibility, Energy)
[ ] brew install --cask rectangle maccy appcleaner itsycal stats vlc
[ ] Apply Rectangle defaults (see section 14)
[ ] Apply Maccy defaults (see section 14)
[ ] AppCleaner: Preferences → SmartDelete → enable
[ ] Install manually: FineTune, Postman, DBeaver, Redis Insight, Obsidian, KeyStore Explorer, GitHub Desktop, Sublime Text
[ ] Install manually: Zoom, Microsoft Teams, Mattermost, Telegram, WhatsApp
[ ] Install manually: OpenVPN Connect (import .ovpn profile), Windows App
[ ] Install manually: macOS InstantView, iTermAI, Stremio, Pinta
[ ] Sign in to: GitHub Desktop, Postman, Zoom, Telegram, WhatsApp
[ ] Clone claude-code-stats: git clone https://github.com/AeternaLabsHQ/claude-code-stats ~/Projects/Github/claude-code-stats
[ ] Configure claude-code-stats: cp config.example.json config.json → edit plan_history
[ ] Set up cron job: */10 * * * * cd ~/Projects/Github/claude-code-stats && python3 extract_stats.py 2>&1 >> update.log
[ ] Create ~/.config/git/ignore with **/.claude/settings.local.json → git config --global core.excludesfile ~/.config/git/ignore
```
