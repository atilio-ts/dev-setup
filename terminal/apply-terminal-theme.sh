#!/usr/bin/env bash
# Apply the dev-setup dark theme + MesloLGS NF font to Terminal.app's "Basic" profile.
# Requires font-meslo-for-powerlevel10k (brew cask) already installed.
#
# Known limitation: Terminal.app's AppleScript API only exposes background,
# normal text, bold text and cursor color — not the 16 ANSI colors. So `ls`,
# `git`, and p10k colored output will not match iTerm2 exactly. Fixing that
# requires importing a .terminal file or writing NSKeyedArchiver-encoded
# NSColor blobs directly into the plist, which isn't worth the complexity
# for a secondary terminal — iTerm2 is the primary one (see iterm2/).
set -e

osascript <<'EOF'
tell application "Terminal"
	tell settings set "Basic"
		set font to "MesloLGS-NF-Regular"
		set font size to 15
		set background color to {5288, 6496, 7930}
		set normal text color to {56491, 56491, 56491}
		set bold text color to {56491, 56491, 56491}
		set cursor color to {65535, 65535, 65535}
	end tell
end tell
EOF

defaults write com.apple.Terminal "Default Window Settings" "Basic"
defaults write com.apple.Terminal "Startup Window Settings" "Basic"

echo "Terminal.app 'Basic' profile updated (font, background, text, cursor) and set as default."
