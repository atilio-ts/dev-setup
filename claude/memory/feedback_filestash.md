---
name: Use file-stash for file reads
description: Always use file-stash MCP read_file tool instead of the built-in Read tool
type: feedback
---

Always use file-stash's `read_file` (or `read_files`) MCP tool instead of the built-in Read tool when reading files.

**Why:** file-stash caches file contents by hash. On subsequent reads it returns "unchanged" (one line) or a compact diff instead of the full file, saving significant tokens.

**How to apply:** Every time you need to read a file, reach for the file-stash `read_file` tool first. Only fall back to the built-in Read tool if file-stash is unavailable.