#!/usr/bin/env python3
"""Patch code-review-graph's load_custom_languages() with a global fallback.

Custom languages (languages.toml, for teaching the parser grammars it doesn't
ship built-in — including markdown) are hardcoded to
`<repo_root>/.code-review-graph/languages.toml`. There is no user-level
config path, so every repo needs its own copy of the same file just to get
markdown parsing for .vscode/ docs.

This patches load_custom_languages() in the installed package so that, when
a repo has no local languages.toml, it falls back to
`~/.claude/code-review-graph/languages.toml` instead of returning nothing.
A repo-local file still always wins if present — this is a fallback, not a
merge. Combined with patch_vscode_docs.py (which makes .vscode/ visible to
the file collector regardless of git tracking), this makes markdown docs
under .vscode/ get indexed in every repo with zero per-repo setup.

Must be reapplied after every `pipx upgrade code-review-graph` / reinstall,
since pipx overwrites site-packages from the fresh wheel each time. Run
apply-patches.sh in this directory instead of calling this script directly.

Idempotent: safe to run multiple times, and safe to run against an
already-patched or a not-yet-patched custom_languages.py.
"""
import sys
from pathlib import Path

MARKER = "# Global fallback: ~/.claude/code-review-graph/languages.toml"

ANCHOR = '''    config_path = Path(repo_root) / CONFIG_RELATIVE_PATH
    try:
        stat = config_path.stat()
    except OSError:
        return {}  # No config file — the common case; not worth a log line.'''

PATCHED = '''    config_path = Path(repo_root) / CONFIG_RELATIVE_PATH
    try:
        stat = config_path.stat()
    except OSError:
        # Global fallback: ~/.claude/code-review-graph/languages.toml
        # No repo-local config — fall back to the global default before
        # giving up. A repo-local file always wins when present (this is a
        # fallback, not a merge).
        config_path = Path.home() / ".claude" / "code-review-graph" / "languages.toml"
        try:
            stat = config_path.stat()
        except OSError:
            return {}  # No config file at all — not worth a log line.'''


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: patch_global_languages.py <path/to/custom_languages.py>", file=sys.stderr)
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
            f"anchor block not found in {target} — code-review-graph's "
            "internals have likely changed upstream; this patch needs updating "
            "(diff the new load_custom_languages() against ANCHOR/PATCHED above)",
            file=sys.stderr,
        )
        return 1

    target.write_text(text.replace(ANCHOR, PATCHED, 1), encoding="utf-8")
    print(f"patched: {target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())