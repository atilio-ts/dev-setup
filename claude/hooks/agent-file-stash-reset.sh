#!/usr/bin/env bash
# Forgets what the stash delivered, so files come back in full after /clear or /compact.
# The hook JSON arrives on stdin and is forwarded to the command untouched.

exec /opt/homebrew/bin/agent-file-stash reset --from-hook
