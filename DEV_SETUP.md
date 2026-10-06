# Developer Setup — Atilio Villalba

> Last updated: 2026-10-06
> Goal: replicate this exact environment on a new macOS (Apple Silicon) machine from scratch.

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Homebrew](#2-homebrew)
3. [Shell — Zsh + Oh My Zsh + Powerlevel10k](#3-shell--zsh--oh-my-zsh--powerlevel10k)
4. [Terminal Tools & Aliases](#4-terminal-tools--aliases)
5. [Git](#5-git)
6. [Node.js — mise + pnpm + bun](#6-nodejs--mise--pnpm--bun)
7. [Java — mise](#7-java--mise)
8. [Neovim (LazyVim)](#8-neovim-lazyvim)
9. [Terminal Editors — nano & vim](#9-terminal-editors--nano--vim)
10. [Docker](#10-docker)
11. [JetBrains IDEs](#11-jetbrains-ides)
12. [VS Code](#12-vs-code)
13. [Terminal Emulators — iTerm2 & Terminal.app](#13-terminal-emulators--iterm2--terminalapp)
14. [macOS Apps & System Config](#14-macos-apps--system-config)
15. [Claude Code](#15-claude-code)
16. [Spicetify](#16-spicetify)
17. [Claude Code Stats](#17-claude-code-stats)
18. [opencode](#18-opencode)

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

> **Note:** `brew bundle dump` only captures explicitly installed packages, not those installed as dependencies. The manual formula list below is the authoritative reference — use it to cross-check after a bundle restore. Known gaps in the Brewfile (installed but not dumped): `awscli`, `fnm`, `jenv`, `openjdk@25`. The Brewfile also taps `anomalyco/tap`, `can1357/tap`, `chattymin/tap`, `okooo5km/tap` and `steipete/tap` — `brew bundle` adds them itself.

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
  ffmpeg \
  fx \
  fzf \
  gh \
  git \
  git-delta \
  git-filter-repo \
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
  libpq \
  maven \
  minikube \
  mole \
  nano \
  navi \
  neovim \
  ninja \
  openjdk \
  openjdk@21 \
  openjdk@25 \
  overmind \
  pipx \
  poppler \
  powerlevel10k \
  pygments \
  python@3.14 \
  repomix \
  ripgrep \
  rtk \
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
  zsh-autosuggestions \
  can1357/tap/omp
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
  codexbar \
  dbeaver-community \
  docker-desktop \
  firefox@developer-edition \
  font-meslo-for-powerlevel10k \
  github \
  handy \
  okooo5km/tap/hipixel \
  instantview \
  intellij-idea \
  iterm2 \
  itermai \
  itsycal \
  keystore-explorer \
  lm-studio \
  logi-options+ \
  logitech-g-hub \
  mattermost \
  microsoft-teams \
  obsidian \
  ollama-app \
  openvpn-connect \
  pinta \
  chattymin/tap/poke-token-bar \
  postman \
  realvnc-connect-viewer \
  rectangle \
  redis-insight \
  rider \
  spotify \
  stats \
  sublime-text \
  visual-studio-code \
  vlc \
  webstorm \
  windows-app \
  zoom
```

> `docker-desktop`, `logitech-g-hub`, `logi-options+`, `openvpn-connect`, `realvnc-connect-viewer`, `windows-app`, `microsoft-teams` run a privileged `.pkg`/installer post-install step that needs `sudo` — run this block from an interactive terminal (not scripted/headless), you'll get password prompts partway through.

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

Runs before `.zshrc` on login shells. The line that matters initializes Homebrew so it's available to everything that follows (Docker Desktop and other installers append their own `PATH` lines here automatically):

```zsh
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Copy to new machine:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' > ~/.zprofile
```

### `~/.zshrc`

```zsh
MAILCHECK=0

# Powerlevel10k instant prompt — must stay near the top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ARM Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_COLORIZE_STYLE="colorful"

# Docker CLI completions (must be before oh-my-zsh)
fpath=($HOME/.docker/completions $fpath)

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

# mise (version manager — Node, Java, etc.)
eval "$($HOME/.local/bin/mise activate zsh)"

# fzf shell integration
source <(fzf --zsh)

# zoxide (smart cd)
eval "$(zoxide init zsh)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Default editor
export EDITOR=nvim
export VISUAL=nvim

# Python 3.14
export PATH="/opt/homebrew/opt/python@3.14/libexec/bin:$PATH"

# PATH extras
PATH=~/.console-ninja/.bin:$PATH
export PATH=$HOME/.opencode/bin:$PATH
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

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section

export PATH=$PATH:$HOME/.spicetify
```

> All shell config paths use `$HOME` and are portable. Only `~/.claude/settings.json` hardcodes `/Users/<username>/` in hook paths — update those after copying (see section 15).

### Powerlevel10k

The theme is configured with the **rainbow** style, **Nerd Fonts** (`MesloLGS NF`), powerline separators, 1-line compact prompt, and the following segment layout:

- **Left:** `os_icon` → `dir` → `vcs`
- **Right:** `status`, `command_execution_time`, `background_jobs`, `direnv`, `kubecontext`, `aws`, `context`, `time`

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
| `atuin` | Shell history with sync (v18.23.0) — run `atuin login` to sync history across machines. Non-default config in `~/.config/atuin/config.toml`: `enter_accept = true`, `workspaces = true` |
| `bat` | Syntax-highlighted `cat` |
| `btop` | Resource monitor |
| `direnv` | Per-directory environment variables |
| `eza` | Modern `ls` with icons and git status |
| `fd` | Fast `find` alternative |
| `fzf` | Fuzzy finder (shell integration enabled) |
| `fx` | Terminal JSON viewer |
| `gh` | GitHub CLI (v2.102.0) |
| `git-delta` | Side-by-side diff pager |
| `git-open` | Open repo in browser |
| `gum` | Interactive shell scripts |
| `jq` | JSON processor |
| `lazygit` | Terminal git UI (v0.66.0) — alias `lg` |
| `mole` | macOS deep clean and optimization CLI (mole.fit) |
| `overmind` | Process manager (Procfile-based) |
| `tmux` | Terminal multiplexer — config tracked at `tmux/tmux.conf` (prefix `Ctrl+a`, mouse on, vi copy-mode keys, `pbcopy` on yank) |
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
| `git-filter-repo` | Rewrite git history (email, paths, etc.) — modern `filter-branch` replacement |
| `git-lfs` | Git Large File Storage — must run `git lfs install` after setup |
| `gh copilot` | Built into `gh` — explains shell commands (`gh copilot explain`) |

### Python tools — pipx

`pipx` installs Python CLI tools in isolated environments and exposes them on `$PATH` via `~/.local/bin`. Installed via brew.

```bash
brew install pipx
```

| Tool | Install |
|------|---------|
| `code-review-graph` | `pipx install code-review-graph` |

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

No registration needed: `~/.config/git/ignore` is git's XDG default for `core.excludesfile`.

> Because `core.excludesfile` is explicitly set to `~/.gitignore_global`, git reads only that file — the XDG `~/.config/git/ignore` is consulted only when `core.excludesfile` is unset. To make its pattern effective, add `**/.claude/settings.local.json` to `~/.gitignore_global` (or point `core.excludesfile` at the XDG file instead). Do not run `git config --global core.excludesfile ~/.config/git/ignore` on top of the existing setting — it replaces the `~/.gitignore_global` registration.

The config also contains **Conventional Commits git aliases** (`feat`, `fix`, `refactor`, `docs`, `style`, `test`, `perf`, `build`, `ci`, `chore`, `wip`, `rev`) that accept `-s <scope>` and `-a` (attention/breaking) flags. These come from the `git-commit` Oh My Zsh plugin setup — copy the `[alias]` section from the old `~/.gitconfig` directly.

---

## 6. Node.js — mise + pnpm + bun

mise stays the standing choice for Node/Java version management on this machine — do not replace it with jenv/fnm. (An experimental jenv addition briefly replaced the mise `activate` line in `~/.zshrc`; reverted during this sync.)

### Current versions

| Tool | Version |
|------|---------|
| Node.js | `v24.13.1` (default) |
| npm | `11.13.0` |
| pnpm | `11.2.2` |
| bun | `1.3.14` |

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

Also installed via brew: `openjdk@21` (21.0.12).

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

- Version: `4.94.0`
- Architecture: `aarch64`
- Install: `brew install --cask docker-desktop`

No custom daemon config. Docker Compose is bundled with Docker Desktop.

Docker CLI completions are added in `.zshrc`:
```zsh
fpath=($HOME/.docker/completions $fpath)
```

---

## 11. JetBrains IDEs

Installed directly via brew cask (one cask per IDE, no JetBrains Toolbox):

| IDE | Purpose | Cask |
|-----|---------|------|
| IntelliJ IDEA | Java / Kotlin / general JVM | `intellij-idea` |
| Rider | .NET / C# | `rider` |
| WebStorm | JavaScript / TypeScript | `webstorm` |

```bash
brew install --cask intellij-idea rider webstorm
```

---

## 12. VS Code

Installed at `/Applications/Visual Studio Code.app`. The cask links the `code` CLI into `/opt/homebrew/bin`. If it is missing:

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

Key extensions (the full set of ~150 is tracked as `vscode` entries in `git/Brewfile` and installed by `brew bundle`):

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
code --install-extension github.vscode-github-actions
code --install-extension github.vscode-pull-request-github
code --install-extension hediet.vscode-drawio
code --install-extension ionutvmi.path-autocomplete
code --install-extension johnpapa.vscode-peacock
code --install-extension mhutchie.git-graph
code --install-extension mikestead.dotenv
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-dotnettools.csdevkit
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

## 13. Terminal Emulators — iTerm2 & Terminal.app

### iTerm2

iTerm2 is the primary terminal emulator (`/Applications/iTerm.app`).

#### Install

Download from https://iterm2.com/ or install via brew:

```bash
brew install --cask iterm2
```

#### Profile settings (Default profile)

| Setting | Value |
|---------|-------|
| Font | MesloLGS NF Regular, 15pt |
| Non-ASCII font | Monaco 12 (disabled — "Use Non-ASCII Font" = off) |
| Bold | enabled |
| Italic | enabled |
| Scrollback lines | 1000 |
| Unlimited scrollback | off |
| Transparency | 0 (opaque) |
| Theme | Dark — 16 ANSI colors + background/foreground/cursor customized |

> The font must be installed first — it comes from the `font-meslo-for-powerlevel10k` brew cask.

#### Restore settings

The color/font/behavior subset of the Default profile is tracked at `iterm2/dynamic-profile.json` (colors, ANSI palette, font, ligatures, scrollback — window position and other machine-local noise excluded on purpose). Copy it into iTerm2's Dynamic Profiles folder and it shows up as a selectable profile automatically, no plist surgery required:

```bash
mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles
cp iterm2/dynamic-profile.json ~/Library/Application\ Support/iTerm2/DynamicProfiles/dev-setup.json
```

Then in iTerm2: **Preferences → Profiles**, select **dev-setup**, and **Other Actions → Set as Default**.

Alternative for a full 1:1 clone (not used here — see note below): **Preferences → General → Preferences → Load preferences from a custom folder**, pointed at a synced folder.

### Terminal.app

Apple's built-in terminal (`/Applications/Utilities/Terminal.app`). Not the daily driver, but kept in sync as a fallback (e.g. before iTerm2 is installed on a fresh machine, or when iTerm2 is unavailable).

#### Restore settings

```bash
terminal/apply-terminal-theme.sh
```

Sets the **Basic** profile's font (MesloLGS NF, 15pt), background/text/cursor colors to match iTerm2's dark theme, and makes it the default + startup profile.

> **Known limitation:** Terminal.app's AppleScript API only exposes 4 color properties (background, normal text, bold text, cursor) — not the 16 ANSI colors. So the 16-color palette stays macOS default, and colored `ls`/`git`/p10k output won't match iTerm2 exactly. A pixel-perfect match would need a `.terminal` file import or hand-written NSKeyedArchiver `NSColor` blobs in the plist — not worth it for a fallback terminal.

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

#### Itsycal `v0.15.14` — `brew install --cask itsycal`

Compact calendar in the menu bar. Replaces the system clock date display.

| Setting | Value |
|---------|-------|
| Show day of week in icon | yes |
| Show month in icon | yes |
| Show events | 7 days ahead |
| Icon type | date-based |

No restore command needed — configure manually after install. Connect calendars via System Settings → Internet Accounts.

#### Stats `v3.0.20` — `brew install --cask stats`

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

#### Rectangle `v2.0.3` — `brew install --cask rectangle`

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

#### Postman `v12.30.0` — `brew install --cask postman`

API development and testing client. Collections and environments sync automatically through a Postman account — sign in after install to restore workspaces.

#### DBeaver Community `v26.2.2` — `brew install --cask dbeaver-community`

Universal database GUI. Supports PostgreSQL, MySQL, SQLite, Oracle, SQL Server, and more.

Config and connection data live at `~/Library/DBeaverData/workspace6/`. No automated restore — reconnect to databases manually after install. Connection passwords are stored in the system keychain.

#### Redis Insight `v3.8.0` — `brew install --cask redis-insight`

Redis GUI for browsing keys, running commands, and profiling. Config at `~/Library/Application Support/RedisInsight/config.json`.

| Setting | Value |
|---------|-------|
| Window size | 1300 × 860 px |

Databases are stored in the app's internal config — re-add connections manually after install.

#### Obsidian `v1.14.4` — `brew install --cask obsidian`

Markdown-based knowledge management and note-taking. Vaults are plain folders of `.md` files — back them up separately (e.g., iCloud, Dropbox, or a dedicated git repo). No Obsidian-specific config to restore beyond re-opening the vault folder.

#### Sublime Text `Build 4215` — `brew install --cask sublime-text`

Lightweight editor used for quick file viewing and edits that don't warrant opening a full IDE. No custom packages installed — used out of the box.

#### KeyStore Explorer `v5.7.0` — `brew install --cask keystore-explorer`

GUI for managing Java keystores, truststores, and certificates (JKS, PKCS12). No config to restore — open `.jks` / `.p12` files directly.

#### GitHub Desktop `v3.6.6` — `brew install --cask github`

Git GUI for visual diffs, branch management, and PR workflows. Sign in with GitHub account after install to restore repository access.

#### aws-vault — `brew install --cask aws-vault-binary`

Stores AWS credentials in the macOS Keychain instead of plaintext `~/.aws/credentials`, and vends temporary session credentials to the shell on demand. `~/.aws/config` only holds profile names/regions (no secrets) but isn't tracked in this repo — profile names are environment-specific. Re-create profiles with `aws-vault add <profile>` after install.

#### CodexBar — `brew install --cask codexbar`

Menu bar usage tracker for AI coding CLI token spend. No config to restore — connects to local tool state automatically.

#### Handy — `brew install --cask handy`

Push-to-talk speech-to-text. No config to restore — set the trigger hotkey once from its menu bar preferences after install.

---

### Communication

| App | Version | Install | Notes |
|-----|---------|---------|-------|
| Zoom | 7.2.1 | `brew install --cask zoom` | Work video calls |
| Microsoft Teams | 26225.1708 | `brew install --cask microsoft-teams` | Work meetings — needs `sudo` (pkg installer), can't run headless |
| Mattermost | 6.3.0 | `brew install --cask mattermost` | Team chat |
| Telegram | 12.5 | Mac App Store or https://telegram.org | Messaging |
| WhatsApp | 26.9.75 | Mac App Store or https://www.whatsapp.com | Messaging |

---

### Remote Access

| App | Version | Install | Notes |
|-----|---------|---------|-------|
| OpenVPN Connect | 3.8.2 | `brew install --cask openvpn-connect` | VPN — needs `sudo` (pkg installer); import `.ovpn` profile after install |
| Windows App | 11.4.3 | `brew install --cask windows-app` | Microsoft Remote Desktop — needs `sudo` (pkg installer); add PC connections manually |
| RealVNC Connect Viewer | 8.5.0 | `brew install --cask realvnc-connect-viewer` | Needs `sudo` (pkg installer) — remote desktop viewer |

---

### Media

| App | Version | Install | Notes |
|-----|---------|---------|-------|
| VLC | 3.0.24 | `brew install --cask vlc` | Universal media player |
| Stremio | — | https://www.stremio.com/downloads | Streaming platform — sign in to restore add-ons |

---

### Other Utilities

#### macOS InstantView `v3.24` — `brew install --cask instantview`

Display management driver for SMI (Silicon Motion) external displays. Enables extended/mirror mode for monitors connected over USB-C/DisplayLink. No configuration needed beyond connecting the display.

#### iTermAI `v1.1` — `brew install --cask itermai`

Standalone AI assistant window that integrates with the iTerm2 terminal. Installed separately from iTerm2 itself.

#### Pinta `v3.1.2` — `brew install --cask pinta`

Simple raster image editor (similar to MS Paint). Used for quick image annotations and crops. No configuration needed.

#### HiPixel — `brew install --cask hipixel`

Image upscaling tool. No configuration needed — used ad hoc.

#### PokeTokenBar — `brew install --cask chattymin/tap/poke-token-bar`

Menu bar novelty that turns AI coding token usage into a growing Pokémon. No config to restore.

---

### Input Devices

#### Logitech G HUB `v2026.6.974819` — `brew install --cask logitech-g-hub`

Configuration for Logitech gaming peripherals (mice, macros, RGB). Needs `sudo` (pkg installer). Settings sync to a Logitech account — sign in after install to restore profiles.

#### Logi Options+ `v2.7.970334` — `brew install --cask logi-options+`

Configuration for standard Logitech mice/keyboards (button remapping, gestures, flow between devices). Needs `sudo` (pkg installer). Replaces the older "Logi Options" (no +) app — settings don't carry over automatically, reconfigure after install.

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

### brew upgrade on login

A second user-level LaunchAgent runs `brew upgrade` at every login (log in `/tmp/brew-upgrade.log`):

```bash
cp launchagents/com.atilio.brew-upgrade.plist ~/Library/LaunchAgents/com.atilio.brew-upgrade.plist
launchctl load ~/Library/LaunchAgents/com.atilio.brew-upgrade.plist
```

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

### How the config is installed: symlinks

Everything in `claude/` is the source of truth. `setup.sh` links each item into `~/.claude/`, so any change made on the machine lands directly in this repo and is versioned. The exception is `settings.json`: Claude Code and plugins rewrite it, so the live file stays in `~/.claude/` and this repo keeps a copy that is refreshed by hand (see below).

| `~/.claude/` | → `claude/` in this repo |
|---|---|
| `CLAUDE.md` | Global rules (behavior, scope, commits, editing safety, code style) |
| `RTK.md` | RTK usage, imported from `CLAUDE.md` |
| `settings.json` (copy, not a link) | Model, permissions, hooks, plugins, statusline, autoMode |
| `statusline-command.sh` | Custom status line |
| `rules/` | Rules loaded every session |
| `hooks/` | Hook scripts referenced from `settings.json` |
| `commands/` | Slash commands (`/plan`, `/skill-create`) |
| `code-review-graph/languages.toml` | Registers markdown so `.vscode/*.md` docs get indexed |

**Refreshing the `settings.json` copy:** after changing settings, run the `sync-configuration` skill, or by hand:

```bash
cp ~/.claude/settings.json ~/Projects/Personal/dev-setup/claude/settings.json
rg -n -i '\.corp\.|\.internal\b|\.elb\.|amazonaws\.com|ghp_|ctx7sk|sk-ant-|Bearer ' ~/Projects/Personal/dev-setup/claude/settings.json   # must print nothing
```

### Global config — `~/.claude/CLAUDE.md`

General rules: no AI mentions in any output, confirmation before destructive commands, reply in the user's language, scope discipline, commit workflow (always via `/commit-message`, never commit or push without explicit per-commit authorization), editing safety for accented text, and code style (project architecture first, otherwise the simplest solution; strict comment rules). The project-level `CLAUDE.md` lives at `.vscode/CLAUDE.md` in each repo.

### RTK (Rust Token Killer) — `~/.claude/RTK.md`

RTK is a CLI proxy that filters command output before it reaches Claude. A `PreToolUse` hook rewrites Bash commands (`git status` → `rtk git status`). Useful commands: `rtk gain`, `rtk discover`, `rtk proxy <cmd>`.

### Settings — `~/.claude/settings.json`

- `permissions.allow` — read-only tools, safe git commands, rtk, file-stash, context-mode and code-review-graph overview tools
- `permissions.deny` — secrets (`~/.ssh`, `~/.aws`, `.env`, keys), history rewrites, discarding work, deleting refs, `rm -rf`, `sudo`, package publishing
- `enableAllProjectMcpServers: false` — a project `.mcp.json` needs approval the first time
- `autoMode` — generic environment rules for auto mode (production = anything named `prod`, protected IaC scopes, no commit/push without authorization); no organization-specific hosts or paths
- `hooks.*` — see below
- `enabledPlugins` + `extraKnownMarketplaces` — caveman, ponytail, context-mode, token-optimizer, coderabbit
- `model`, `advisorModel`, `env`, `skillOverrides`, `tui`, `autoCompactEnabled` — session behavior
- `cleanupPeriodDays: 1095` — keeps transcripts for 3 years (used by claude-code-stats)
- `env.PONYTAIL_SUBAGENT_MATCHER` — ponytail rules only go to code-writing subagents, not to read-only ones like Explore

Paths in `settings.json` use `/Users/atilio/`; update them if the home directory differs.

### Status Line — `~/.claude/statusline-command.sh`

Shows model, context usage, session cost, total tokens, session duration and lines changed.

### Hooks — `~/.claude/hooks/`

| Hook | Event | What it does |
|---|---|---|
| `pre-bash.sh` | PreToolUse — Bash | Blocks destructive commands (history rewrites, `rm -rf`, `sudo`, destructive SQL, `curl \| sh`) |
| `prefer-search-tools-guard.sh` | PreToolUse — Bash | Blocks `grep` and unbounded `find /`, pushing toward `rg` / `fd` |
| `strip-quoted.sh` | helper | Removes quoted text and heredoc bodies, and splits chained commands, so the two guards above only check what actually runs |
| `code-review-graph-guard.sh` | PreToolUse — Glob/Grep | Blocks text search when the repo has a code-review-graph database |
| `file-stash-guard.sh` | PreToolUse — Read | Denies the first Read of each file to force file-stash; the retry passes (needed before Edit) |
| `pre-websearch.sh` | PreToolUse — WebSearch | Asks for approval showing the query |
| `post-edit-encoding.sh` | PostToolUse — Edit/Write | Warns if a file stops being UTF-8 (protects accents) |
| `context-mode-cache-heal.mjs` | SessionStart | Re-links a broken context-mode plugin cache path |
| `session-start-tool-reminders.sh` | SessionStart | code-review-graph reminder when the repo has a graph |
| `test-hooks.sh` | manual | Self-check for the two Bash guards: `bash ~/.claude/hooks/test-hooks.sh` |

#### Third-party tool hooks (not provisioned by this repo)

`settings.json` also wires most hook events to tools installed independently of `setup.sh`:

- `~/.orca/agent-hooks/claude-hook.sh` — Orca agent orchestration (one short line per event that calls Orca's own script)
- `~/.pixel-agents/hooks/claude-hook.js` — Pixel Agents visualizer
- `~/.config/iterm2/cc-status` — iTerm2 session status

If a tool is not installed, its hook is a no-op.

### Rules — `~/.claude/rules/`

| File | Purpose |
|------|---------|
| `tools.md` | code-review-graph, file-stash, model routing and the tool-priority list |
| `coding-style.md` | Size limits, error handling, input validation, pre-commit security checks |
| `context7.md` | When and how to use Context7 for library docs |

### Commands — `~/.claude/commands/`

| Command | Purpose |
|---------|---------|
| `/plan` | Restate requirements, risks and phases; wait for confirmation before editing |
| `/skill-create` | Extract coding patterns from git history into a `SKILL.md` |

### Skills / Plugins

**Marketplace plugins** — installed via the Claude Code plugin system (entries already in `settings.json`):

| Plugin | Key | Skills |
|--------|-----|--------|
| coderabbit | `coderabbit@claude-plugins-official` | `autofix`, `code-review` |
| context-mode | `context-mode@context-mode` | Context optimization and token savings |
| token-optimizer | `token-optimizer@alexgreensh-token-optimizer` | Token usage tracking and auditing |
| caveman | `caveman@caveman` | Terse response-compression persona |
| ponytail | `ponytail@ponytail` | Lazy/minimal-diff engineering persona |

**Personal skills** — stored at https://github.com/atilio-ts/claude-skills, cloned to
`~/Projects/Personal/claude-skills/` and symlinked into `~/.claude/skills/`:

- `commit-message` — generates conventional commit messages reading git diff and project history
- `custom-init` — bootstraps a new project with file-stash + code-review-graph
- `estimate` — technical analysis and effort estimation (Spanish/English)
- `readme-generator` — generates README files from project context
- `timesheet` — generates Clockify-format timesheet entries from git branch changes (English/Spanish, max 3h per task)
- `user-story` — writes user stories and Jira tasks

**dev-setup project skills** — stored in this repo under `skills/`, discovered from the repo's working directory (NOT symlinked into `~/.claude/skills` — they're project-scoped, only active while working inside this repo):

- `sync-configuration` — syncs live machine config back to this repo (run periodically to keep backup current)
- `install-dev-setup` — interactive step-by-step guide to install this full dev environment on a new machine

**dev-setup global skills** — stored in this repo under `claude/skills/`, symlinked into `~/.claude/skills/` (personal skills that don't have a home in the separate `claude-skills` repo):

- `context7-mcp` — Context7 MCP usage notes
- `learned` — currently empty placeholder (tracked with `.gitkeep`)

#### Reinstall skills on new machine

```bash
# 1. Marketplace plugins (run inside Claude Code or via CLI)
claude plugin install coderabbit@claude-plugins-official
claude plugin install context-mode@context-mode
claude plugin install token-optimizer@alexgreensh-token-optimizer
claude plugin install caveman@caveman
claude plugin install ponytail@ponytail

# 2. Personal skills (clone repo and create symlinks)
git clone https://github.com/atilio-ts/claude-skills ~/Projects/Personal/claude-skills
for skill in commit-message custom-init estimate readme-generator timesheet user-story; do
  ln -sf ~/Projects/Personal/claude-skills/$skill ~/.claude/skills/$skill
done

# 3. dev-setup global skills (symlink from this repo — content lives only here)
for skill in context7-mcp learned; do
  ln -sf ~/Projects/Personal/dev-setup/claude/skills/$skill ~/.claude/skills/$skill
done
```

> `sync-configuration` and `install-dev-setup` need no symlink step — Claude Code discovers them automatically from `skills/` when working inside this repo.

> The marketplace and enabledPlugins entries are already in `settings.json` — they will be applied when the file is copied.

### MCP Server — file-stash

**file-stash** is a Claude Code MCP tool that caches file reads by content hash. On repeated reads it returns cached content instead of re-reading from disk, saving significant tokens across sessions.

It is pre-authorized in `settings.json` (`mcp__filestash__read_file`, `mcp__filestash__read_files`, `mcp__filestash__stash_status`, `mcp__filestash__stash_clear`). The MCP server config lives in `~/.claude.json` (not `settings.json`).

Install globally:

```bash
npm install -g file-stash
```

Get the binary path and add it to `~/.claude.json` manually:

```bash
# Get the path — will be something like:
# /Users/<username>/.local/share/mise/installs/node/<version>/bin/file-stash
echo "$(npm prefix -g)/bin/file-stash"
```

The `mcpServers` block in `~/.claude.json`:

```json
"mcpServers": {
  "filestash": {
    "command": "/Users/<username>/.local/share/mise/installs/node/<version>/bin/file-stash",
    "args": ["serve"],
    "env": {
      "FILESTASH_DIR": ".vscode/file-stash"
    }
  }
}
```

Replace `<username>` and `<version>` with the output of the command above. Restart Claude Code after editing.

**`.vscode/`-scoped stash directory, no patch needed.** Unlike code-review-graph, file-stash needs no source patch at all — `getStashDir()` in the installed package (`agent-file-stash`, `dist/cli.mjs`) already reads `process.env.FILESTASH_DIR ?? ".file-stash"` and resolves it with `path.resolve()` against the server process's `cwd` (the project directory, same `$PWD`-at-startup resolution code-review-graph uses). Setting `FILESTASH_DIR=.vscode/file-stash` once in the global MCP registration above relocates the stash database under `.vscode/` for every project automatically — no separate `.filestash`/`.file-stash` line needed in any project's `.gitignore`, same rationale as the code-review-graph move.

This is a manual, one-time edit to `~/.claude.json` — per the standing rule (see `custom-init`'s Important Notes), tooling never edits that file automatically, only prints instructions. Restart Claude Code after adding the `env` block for it to take effect; existing `.file-stash/` directories at repo roots are stale once this is set and can be deleted (they hold a cache, not anything precious — file-stash rebuilds it from scratch on first read).

> Bug found while auditing this: `custom-init`'s Step 7 (`.gitignore` update) checks for a `.filestash` line (no hyphen), but the tool's real default directory is `.file-stash` (with hyphen) — the two have never matched. Harmless while `.file-stash` sat at the repo root outside `.vscode` (git still ignored it via the literal name once added correctly elsewhere), but worth fixing in `custom-init` regardless, especially now that Step 7 no longer needs a `.filestash`/`.file-stash` entry at all if `FILESTASH_DIR` is set globally.

### MCP Server — code-review-graph (per-project)

`code-review-graph` builds a persistent structural graph of the codebase using Tree-sitter. It provides impact analysis, semantic search, and call-path traversal — use it in any project via the `mcp__code-review-graph__*` tools.

Install:

```bash
pipx install code-review-graph
```

Build the graph, storing everything under `.vscode/` instead of a top-level `.code-review-graph/` (so it rides along with `.vscode` being gitignored — no separate `.code-review-graph` gitignore entry needed):

```bash
code-review-graph build --data-dir .vscode/code-review-graph
```

`--data-dir` is a first-class flag (not a patch) that persists in a machine-wide registry at `~/.code-review-graph/registry.json`, keyed by resolved repo path — set it once per repo and every later `code-review-graph build` / `status` / MCP tool call resolves there automatically, no need to pass the flag again. Claude Code detects the graph automatically via the MCP plugin — no manual `~/.claude.json` entry needed. See the CLAUDE.md rules for usage patterns.

**Doc indexing (`.vscode/` and `temporary/`) — three patches, applied globally.** By default, three things stand between the graph and our per-project docs — `.vscode/*.md` CLAUDE.md docs and `temporary/*.md` scratch analysis notes, both usually gitignored but genuinely useful content:

1. `collect_all_files()` prefers `git ls-files` for file discovery, so any project where these dirs are gitignored (the normal case) never even considers those files as candidates.
2. `.md` isn't a recognized extension at all until a custom language is registered (requires code-review-graph 2.3.6+), and that registration is hardcoded to `<repo_root>/.code-review-graph/languages.toml` — there's no built-in user-level config path.
3. Even the repo-local override in point 2 is hardcoded to the repo root, not `.vscode/` — so a project using `--data-dir .vscode/code-review-graph` for the database would still need a stray `.code-review-graph/languages.toml` sitting outside it.

`setup.sh` patches the installed package for all three, machine-wide, with no per-repo file required:

- `code-review-graph/patch_vscode_docs.py` — `collect_all_files()` always walks `EXTRA_DOC_DIRS = (".vscode", "temporary")` regardless of git tracking status. Idempotently upgrades an already-`.vscode`-only-patched install in place if it encounters one (older machines / earlier runs of this script).
- `code-review-graph/patch_global_languages.py` — `load_custom_languages()` falls back to `~/.claude/code-review-graph/languages.toml` (deployed from `claude/code-review-graph/languages.toml` in this repo) whenever a project has no `languages.toml` of its own. A repo-local file still always wins when present — this is a fallback, not a merge.
- `code-review-graph/patch_config_path.py` — the repo-local override itself moves from `<repo_root>/.code-review-graph/languages.toml` to `<repo_root>/.vscode/code-review-graph/languages.toml`, so it sits next to the database instead of at the repo root.

Together, plus `--data-dir`: any repo with code-review-graph installed and built gets `.vscode/*.md` and `temporary/*.md` docs indexed as markdown automatically, and nothing code-review-graph-related is ever created outside `.vscode/`. Verified on a project with no local `languages.toml` (default data dir) — `markdown` shows in `code-review-graph status` after a rebuild — and on a project with a repo-local `languages.toml` moved into `.vscode/code-review-graph/` with `--data-dir` pointed at the same place (file count rose once `temporary/` walking was added) — an old `.code-review-graph/` left at repo root was just a stale duplicate of an already-current rebuild, safe to delete, nothing lost.

All three patches live in site-packages, not in a config file, so **`pipx upgrade code-review-graph` silently wipes them**. Reapply after every upgrade:

```bash
pipx upgrade code-review-graph
~/Projects/Personal/dev-setup/code-review-graph/apply-patches.sh
```

The apply script is idempotent (safe to run even if already patched) and will fail loudly if code-review-graph's internals change enough that a patch no longer applies cleanly — in that case, diff the new `collect_all_files()` / `load_custom_languages()` / `CONFIG_RELATIVE_PATH` against the ANCHOR/PATCHED blocks in the corresponding `patch_*.py` and update them.

**Per-project override.** `/custom-init` (in `~/Projects/Personal/claude-skills/custom-init/`) still writes an explicit repo-local `.vscode/code-review-graph/languages.toml` for every new project (Step 3b) and builds with `--data-dir .vscode/code-review-graph` — the global fallback above only helps on machines that have these patches applied. Note this repo-local file is **not committed** either, since it lives under gitignored `.vscode/`; it's machine-local like everything else there, and `/custom-init` (or the global fallback) recreates it on any machine that needs it. `languages.toml.template` in this directory is the same content, for manually bootstrapping older projects `/custom-init` hasn't touched. For a project that already has a top-level `.code-review-graph/`, migrate with:

```bash
mkdir -p .vscode/code-review-graph
mv .code-review-graph/languages.toml .vscode/code-review-graph/languages.toml 2>/dev/null  # if present
code-review-graph build --data-dir .vscode/code-review-graph  # rebuilds fresh; old dir is now a stale duplicate
rm -f .code-review-graph/graph.db .code-review-graph/graph.db-shm .code-review-graph/graph.db-wal .code-review-graph/.gitignore
rmdir .code-review-graph
```

Then remove any `.code-review-graph` line from `.gitignore` — it's redundant once everything lives under the already-ignored `.vscode/`.

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
- **file-stash first** — always use file-stash `read_file` MCP tool instead of built-in Read tool for file reads (saves tokens via hash-based caching)
- **code-review-graph before search** — when `.code-review-graph/` or `.vscode/code-review-graph/` exists in a project, use `mcp__code-review-graph__*` tools to navigate instead of Glob/Grep
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

No external dependencies — Python 3.10+ (standard library only; uses `X | None` union type syntax, which fails on macOS's stock `/usr/bin/python3`).

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

Add (use the full path to a Python 3.10+ interpreter — cron runs with a minimal `PATH` that resolves to the old system `/usr/bin/python3` otherwise, which crashes with `TypeError: unsupported operand type(s) for |: 'types.GenericAlias' and 'NoneType'`):

```
*/10 * * * * cd $HOME/Projects/Github/claude-code-stats && /opt/homebrew/bin/python3 extract_stats.py 2>&1 >> update.log
```

This keeps the dashboard up to date in the background. Open `public/index.html` in any browser to view — it reads `dashboard_data.json` which is regenerated on each run.

> If this ever misfires silently again: failures land as local mail (`mail -H` at the shell, or `cat /var/mail/$USER`), not anywhere visible in Claude Code or the dashboard itself.

---

## 18. opencode

An alternative terminal-based AI coding CLI, used alongside Claude Code. Config lives at `~/.config/opencode/` and mirrors the same caveman-plugin setup used in Claude Code (`caveman` skills/commands/agents — see section 15).

**Install:**

```bash
brew install opencode
```

### Config

Tracked in this repo at `opencode/` — `opencode.json` (MCP server: `filestash`; plugin: `caveman`), `AGENTS.md`, `package.json`, and the `agents/`, `commands/`, `skills/`, `plugins/` directories. Not tracked: `node_modules/`, lockfiles (`bun.lock`, `package-lock.json` — regenerate with `bun install`), and `.caveman-opencode-ownership.json` (regenerates itself on first run).

### Restore

```bash
mkdir -p ~/.config/opencode
cp -r opencode/* ~/.config/opencode/
cd ~/.config/opencode && bun install
```

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
[ ] brew install --cask docker-desktop intellij-idea rider webstorm
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
[ ] Run setup.sh — links ~/.claude config (CLAUDE.md, RTK.md, statusline, rules, hooks, commands) to claude/ in this repo and copies settings.json
[ ] Verify hooks: bash ~/.claude/hooks/test-hooks.sh
[ ] Install Claude Code plugins: caveman + ponytail + context-mode + token-optimizer + coderabbit (setup.sh does it if claude is installed)
[ ] Clone personal skills: git clone https://github.com/atilio-ts/claude-skills ~/Projects/Personal/claude-skills + create symlinks (see section 15)
[ ] Install and configure file-stash MCP server (see section 15)
[ ] Seed user profile memory files under ~/.claude/projects/.../memory/
[ ] Apply macOS system preferences (see section 14 — Appearance, Trackpad, Keyboard, Finder, Dock, Mission Control, Accessibility, Energy)
[ ] brew install --cask rectangle maccy appcleaner itsycal stats vlc
[ ] Apply Rectangle defaults (see section 14)
[ ] Apply Maccy defaults (see section 14)
[ ] AppCleaner: Preferences → SmartDelete → enable
[ ] brew install --cask postman redis-insight obsidian keystore-explorer github sublime-text pinta dbeaver-community
[ ] brew install --cask iterm2 itermai lm-studio mattermost logitech-g-hub logi-options+
[ ] brew install --cask openvpn-connect realvnc-connect-viewer windows-app zoom microsoft-teams instantview firefox@developer-edition
[ ] Install manually: FineTune
[ ] Install manually: Telegram, WhatsApp, Stremio
[ ] Import .ovpn profile into OpenVPN Connect after install
[ ] Sign in to: GitHub Desktop, Postman, Zoom, Telegram, WhatsApp, Logi Options+, Logitech G HUB
[ ] Clone claude-code-stats: git clone https://github.com/AeternaLabsHQ/claude-code-stats ~/Projects/Github/claude-code-stats
[ ] Configure claude-code-stats: cp config.example.json config.json → edit plan_history
[ ] Set up cron job: */10 * * * * cd ~/Projects/Github/claude-code-stats && /opt/homebrew/bin/python3 extract_stats.py 2>&1 >> update.log
[ ] Create ~/.config/git/ignore with **/.claude/settings.local.json (only read if core.excludesfile is unset — see section 5)
[ ] Copy tmux config: cp tmux/tmux.conf ~/.tmux.conf
[ ] Copy iTerm2 dynamic profile: cp iterm2/dynamic-profile.json ~/Library/Application\ Support/iTerm2/DynamicProfiles/dev-setup.json → set as Default in iTerm2 Preferences
[ ] Apply Terminal.app theme: bash terminal/apply-terminal-theme.sh
[ ] Install opencode: brew install opencode (already in the Brewfile) → cp -r opencode/* ~/.config/opencode/ → bun install
[ ] Set up aws-vault profiles: aws-vault add <profile>
```
