#!/usr/bin/env bash

# Returns the command text that actually executes: heredoc bodies and quoted strings are removed
# so words inside commit messages, echo text or file contents are not mistaken for commands.
# When the command runs another interpreter or remote shell, the raw text is kept.

RAW_TRIGGER='(^|[^[:alnum:]_])((ba|z)?sh[[:space:]]+-c|eval|xargs|ssh|docker[[:space:]]+(exec|run)|kubectl[[:space:]]+exec|psql|mysql|mariadb|sqlite3|sqlcmd|mongosh|duckdb)([^[:alnum:]_]|$)'

strip_quoted() {
  local raw="$1"
  if printf '%s' "$raw" | grep -qE "$RAW_TRIGGER"; then
    printf '%s' "$raw"
    return
  fi
  printf '%s' "$raw" | perl -0777 -pe '
    s/<<-?\s*([\x27"]?)(\w+)\1([^\n]*)\n.*?\n[ \t]*\2[ \t]*(?:\n|\z)/$3\n/gs;
    s/"(?:[^"\\]|\\.)*"/""/gs;
    s/\x27[^\x27]*\x27/\x27\x27/gs;
  '
}
