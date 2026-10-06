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

# ─── tmux ────────────────────────────────────────────────────────────────────
step "tmux"
cp "$REPO/tmux/tmux.conf" "$HOME/.tmux.conf"
ok "tmux config copied"

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

# ─── Terminal emulators ──────────────────────────────────────────────────────
step "iTerm2 dynamic profile"
mkdir -p "$HOME/Library/Application Support/iTerm2/DynamicProfiles"
cp "$REPO/iterm2/dynamic-profile.json" "$HOME/Library/Application Support/iTerm2/DynamicProfiles/dev-setup.json"
ok "iTerm2 dynamic profile installed — set 'dev-setup' as Default in Preferences → Profiles"

step "Terminal.app theme"
if [ -d "/Applications/Utilities/Terminal.app" ] || [ -d "/System/Applications/Utilities/Terminal.app" ]; then
  bash "$REPO/terminal/apply-terminal-theme.sh"
  ok "Terminal.app 'Basic' profile themed and set as default"
else
  warn "Terminal.app not found at expected path — skipping"
fi

# ─── opencode ────────────────────────────────────────────────────────────────
step "opencode"
if command -v opencode &>/dev/null || brew list opencode &>/dev/null 2>&1; then
  mkdir -p "$HOME/.config/opencode"
  cp -r "$REPO/opencode/"* "$HOME/.config/opencode/"
  if command -v bun &>/dev/null; then
    (cd "$HOME/.config/opencode" && bun install) && ok "opencode config copied and dependencies installed"
  else
    warn "bun not found — run 'bun install' in ~/.config/opencode manually"
  fi
else
  warn "opencode not installed (brew install opencode) — skipping config copy"
fi

# ─── Claude Code ─────────────────────────────────────────────────────────────
step "Claude Code"
mkdir -p "$HOME/.claude"
for item in CLAUDE.md RTK.md statusline-command.sh rules hooks commands; do
  target="$HOME/.claude/$item"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.pre-dev-setup"
    warn "Existing ~/.claude/$item moved to $item.pre-dev-setup"
  fi
  ln -sfn "$REPO/claude/$item" "$target"
done
chmod +x "$REPO/claude/statusline-command.sh" "$REPO/claude/hooks/"*.sh
if [ -e "$HOME/.claude/settings.json" ] && [ ! -L "$HOME/.claude/settings.json" ]; then
  cp "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.pre-dev-setup"
  warn "Existing ~/.claude/settings.json backed up as settings.json.pre-dev-setup"
fi
[ -L "$HOME/.claude/settings.json" ] && unlink "$HOME/.claude/settings.json"
cp "$REPO/claude/settings.json" "$HOME/.claude/settings.json"
ok "Claude Code config linked from $REPO/claude (CLAUDE.md, RTK.md, statusline, rules, hooks, commands); settings.json copied"
warn "Update username paths in ~/.claude/settings.json if your home directory is not /Users/atilio"

# ─── code-review-graph ───────────────────────────────────────────────────────
step "code-review-graph"
if ! command -v code-review-graph &>/dev/null; then
  pipx install code-review-graph
  ok "code-review-graph installed"
else
  ok "code-review-graph already installed"
fi
mkdir -p "$HOME/.claude/code-review-graph"
ln -sfn "$REPO/claude/code-review-graph/languages.toml" "$HOME/.claude/code-review-graph/languages.toml"
ok "Global languages.toml (markdown) linked into ~/.claude/code-review-graph/"
bash "$REPO/code-review-graph/apply-patches.sh"
ok "code-review-graph patches applied (.vscode visibility, global languages.toml fallback, .vscode-scoped config path)"
warn "Reapply patches after every 'pipx upgrade code-review-graph' — run: $REPO/code-review-graph/apply-patches.sh"
warn "Build new projects with: code-review-graph build --data-dir .vscode/code-review-graph"

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

# ─── Claude Code plugins ──────────────────────────────────────────────────────
step "Claude Code plugins"
if command -v claude &>/dev/null; then
  for marketplace in JuliusBrussee/caveman DietrichGebert/ponytail mksglu/context-mode alexgreensh/token-optimizer; do
    claude plugin marketplace add "$marketplace" 2>/dev/null || true
  done
  for plugin in caveman@caveman ponytail@ponytail context-mode@context-mode \
    token-optimizer@alexgreensh-token-optimizer coderabbit@claude-plugins-official; do
    claude plugin install "$plugin" 2>/dev/null || true
  done
  ok "Plugins installed: caveman, ponytail, context-mode, token-optimizer, coderabbit"
else
  warn "Claude Code not found — install it first, then run plugins setup"
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

# Link dev-setup local skills
for skill_dir in "$REPO/skills/"/*/; do
  skill_name="$(basename "$skill_dir")"
  if [ -f "$skill_dir/SKILL.md" ]; then
    ln -sfn "$skill_dir" "$HOME/.claude/skills/${skill_name}"
    ok "local skill '${skill_name}' linked"
  fi
done

# ─── Third-party Claude skills ────────────────────────────────────────────────
step "Third-party Claude skills (humanlayer/skills)"
HUMANLAYER_DIR="$HOME/Projects/Github/humanlayer-skills"
if [ ! -d "$HUMANLAYER_DIR" ]; then
  mkdir -p "$HOME/Projects/Github"
  git clone https://github.com/humanlayer/skills "$HUMANLAYER_DIR"
fi
for skill in improve-claude-md show-me; do
  ln -sfn "$HUMANLAYER_DIR/plugins/$skill/skills/$skill" "$HOME/.claude/skills/$skill"
done
ok "humanlayer skills linked: improve-claude-md, show-me"

# ─── MCP servers (user scope, stored in ~/.claude.json) ───────────────────────
step "MCP servers"
if command -v claude &>/dev/null; then
  /opt/homebrew/bin/npm install -g agent-file-stash 2>/dev/null || true
  claude mcp remove filestash -s user >/dev/null 2>&1 || true
  claude mcp add --scope user filestash -e FILESTASH_DIR=.vscode/file-stash -- /opt/homebrew/bin/agent-file-stash serve
  ok "filestash MCP registered"

  claude mcp remove code-review-graph -s user >/dev/null 2>&1 || true
  claude mcp add --scope user code-review-graph -- "$HOME/.local/bin/code-review-graph" serve
  ok "code-review-graph MCP registered"

  if [ -n "${CONTEXT7_API_KEY:-}" ]; then
    claude mcp remove context7 -s user >/dev/null 2>&1 || true
    claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp --header "Authorization: Bearer $CONTEXT7_API_KEY"
    ok "context7 MCP registered"
  else
    warn "CONTEXT7_API_KEY not set — export it (key from context7.com/dashboard) and re-run to register context7"
  fi
else
  warn "Claude Code not found — install it first, then re-run to register MCP servers"
fi

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
