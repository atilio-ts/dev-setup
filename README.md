# dev-setup

Personal developer environment configuration files and setup documentation.

See [DEV_SETUP.md](DEV_SETUP.md) for the full setup guide.

## Structure

```
.
├── DEV_SETUP.md              # Full setup guide — start here
├── shell/
│   ├── zshrc                 # ~/.zshrc
│   └── p10k.zsh              # ~/.p10k.zsh (Powerlevel10k theme config)
├── git/
│   ├── gitconfig             # ~/.gitconfig
│   ├── gitignore_global      # ~/.gitignore_global
│   └── Brewfile              # ~/Brewfile — restore with: brew bundle install
├── nvim/
│   ├── init.lua              # ~/.config/nvim/init.lua
│   ├── lazy-lock.json        # ~/.config/nvim/lazy-lock.json
│   └── lua/config/           # ~/.config/nvim/lua/config/
├── claude/
│   ├── CLAUDE.md             # ~/.claude/CLAUDE.md
│   ├── settings.json         # ~/.claude/settings.json
│   ├── statusline-command.sh # ~/.claude/statusline-command.sh
│   └── hooks/
│       ├── pre-bash.sh       # ~/.claude/hooks/pre-bash.sh
│       └── pre-websearch.sh  # ~/.claude/hooks/pre-websearch.sh
├── atuin/
│   └── config.toml           # ~/.config/atuin/config.toml
└── spicetify/
    └── config-xpui.ini       # ~/.config/spicetify/config-xpui.ini
```

## Restoring on a new machine

Follow DEV_SETUP.md step by step. The quick version:

```bash
# 1. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew tap lucassabrero/tap && brew tap sheeki03/tap
brew bundle install --file=git/Brewfile

# 2. Symlink or copy configs to their destinations
cp shell/zshrc ~/.zshrc
cp shell/p10k.zsh ~/.p10k.zsh
cp git/gitconfig ~/.gitconfig
cp git/gitignore_global ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
mkdir -p ~/.config/nvim/lua/config && cp -r nvim/* ~/.config/nvim/
mkdir -p ~/.config/atuin && cp atuin/config.toml ~/.config/atuin/
mkdir -p ~/.config/spicetify && cp spicetify/config-xpui.ini ~/.config/spicetify/
mkdir -p ~/.claude/hooks
cp claude/CLAUDE.md ~/.claude/
cp claude/settings.json ~/.claude/
cp claude/statusline-command.sh ~/.claude/
cp claude/hooks/* ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
chmod +x ~/.claude/statusline-command.sh
```
