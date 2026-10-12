#!/usr/bin/env bash

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')

source "$(dirname "$0")/strip-quoted.sh"
check=$(strip_quoted "$cmd" | sed -E 's/(&&|\|\||;)/\n/g')

destructive_patterns=(
  # git — force / rewrite history
  "git reset --hard"
  "git push --force"
  "git push -f "
  "git push -f$"
  "git push.*--force-with-lease"
  "git rebase( .*)? (-i|--interactive)( |$)"
  "git rebase.*--onto"
  "git filter-branch"
  "git filter-repo"
  "git commit.*--amend"
  "git reflog.*delete"
  "git reflog.*expire"

  # git — discard working tree / index
  "git clean -f"
  "git clean -fd"
  "git clean -fx"
  "git checkout \."
  "git restore \."
  "git checkout( .*)? -- "

  # git — delete branches / tags / remotes
  "git branch -D"
  "git branch -d"
  "git tag -d"
  "git push.*:refs/tags/"
  "git push.*--delete"
  "git push.*--prune"
  "git remote.*remove"
  "git remote.*rm"

  # git — config tampering
  "git config.*--global"
  "git config.*--system"

  # filesystem — recursive delete
  "rm -rf /"
  "rm -rf \*"
  "rm -rf \$"
  "rm -rf ~"
  "rm -rf \."
  "rm -fr "
  "rmdir.*--ignore-fail"

  # filesystem — dangerous overwrites
  "dd if="
  "dd of="
  "> /etc/"
  "> /usr/"
  "> /bin/"
  "> /sbin/"

  # filesystem — permission escalation
  "chmod -R 777"
  "chmod 777"
  "chown -R root"
  "chown root"
  "sudo chmod"
  "sudo chown"

  # database — destructive DDL / DML
  "DROP TABLE"
  "DROP DATABASE"
  "DROP SCHEMA"
  "TRUNCATE TABLE"
  "TRUNCATE "
  "DELETE FROM.*WHERE.*1=1"
  "DELETE FROM.*WHERE.*true"

  # process — kill system processes
  "kill -9"
  "kill -KILL"
  "pkill"
  "killall"

  # package publishing — accidental releases
  "npm publish"
  "pip publish"
  "twine upload"
  "cargo publish"
  "gem push"

  # privilege escalation
  "sudo su"
  "sudo -i"
  "sudo bash"
  "sudo sh"
  "sudo rm"

  # filesystem — secure delete / format
  "shred "
  "wipe "
  "mkfs\."
  "mkfs "
  "truncate -s"

  # arbitrary code from network
  "curl.*\| *sh"
  "curl.*\| *bash"
  "wget.*\| *sh"
  "wget.*\| *bash"
  "curl.*\| *python"
  "curl.*\| *node"

  # database CLIs with destructive statements
  "psql.*DROP"
  "psql.*TRUNCATE"
  "mysql.*DROP"
  "mysql.*TRUNCATE"
  "sqlite3.*DROP"
  "sqlite3.*DELETE FROM"
)

for pattern in "${destructive_patterns[@]}"; do
  if echo "$check" | grep -qE "$pattern"; then
    echo "Destructive command blocked: $cmd" >&2
    exit 2
  fi
done

sensitive=$(printf '%s' "$cmd" | perl -0777 -ne '
  s/<<-?\s*(["\x27]?)(\w+)\1([^\n]*)\n.*?\n[ \t]*\2[ \t]*(?:\n|\z)/$3\n/gs;
  s/(["\x27])((?:(?!\1).)*)\1/$2 =~ m{[\\|()\[\]{}^+?]} ? q("") : $&/ge;
  for my $seg (split /&&|\|\||;|\||\n/) {
    $seg =~ s/^\s+//;
    my @w = split /\s+/, $seg;
    shift @w while @w && $w[0] =~ /^(sudo|rtk|proxy)$/;
    next unless @w && $w[0] =~ /^(cat|less|more|head|tail|bat|nl|tac|xxd|od|strings|base64|cp|mv|scp|rg|awk|sed|source|\.|read)$/;
    for my $a (@w[1..$#w]) {
      (my $p = $a) =~ s/^["\x27]|["\x27]$//g;
      $p =~ s/^~/$ENV{HOME}/;
      $p =~ s/:[^\/:]*$//;
      if ($p =~ m{\.env(\.(?!example$)[^/]*)?$|\.pem$|\.key$|(^|/)\.ssh(/|$)|(^|/)\.aws(/|$)}) { print "1"; exit }
    }
  }')
if [ -n "$sensitive" ]; then
  echo "Blocked: reading a sensitive file via bash: $cmd" >&2
  exit 2
fi

exit 0