#!/usr/bin/env python3
"""Patch code-review-graph's CONFIG_RELATIVE_PATH to live under .vscode/.

languages.toml's location is hardcoded to <repo_root>/.code-review-graph/,
independent of --data-dir (which only relocates the graph database via the
registry). This patches the constant itself so the repo-local override also
lives under .vscode/code-review-graph/ — the same directory --data-dir
points the database at — leaving nothing for code-review-graph to create at
the repo root at all.

Must be reapplied after every `pipx upgrade code-review-graph` / reinstall,
since pipx overwrites site-packages from the fresh wheel each time. Run
apply-patches.sh in this directory instead of calling this script directly.

Idempotent: safe to run multiple times, and safe to run against an
already-patched or a not-yet-patched custom_languages.py.
"""
import sys
from pathlib import Path

MARKER = 'CONFIG_RELATIVE_PATH = Path(".vscode") / "code-review-graph" / "languages.toml"'

ANCHOR = 'CONFIG_RELATIVE_PATH = Path(".code-review-graph") / "languages.toml"'

PATCHED = MARKER


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: patch_config_path.py <path/to/custom_languages.py>", file=sys.stderr)
        return 1

    target = Path(sys.argv[1])
    if not target.is_file():
        print(f"not found: {target}", file=sys.stderr)
        return 1

    text = target.read_text(encoding="utf-8")

    if MARKER in text:
        print(f"already patched: {target}")
        return 0

    if ANCHOR not in text:
        print(
            f"anchor not found in {target} — code-review-graph's internals "
            "have likely changed upstream; this patch needs updating",
            file=sys.stderr,
        )
        return 1

    target.write_text(text.replace(ANCHOR, PATCHED, 1), encoding="utf-8")
    print(f"patched: {target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())