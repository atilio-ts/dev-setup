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
│   ├── gitconfig             # ~/.gitconfig (placeholders for name/email)
│   ├── gitconfig-personal    # ~/.gitconfig-personal (identity for personal folders)
│   ├── gitconfig-work        # seeds ~/.gitconfig-local (untracked, machine-specific identity)
│   ├── gitignore_global      # ~/.gitignore_global
│   └── Brewfile              # restore with: brew bundle install --file=git/Brewfile
├── nvim/
│   ├── init.lua              # ~/.config/nvim/init.lua
│   ├── lazy-lock.json        # ~/.config/nvim/lazy-lock.json
│   └── lua/config/           # ~/.config/nvim/lua/config/
├── .env.example              # API keys the setup and skills expect (CONTEXT7_API_KEY, CLOCKIFY_API_KEY)
├── gradle/gradle.properties  # ~/.gradle/gradle.properties
├── nano/                     # ~/.nanorc and ~/.nano/typescript.nanorc
├── vim/vimrc                 # ~/.vimrc
├── code-review-graph/        # patches applied to the pipx install (apply-patches.sh)
├── claude/                   # symlinked into ~/.claude/ by setup.sh
│   ├── CLAUDE.md             # ~/.claude/CLAUDE.md
│   ├── RTK.md                # ~/.claude/RTK.md (Rust Token Killer docs)
│   ├── settings.json         # copied to ~/.claude/settings.json (not linked)
│   ├── statusline-command.sh # ~/.claude/statusline-command.sh
│   ├── commands/             # ~/.claude/commands/ (/plan, /skill-create)
│   ├── rules/                # ~/.claude/rules/ (tools, coding-style, context7)
│   ├── hooks/                # ~/.claude/hooks/ (guards, helpers, test-hooks.sh)
│   ├── code-review-graph/languages.toml # registers markdown for code-review-graph
│   ├── skills/               # each skill symlinked into ~/.claude/skills/ (llm-council is skipped)
│   └── skill-patches/        # description overrides applied by apply.sh
├── opencode/                 # ~/.config/opencode/ (config, caveman and postman plugins, skills, agents)
├── omp/                      # ~/.omp/agent/ (config.yml, mcp.json, AGENTS.md, extensions, plugins.txt)
├── firefox/user.js           # Betterfox user.js + overrides, copied into the Dev Edition profile
├── tmux/tmux.conf            # ~/.tmux.conf
├── iterm2/dynamic-profile.json # iTerm2 Dynamic Profiles
├── terminal/apply-terminal-theme.sh # themes the Terminal.app Basic profile
├── vscode/
│   └── settings.json         # ~/Library/Application Support/Code/User/settings.json
├── gh/
│   └── config.yml            # ~/.config/gh/config.yml
├── atuin/
│   └── config.toml           # ~/.config/atuin/config.toml
├── launchagents/
│   ├── com.atilio.brew-upgrade.plist  # ~/Library/LaunchAgents/ (daily brew upgrade)
│   └── homebrew.asimov.plist          # ~/Library/LaunchAgents/ (exclude brew from Time Machine)
├── skills/
│   ├── install-dev-setup/    # Claude skill: interactive full dev environment installation guide
│   │   └── SKILL.md           # project-scoped — discovered from cwd, not symlinked
│   └── sync-configuration/   # Claude skill: sync live machine config → this repo
│       └── SKILL.md           # project-scoped — discovered from cwd, not symlinked
└── spicetify/
    └── config-xpui.ini       # ~/.config/spicetify/config-xpui.ini
```

## Restoring on a new machine

```bash
git clone git@github.com:youruser/dev-setup.git
cd dev-setup
bash setup.sh
```

The script handles: Homebrew and all packages, Oh My Zsh, shell config, git, project repos, Neovim, nano, vim, tmux, Gradle, Firefox, atuin, gh, VS Code settings, iTerm2 and Terminal.app themes, opencode, omp, Claude Code (config, hooks, rules, commands, plugins, skills, MCP servers), code-review-graph and its patches, spicetify, LaunchAgents (asimov, daily brew upgrade), navi cheatsheets, claude-code-stats, Postman CLI, SonarQube CLI, and macOS Dock settings.

See DEV_SETUP.md for anything that requires manual steps (Docker, JetBrains, Java JDKs, Claude skills).
