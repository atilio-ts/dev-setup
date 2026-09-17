#!/usr/bin/env bash
# Reapply the code-review-graph patches to the globally pipx-installed package.
# Run this once after `pipx install code-review-graph`, and again after every
# `pipx upgrade code-review-graph` — pipx overwrites site-packages from the
# fresh wheel each time, silently dropping both patches.
#
# 1. patch_vscode_docs.py      — always walk .vscode/ regardless of git tracking
# 2. patch_global_languages.py — fall back to ~/.claude/code-review-graph/languages.toml
#                                 when a repo has no languages.toml of its own
# 3. patch_config_path.py      — repo-local languages.toml lives under
#                                 .vscode/code-review-graph/ instead of the repo root
#
# Together these make .vscode/*.md project docs get indexed as markdown in
# every repo, with zero per-repo setup, and nothing code-review-graph-related
# ever created outside .vscode/ (use --data-dir .vscode/code-review-graph on
# `build` to relocate the database the same way).
set -euo pipefail

VENV_PY="$HOME/.local/pipx/venvs/code-review-graph/bin/python3"
if [[ ! -x "$VENV_PY" ]]; then
  echo "code-review-graph pipx venv not found at $VENV_PY — install it first with:" >&2
  echo "  pipx install code-review-graph" >&2
  exit 1
fi

INCREMENTAL_PY=$("$VENV_PY" -c "import code_review_graph, os; print(os.path.join(os.path.dirname(code_review_graph.__file__), 'incremental.py'))")
CUSTOM_LANGUAGES_PY=$("$VENV_PY" -c "import code_review_graph, os; print(os.path.join(os.path.dirname(code_review_graph.__file__), 'custom_languages.py'))")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$SCRIPT_DIR/patch_vscode_docs.py" "$INCREMENTAL_PY"
python3 "$SCRIPT_DIR/patch_global_languages.py" "$CUSTOM_LANGUAGES_PY"
python3 "$SCRIPT_DIR/patch_config_path.py" "$CUSTOM_LANGUAGES_PY"