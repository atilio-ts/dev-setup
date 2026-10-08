#!/usr/bin/env bash
# Scopes stash reads per subagent by adding the agent id to read_file and read_files calls.
# The hook JSON arrives on stdin; the command prints nothing for the main agent.

exec /opt/homebrew/bin/agent-file-stash hook subagent-scope
