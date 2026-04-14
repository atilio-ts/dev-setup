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

# ─── nano ────────────────────────────────────────────────────────────────────
step "nano"
cp "$REPO/nano/nanorc" "$HOME/.nanorc"
mkdir -p "$HOME/.nano"
cp "$REPO/nano/typescript.nanorc" "$HOME/.nano/typescript.nanorc"
ok "nano config and TypeScript syntax copied"

# ─── vim ─────────────────────────────────────────────────────────────────────
step "vim"
cp "$REPO/vim/vimrc" "$HOME/.vimrc"
ok "vim config copied"

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

# ─── brew upgrade on login ───────────────────────────────────────────────────
step "brew upgrade LaunchAgent"
cp "$REPO/launchagents/com.atilio.brew-upgrade.plist" "$LAUNCHAGENTS_DIR/com.atilio.brew-upgrade.plist"
launchctl load "$LAUNCHAGENTS_DIR/com.atilio.brew-upgrade.plist" 2>/dev/null || true
ok "brew upgrade LaunchAgent installed and loaded"

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

# ─── Claude Code skills ───────────────────────────────────────────────────────
step "Claude Code skills"
if command -v claude &>/dev/null; then
  claude plugins marketplace add jeffallan/claude-skills 2>/dev/null || true
  claude plugin install fullstack-dev-skills@fullstack-dev-skills 2>/dev/null || true
  ok "fullstack-dev-skills plugin installed"
  claude plugin install everything-claude-code@everything-claude-code 2>/dev/null || true
  ok "everything-claude-code plugin installed"
  claude plugin install coderabbit@claude-plugins-official 2>/dev/null || true
  ok "coderabbit plugin installed"
  npx skills add vercel-labs/agent-skills --yes --global 2>/dev/null || true
  ok "vercel-labs/agent-skills installed"
  claude plugins install gstack 2>/dev/null || true
  ok "gstack skills installed"

  # Remove unused skills from fullstack-dev-skills
  FDS="$HOME/.claude/plugins/marketplaces/fullstack-dev-skills/skills"
  for skill in atlassian-mcp cli-developer cpp-pro django-expert embedded-systems \
    fastapi-expert flutter-expert golang-pro graphql-architect kotlin-specialist \
    laravel-specialist pandas-pro php-pro playwright-expert rag-architect \
    rails-expert rust-engineer salesforce-developer shopify-expert swift-expert \
    vue-expert vue-expert-js wordpress-pro; do
    rm -r "$FDS/$skill" 2>/dev/null && echo "  removed fds: $skill" || true
  done
  ok "unused fullstack-dev-skills skills removed"

  # Remove unused skills from everything-claude-code
  ECC="$HOME/.claude/plugins/marketplaces/everything-claude-code/skills"
  for skill in claude-api clickhouse-io content-engine cpp-coding-standards cpp-testing \
    crosspost django-patterns django-security django-tdd django-verification dmux-workflows \
    fal-ai-media golang-patterns golang-testing kotlin-coroutines-flows kotlin-exposed-patterns \
    kotlin-ktor-patterns kotlin-patterns kotlin-testing liquid-glass-design perl-patterns \
    perl-security perl-testing plankton-code-quality ralphinho-rfc-pipeline \
    returns-reverse-logistics swift-actor-persistence swift-concurrency-6-2 \
    swift-protocol-di-testing swiftui-patterns visa-doc-translate x-api; do
    rm -r "$ECC/$skill" 2>/dev/null && echo "  removed ecc: $skill" || true
  done
  ok "unused everything-claude-code skills removed"

  # Remove unused everything-claude-code commands
  ECC_CMD="$HOME/.claude/plugins/marketplaces/everything-claude-code/commands"
  for cmd in go-build go-review go-test kotlin-build kotlin-review kotlin-test python-review; do
    rm "$ECC_CMD/$cmd.md" 2>/dev/null && echo "  removed cmd: $cmd" || true
  done
  ok "unused everything-claude-code commands removed"
else
  warn "Claude Code not found — install it first, then run skills setup"
fi

# ─── Personal Claude skills ───────────────────────────────────────────────────
step "Personal Claude skills (atilio-ts/claude-skills)"
CLAUDE_SKILLS_DIR="$HOME/Projects/Personal/claude-skills"
if [ ! -d "$CLAUDE_SKILLS_DIR" ]; then
  mkdir -p "$HOME/Projects/Personal"
  git clone https://github.com/atilio-ts/claude-skills "$CLAUDE_SKILLS_DIR"
  ok "claude-skills repo cloned"
else
  ok "claude-skills repo already present"
fi

mkdir -p "$HOME/.claude/skills"
for skill_dir in "$CLAUDE_SKILLS_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  if [ -f "$skill_dir/SKILL.md" ]; then
    ln -sfn "$skill_dir" "$HOME/.claude/skills/${skill_name}"
    ok "skill '${skill_name}' linked"
  fi
done

# ─── cachebro MCP ─────────────────────────────────────────────────────────────
step "cachebro MCP"
npx cachebro init 2>/dev/null || true
ok "cachebro configured — restart Claude Code to activate"

# ─── claude-code-stats ───────────────────────────────────────────────────────
step "claude-code-stats"
STATS_DIR="$HOME/Projects/Github/claude-code-stats"
if [ ! -d "$STATS_DIR" ]; then
  mkdir -p "$HOME/Projects/Github"
  git clone https://github.com/AeternaLabsHQ/claude-code-stats "$STATS_DIR"
  ok "claude-code-stats cloned"
else
  ok "claude-code-stats already cloned"
fi

if [ ! -f "$STATS_DIR/config.json" ]; then
  cp "$STATS_DIR/config.example.json" "$STATS_DIR/config.json"
  ok "config.json created from example — update display_name and plan_history"
else
  ok "config.json already exists"
fi

CRON_JOB="*/10 * * * * cd $STATS_DIR && python3 extract_stats.py 2>&1 >> update.log"
if ! crontab -l 2>/dev/null | grep -qF "claude-code-stats"; then
  (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
  ok "cron job installed (every 10 min)"
else
  ok "cron job already installed"
fi

# ─── Done ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}Setup complete.${NC} Remaining manual steps:"
echo "  • source ~/.zshrc  (or open a new terminal)"
echo "  • p10k configure   (if font isn't rendering correctly)"
echo "  • gh auth login"
echo "  • atuin login"
echo "  • Install mise: curl https://mise.run | sh  →  mise install node@24.13.1"
echo "  • Install Java JDKs (Corretto 21, 24): mise install java@corretto-21 java@corretto-24"
echo "  • Install Docker Desktop, JetBrains Toolbox, Obsidian, Postman"
echo "  • VS Code: Cmd+Shift+P → 'Shell Command: Install code command in PATH'"
