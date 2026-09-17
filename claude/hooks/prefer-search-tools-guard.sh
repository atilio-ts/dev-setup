#!/usr/bin/env bash
# Hard-blocks unbounded find/grep in Bash, pushing toward fd/rg (both already
# pre-approved in permissions.allow). Does NOT touch test/build commands or
# scoped find/grep usage -- only root-wide find and any bare grep invocation.

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

# Strip "--grep" (mocha/jest/etc test-filter flag) before checking for a bare grep command,
# so test runner flags don't get misflagged as grep invocations.
cmd_for_grep_check=$(echo "$cmd" | sed -E 's/--grep([^a-zA-Z0-9_]|$)/\1/g')

if echo "$cmd_for_grep_check" | grep -qE '\bgrep\b'; then
  echo "Bloqueado: usa rg (ripgrep) en vez de grep -- mismo resultado, mejor rendimiento, respeta .gitignore. Comando: $cmd" >&2
  exit 2
fi

if echo "$cmd" | grep -qE '\bfind[[:space:]]+/([[:space:]]|$)' && ! echo "$cmd" | grep -qE '\-maxdepth\b'; then
  echo "Bloqueado: find / sin acotar puede generar output enorme. Usa fd (respeta .gitignore, ya preaprobado) o agrega -maxdepth. Comando: $cmd" >&2
  exit 2
fi

exit 0
