#!/usr/bin/env bash
# Warns if a just-edited file is not UTF-8 encoded.
# Triggered as a PostToolUse hook on Edit and Write.

FILE="${CLAUDE_FILE_PATH:-}"

[[ -z "$FILE" ]] && exit 0
[[ ! -f "$FILE" ]] && exit 0

ENCODING=$(file -bi "$FILE" 2>/dev/null)

if echo "$ENCODING" | grep -qi "charset=utf-8\|charset=us-ascii"; then
  exit 0
fi

echo "WARNING: $FILE encoding may not be UTF-8 — detected: $ENCODING"
echo "Re-read the file and verify accent characters (á é í ó ú ñ) are intact."