#!/usr/bin/env bash
# Rewrites the single-line `description:` of skills listed here; idempotent, rerun after installing or updating skills.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOTS=("$HOME/.claude/skills" "$HOME/.agents/skills")

for patch in "$DIR"/*.description; do
  name="$(basename "$patch" .description)"
  target=""
  for root in "${ROOTS[@]}"; do
    [ -f "$root/$name/SKILL.md" ] && { target="$(cd "$root/$name" && pwd -P)/SKILL.md"; break; }
  done
  if [ -z "$target" ]; then echo "skip   $name (not installed)"; continue; fi

  python3 - "$target" "$patch" <<'PY'
import json, re, sys
path, patch = sys.argv[1:]
new = "description: " + json.dumps(open(patch, encoding="utf-8").read().strip(), ensure_ascii=False)
text = open(path, encoding="utf-8").read()
m = re.match(r"(---\n)(.*?)(\n---\n)", text, re.S)
if not m:
    sys.exit("fail   %s (no frontmatter)" % path)
lines = m.group(2).split("\n")
idx = [i for i, l in enumerate(lines) if l.startswith("description:")]
if len(idx) != 1 or (idx[0] + 1 < len(lines) and lines[idx[0] + 1].startswith((" ", "\t"))):
    sys.exit("fail   %s (description missing or multi-line)" % path)
if lines[idx[0]] == new:
    print("ok     %s (already patched)" % path); sys.exit()
lines[idx[0]] = new
open(path, "w", encoding="utf-8").write(m.group(1) + "\n".join(lines) + text[m.end(2):])
print("patched %s" % path)
PY
done
