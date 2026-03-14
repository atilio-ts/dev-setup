#!/usr/bin/env bash
# setup.sh — restore dev environment on a new macOS machine
# Run from the root of this repo: bash setup.sh

set -e

REPO="$(cd "$(dirname "$0")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
step() { echo -e "\n${YELLOW}▶${NC} $1"; }

# ─── Homebrew ────────────────────────────────────────────────────────────────
step "Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  ok "Homebrew installed"
else
  ok "Homebrew already installed"
fi

brew tap lucassabrero/tap 2>/dev/null || true
brew tap sheeki03/tap 2>/dev/null || true
brew bundle install --file="$REPO/git/Brewfile"
cp "$REPO/git/Brewfile" "$HOME/Brewfile"
ok "Brew packages installed and Brewfile copied to ~/"

git lfs install
ok "git-lfs initialized"

# ─── Shell ───────────────────────────────────────────────────────────────────
step "Shell — Zsh + Oh My Zsh + Powerlevel10k"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "Oh My Zsh installed"
else
  ok "Oh My Zsh already installed"
fi

OMZ_CUSTOM="$HOME/.oh-my-zsh/custom/plugins"
[ ! -d "$OMZ_CUSTOM/zsh-autosuggestions" ] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$OMZ_CUSTOM/zsh-autosuggestions"
[ ! -d "$OMZ_CUSTOM/zsh-syntax-highlighting" ] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$OMZ_CUSTOM/zsh-syntax-highlighting"
ok "Zsh plugins cloned"

cp "$REPO/shell/zshrc" "$HOME/.zshrc"
cp "$REPO/shell/p10k.zsh" "$HOME/.p10k.zsh"
ok "Shell configs copied — update username paths in ~/.zshrc if needed"

# ─── Git ─────────────────────────────────────────────────────────────────────
step "Git"
cp "$REPO/git/gitconfig" "$HOME/.gitconfig"
cp "$REPO/git/gitignore_global" "$HOME/.gitignore_global"
git config --global core.excludesfile "$HOME/.gitignore_global"
ok "Git config copied and global gitignore registered"
warn "Update name/email in ~/.gitconfig if this is a different user"

# ─── Neovim (LazyVim) ────────────────────────────────────────────────────────
step "Neovim"
if [ ! -d "$HOME/.config/nvim" ]; then
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
  ok "LazyVim starter cloned"
fi
cp "$REPO/nvim/init.lua" "$HOME/.config/nvim/init.lua"
cp "$REPO/nvim/lazy-lock.json" "$HOME/.config/nvim/lazy-lock.json"
cp "$REPO/nvim/lua/config/"*.lua "$HOME/.config/nvim/lua/config/"
ok "Neovim config copied"

# ─── Atuin ───────────────────────────────────────────────────────────────────
step "Atuin"
mkdir -p "$HOME/.config/atuin"
cp "$REPO/atuin/config.toml" "$HOME/.config/atuin/config.toml"
ok "Atuin config copied — run 'atuin login' to sync history"

# ─── gh CLI ──────────────────────────────────────────────────────────────────
step "gh CLI"
mkdir -p "$HOME/.config/gh"
cp "$REPO/gh/config.yml" "$HOME/.config/gh/config.yml"
ok "gh config copied — run 'gh auth login' to authenticate"

# ─── VS Code ─────────────────────────────────────────────────────────────────
step "VS Code"
VSCODE_DIR="$HOME/Library/Application Support/Code/User"
if [ -d "$VSCODE_DIR" ]; then
  cp "$REPO/vscode/settings.json" "$VSCODE_DIR/settings.json"
  ok "VS Code settings copied"
  warn "Install extensions: run 'code --install-extension <id>' or enable Settings Sync"
else
  warn "VS Code not found — install it first, then re-run this section"
fi

# ─── Claude Code ─────────────────────────────────────────────────────────────
step "Claude Code"
mkdir -p "$HOME/.claude/hooks"
cp "$REPO/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
cp "$REPO/claude/settings.json" "$HOME/.claude/settings.json"
cp "$REPO/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
cp "$REPO/claude/hooks/pre-bash.sh" "$HOME/.claude/hooks/pre-bash.sh"
cp "$REPO/claude/hooks/pre-websearch.sh" "$HOME/.claude/hooks/pre-websearch.sh"
chmod +x "$HOME/.claude/statusline-command.sh" "$HOME/.claude/hooks/"*.sh
ok "Claude Code config and hooks copied"
warn "Update username paths in ~/.claude/settings.json"

# Seed user profile memory
MEMORY_DIR="$HOME/.claude/projects/-Users-$(whoami)-Projects/memory"
mkdir -p "$MEMORY_DIR"
cp "$REPO/claude/memory/MEMORY.md" "$MEMORY_DIR/MEMORY.md"
cp "$REPO/claude/memory/user_profile.md" "$MEMORY_DIR/user_profile.md"
ok "Claude user profile memory seeded"

# ─── Spicetify ───────────────────────────────────────────────────────────────
step "Spicetify"
if command -v spicetify &>/dev/null && [ -d "/Applications/Spotify.app" ]; then
  mkdir -p "$HOME/.config/spicetify"
  cp "$REPO/spicetify/config-xpui.ini" "$HOME/.config/spicetify/config-xpui.ini"
  spicetify backup apply 2>/dev/null || true
  ok "Spicetify config applied — install Marketplace theme manually if needed"
else
  warn "Spotify or spicetify not found — skipping"
fi

# ─── asimov (Time Machine exclusions) ────────────────────────────────────────
step "asimov"
LAUNCHAGENTS_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$LAUNCHAGENTS_DIR"
cp "$REPO/launchagents/homebrew.asimov.plist" "$LAUNCHAGENTS_DIR/homebrew.asimov.plist"
launchctl load "$LAUNCHAGENTS_DIR/homebrew.asimov.plist" 2>/dev/null || true
ok "asimov LaunchAgent installed and loaded"

# ─── navi cheatsheets ────────────────────────────────────────────────────────
step "navi"
navi repo add denisidoro/cheats 2>/dev/null || true
ok "navi community cheatsheets added"

# ─── macOS defaults ──────────────────────────────────────────────────────────
step "macOS Dock"
defaults write com.apple.dock orientation left
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 66
killall Dock
ok "Dock configured (left, autohide, size 66)"

# ─── Done ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}Setup complete.${NC} Remaining manual steps:"
echo "  • source ~/.zshrc  (or open a new terminal)"
echo "  • p10k configure   (if font isn't rendering correctly)"
echo "  • gh auth login"
echo "  • atuin login"
echo "  • Install Docker Desktop, JetBrains Toolbox, Rectangle, Maccy, Obsidian, Postman"
echo "  • Install Claude Code skills: claude plugins install gstack"
echo "  • Install and configure cachebro MCP server"
echo "  • Install mise: curl https://mise.run | sh  →  mise install node@24.13.1"
echo "  • Install Java JDKs (Corretto 21, 24) via mise or jenv"
