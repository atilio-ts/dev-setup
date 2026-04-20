---
name: Use file-stash for file reads
description: Always use file-stash MCP read_file tool instead of the built-in Read tool
type: feedback
---

Always use file-stash's `read_file` (or `read_files`) MCP tool instead of the built-in Read tool when reading files for exploration.

**Why:** file-stash caches file contents by hash. On subsequent reads it returns cached content instead of re-reading from disk, saving significant tokens across sessions.

**How to apply:** Every time you need to read a file for exploration, reach for the file-stash `read_file` tool first. For files you will edit, use file-stash to understand first, then call the built-in Read tool immediately before editing (the Edit tool requires a prior built-in Read).
