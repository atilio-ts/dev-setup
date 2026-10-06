#!/usr/bin/env bash
# Self-check for pre-bash.sh and prefer-search-tools-guard.sh. Run: bash ~/.claude/hooks/test-hooks.sh

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

[ "$fail" -eq 0 ] && echo "todas las pruebas pasaron"
exit "$fail"
