#!/usr/bin/env bash
# Hard-blocks the grep command and unbounded find / in Bash, pushing toward rg/fd
# (both already pre-approved in permissions.allow). Only the executed command is checked:
# text inside quotes or heredocs (commit messages, echo, file contents) is ignored.

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

source "$(dirname "$0")/strip-quoted.sh"
check=$(strip_quoted "$cmd")

COMMAND_POSITION='(^|[|;&(`]|\$\()[[:space:]]*(sudo[[:space:]]+|xargs[[:space:]]+)?'

if echo "$check" | grep -qE "${COMMAND_POSITION}(e|f)?grep([[:space:]]|$)"; then
  echo "Bloqueado: usa rg (ripgrep) en vez de grep -- mismo resultado, mejor rendimiento, respeta .gitignore. Comando: $cmd" >&2
  exit 2
fi

if echo "$check" | grep -qE "${COMMAND_POSITION}find[[:space:]]+/([[:space:]]|$)" && ! echo "$check" | grep -qE '\-maxdepth\b'; then
  echo "Bloqueado: find / sin acotar puede generar output enorme. Usa fd (respeta .gitignore, ya preaprobado) o agrega -maxdepth. Comando: $cmd" >&2
  exit 2
fi

exit 0
