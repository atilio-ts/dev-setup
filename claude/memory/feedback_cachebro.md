---
name: Use cachebro for file reads
description: Always use cachebro MCP read_file tool instead of the built-in Read tool
type: feedback
---

Always use cachebro's `read_file` (or `read_files`) MCP tool instead of the built-in Read tool when reading files.

**Why:** Cachebro caches file contents by hash. On subsequent reads it returns "unchanged" (one line) or a compact diff instead of the full file, saving significant tokens.

**How to apply:** Every time you need to read a file, reach for the cachebro `read_file` tool first. Only fall back to the built-in Read tool if cachebro is unavailable.
