#!/usr/bin/env python3
"""Patch code-review-graph's collect_all_files() so doc-only dirs are always indexed.

code-review-graph prefers `git ls-files` for file discovery whenever the repo
has any tracked files at all, falling back to a full filesystem walk only
when there are zero tracked files. `.vscode/` (per-project CLAUDE.md docs) and
`temporary/` (scratch analysis notes, bug writeups, migration plans) are both
gitignored in most of our projects but genuinely useful content — and both
are invisible to the graph by default. No `.code-review-graph/languages.toml`
custom-language config can fix this on its own, because the files are never
even considered as candidates in the first place.

This patches collect_all_files() in the installed package to always walk
EXTRA_DOC_DIRS and merge their files into the candidate list, regardless of
git tracking status. It must be reapplied after every `pipx upgrade
code-review-graph` / reinstall, since pipx overwrites site-packages from the
fresh wheel each time. Run apply-patches.sh in this directory instead of
calling this script directly.

Idempotent: safe to run multiple times, safe against an unpatched
incremental.py, and safe against one carrying the older single-directory
(.vscode/ only) version of this patch — it upgrades in place.
"""
import sys
from pathlib import Path

MARKER = "# Extra doc directories that commonly live outside git tracking"
OLD_MARKER = "# .vscode/ commonly holds project documentation"

ORIGINAL_ANCHOR = '''    # Prefer git ls-files for tracked files
    tracked = get_all_tracked_files(repo_root, recurse_submodules)
    if tracked:
        candidates = tracked
    else:
        # Fallback: walk directory
        candidates = [str(p.relative_to(repo_root)) for p in repo_root.rglob("*") if p.is_file()]

    for rel_path in candidates:'''

OLD_PATCHED = '''    # Prefer git ls-files for tracked files
    tracked = get_all_tracked_files(repo_root, recurse_submodules)
    if tracked:
        candidates = tracked
    else:
        # Fallback: walk directory
        candidates = [str(p.relative_to(repo_root)) for p in repo_root.rglob("*") if p.is_file()]

    # .vscode/ commonly holds project documentation (CLAUDE.md and friends)
    # that teams deliberately keep out of git via .gitignore. git ls-files
    # would otherwise hide it from the graph entirely, so it is always
    # walked and merged in here regardless of tracking status.
    vscode_dir = repo_root / ".vscode"
    if vscode_dir.is_dir():
        tracked_set = set(candidates)
        for p in vscode_dir.rglob("*"):
            if p.is_file():
                rel = str(p.relative_to(repo_root))
                if rel not in tracked_set:
                    candidates.append(rel)
                    tracked_set.add(rel)

    for rel_path in candidates:'''

NEW_PATCHED = '''    # Prefer git ls-files for tracked files
    tracked = get_all_tracked_files(repo_root, recurse_submodules)
    if tracked:
        candidates = tracked
    else:
        # Fallback: walk directory
        candidates = [str(p.relative_to(repo_root)) for p in repo_root.rglob("*") if p.is_file()]

    # Extra doc directories that commonly live outside git tracking (.vscode/
    # project docs, temporary/ scratch analysis notes) but hold genuinely
    # useful content. git ls-files would otherwise hide them from the graph
    # entirely, so they are always walked and merged in here regardless of
    # tracking status.
    EXTRA_DOC_DIRS = (".vscode", "temporary")
    tracked_set = set(candidates)
    for extra_dir_name in EXTRA_DOC_DIRS:
        extra_dir = repo_root / extra_dir_name
        if extra_dir.is_dir():
            for p in extra_dir.rglob("*"):
                if p.is_file():
                    rel = str(p.relative_to(repo_root))
                    if rel not in tracked_set:
                        candidates.append(rel)
                        tracked_set.add(rel)

    for rel_path in candidates:'''


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: patch_vscode_docs.py <path/to/incremental.py>", file=sys.stderr)
        return 1

    target = Path(sys.argv[1])
    if not target.is_file():
        print(f"not found: {target}", file=sys.stderr)
        return 1

    text = target.read_text(encoding="utf-8")

    if MARKER in text:
        print(f"already patched: {target}")
        return 0

    if OLD_MARKER in text:
        if OLD_PATCHED not in text:
            print(
                f"old marker found but old patched block doesn't match in {target} — "
                "manual reconciliation needed",
                file=sys.stderr,
            )
            return 1
        target.write_text(text.replace(OLD_PATCHED, NEW_PATCHED, 1), encoding="utf-8")
        print(f"upgraded (.vscode-only -> .vscode+temporary): {target}")
        return 0

    if ORIGINAL_ANCHOR not in text:
        print(
            f"anchor block not found in {target} — code-review-graph's "
            "internals have likely changed upstream; this patch needs updating "
            "(diff the new collect_all_files() against ORIGINAL_ANCHOR/NEW_PATCHED above)",
            file=sys.stderr,
        )
        return 1

    target.write_text(text.replace(ORIGINAL_ANCHOR, NEW_PATCHED, 1), encoding="utf-8")
    print(f"patched: {target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())