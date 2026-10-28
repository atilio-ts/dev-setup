#!/usr/bin/env bash
# PostToolUse for mcp__code-review-graph__*: records that the graph was consulted this session.
session_id=$(jq -r '.session_id // "default"')
touch "/tmp/claude-crg-used-${session_id}"
exit 0
