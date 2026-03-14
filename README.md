# dev-setup

Personal developer environment configuration files and setup documentation.

See [DEV_SETUP.md](DEV_SETUP.md) for the full setup guide.

## Structure

```
.
├── DEV_SETUP.md              # Full setup guide — start here
├── setup.sh                  # Automated restore script
├── shell/
│   ├── zshrc                 # ~/.zshrc
│   └── p10k.zsh              # ~/.p10k.zsh (Powerlevel10k theme config)
├── git/
│   ├── gitconfig             # ~/.gitconfig
│   ├── gitignore_global      # ~/.gitignore_global
│   └── Brewfile              # restore with: brew bundle install --file=git/Brewfile
├── nvim/
│   ├── init.lua              # ~/.config/nvim/init.lua
│   ├── lazy-lock.json        # ~/.config/nvim/lazy-lock.json
│   └── lua/config/           # ~/.config/nvim/lua/config/
├── claude/
│   ├── CLAUDE.md             # ~/.claude/CLAUDE.md
│   ├── settings.json         # ~/.claude/settings.json
│   ├── statusline-command.sh # ~/.claude/statusline-command.sh
│   ├── hooks/
│   │   ├── pre-bash.sh       # ~/.claude/hooks/pre-bash.sh
│   │   └── pre-websearch.sh  # ~/.claude/hooks/pre-websearch.sh
│   └── memory/
│       ├── MEMORY.md         # User profile memory index
│       └── user_profile.md   # Who Atilio is — seeded into Claude on new machines
├── vscode/
│   └── settings.json         # ~/Library/Application Support/Code/User/settings.json
├── gh/
│   └── config.yml            # ~/.config/gh/config.yml
├── atuin/
│   └── config.toml           # ~/.config/atuin/config.toml
└── spicetify/
    └── config-xpui.ini       # ~/.config/spicetify/config-xpui.ini
```

## Restoring on a new machine

```bash
git clone git@github.com:youruser/dev-setup.git
cd dev-setup
bash setup.sh
```

The script handles: Homebrew, all packages, Oh My Zsh, shell config, git, Neovim, atuin, gh, VS Code settings, Claude Code (config + hooks + memory), spicetify, navi cheatsheets, and macOS Dock settings.

See DEV_SETUP.md for anything that requires manual steps (Docker, JetBrains, mise, Java JDKs, Claude skills).
