---
name: Prefer Write over multiple Edits for scattered changes
description: When a file needs many scattered replacements, use Write (read once, rewrite once) instead of many Edit calls
type: feedback
---

For files with many scattered replacements (3+), use `Write` to rewrite the full file in one call instead of multiple `Edit` calls.

**Why:** Each `Edit` is a separate round-trip tool call. A file with 10 replacements costs 12+ calls (cachebro read + built-in Read + 10 Edits). With `Write` it's 3 calls total (cachebro read + built-in Read + one Write). User flagged doing 10+ Edit calls on a single README as wasteful.

**How to apply:**
- 1-2 targeted, precise changes → `Edit`
- Many scattered replacements across the file → read once with cachebro, built-in Read once, then `Write` the complete new content
- Same string repeated → `Edit` with `replace_all: true`