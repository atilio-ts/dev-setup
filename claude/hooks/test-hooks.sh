#!/usr/bin/env bash
# Self-check for pre-bash.sh, prefer-search-tools-guard.sh, code-review-graph-guard.sh and context7-reminder.sh. Run: bash ~/.claude/hooks/test-hooks.sh

dir="$(cd "$(dirname "$0")" && pwd)"
fail=0

run() {
  local hook="$1" expect="$2" cmd="$3"
  local json code
  json=$(jq -n --arg c "$cmd" '{tool_input:{command:$c}}')
  echo "$json" | bash "$dir/$hook" >/dev/null 2>&1
  code=$?
  if { [ "$expect" = block ] && [ "$code" -ne 2 ]; } || { [ "$expect" = pass ] && [ "$code" -ne 0 ]; }; then
    echo "FAIL ($hook): expected $expect -> $cmd"
    fail=1
  fi
}

p=pre-bash.sh
run $p block 'git reset --hard HEAD~1'
run $p block 'git push --force origin main'
run $p block 'git rebase -i HEAD~3'
run $p block 'git checkout -- src/File.java'
run $p block 'rm -rf /tmp/x/*'
run $p block 'psql -c "DROP TABLE users"'
run $p block 'bash -c "git push -f origin main"'
run $p pass 'git checkout -b feature/fix--x'
run $p pass 'git rebase --continue'
run $p pass 'git commit -m "docs: mention git reset --hard and rm -rf in the guide"'
run $p pass $'cat > notes.md <<\'EOF\'\nnever run git push --force or rm -rf /\nEOF'
run $p pass 'echo "kill -9 is dangerous" > note.txt'
run $p pass 'git remote -v | head -1; git log -3 --format=%cs'
run $p pass 'git status && git commit -m ok && git log --amend-test 2>/dev/null'
run $p block 'cat .env'
run $p block 'cat ~/.ssh/id_rsa'
run $p block 'head -5 "$HOME/.aws/credentials" && cat key.pem'
run $p block 'cat "~/.aws/credentials"'
run $p pass 'cat .env.example'
run $p pass "rg -n '\\.env|\\.ssh' claude/hooks"
run $p pass 'git commit -m "fix .env loading"'
run $p pass $'cat > doc.md <<\'EOF\'\ncat .env\nEOF'

g=prefer-search-tools-guard.sh
run $g block 'grep -r foo src'
run $g block 'cat file | grep foo'
run $g block 'git log | xargs grep foo'
run $g block 'find / -name x'
run $g pass 'git log --grep=fix'
run $g pass 'rg foo src'
run $g pass 'find / -maxdepth 2 -name x'
run $g pass 'git commit -m "replace grep with rg in scripts"'
run $g pass $'cat > doc.md <<\'EOF\'\nuse grep or find / carefully\nEOF'
run $g pass 'echo "no uses grep"'

# code-review-graph-guard.sh: Bash search blocked until the graph was used (needs a repo with a graph)
repo="$(cd "$(mktemp -d)" && pwd -P)"; git -C "$repo" init -q && mkdir "$repo/.code-review-graph"
if true; then
  sid="test-$$"; rm -f "/tmp/claude-crg-used-$sid"
  crg() {
    local expect="$1" cmd="$2" code
    jq -n --arg c "$cmd" --arg cwd "$repo" --arg s "$sid" '{cwd:$cwd,tool_name:"Bash",session_id:$s,tool_input:{command:$c}}' | bash "$dir/code-review-graph-guard.sh" >/dev/null 2>&1
    code=$?
    if { [ "$expect" = block ] && [ "$code" -ne 2 ]; } || { [ "$expect" = pass ] && [ "$code" -ne 0 ]; }; then
      echo "FAIL (code-review-graph-guard.sh): expected $expect -> $cmd"; fail=1
    fi
  }
  crg block 'rg foo src'
  crg block 'fd Controller'
  crg pass 'git log | rg fix'
  crg pass 'rg foo ~/Projects/other-repo'
  crg pass 'rg foo /tmp/x'
  crg pass 'cd ~/.claude && rg foo'
  crg block "rg foo $repo/backend"
  crg pass 'git commit -m "use rg here"'
  echo "{\"session_id\":\"$sid\"}" | bash "$dir/code-review-graph-mark.sh"
  crg pass 'rg foo src'
  rm -f "/tmp/claude-crg-used-$sid"
fi
rm -rf "$repo"

# context7-reminder.sh
c7() {
  local expect="$1" prompt="$2" out
  out=$(jq -n --arg p "$prompt" '{prompt:$p}' | bash "$dir/context7-reminder.sh")
  if { [ "$expect" = hint ] && [ -z "$out" ]; } || { [ "$expect" = none ] && [ -n "$out" ]; }; then
    echo "FAIL (context7-reminder.sh): expected $expect -> $prompt"; fail=1
  fi
}
c7 hint 'how do I configure Flyway with Spring Boot?'
c7 hint 'upgrade tailwind to the latest version'
c7 none 'rename this variable'
c7 none '/doctor react'
c7 none 'esta todo bien con dev setup, cargaste los plugins y skills?'
c7 none 'arregla el bug de este controller de spring'
c7 hint 'como migro de jest a vitest?'
c7 hint 'cómo configuro keycloak con traefik'

[ "$fail" -eq 0 ] && echo "todas las pruebas pasaron"
exit "$fail"
