---
name: Use graphify to navigate codebases
description: Use graphify MCP tools when available to find and traverse files in a project
type: feedback
---

When graphify is available and `graphify-out/graph.json` exists in the project, use graphify MCP tools (mcp__graphify__*) to navigate and find files instead of doing blind searches with Glob or Grep.

**Why:** Graphify provides a pre-built knowledge graph of the codebase, making file and symbol lookup much faster and more accurate than raw file searches.

**How to apply:** Before searching for files or symbols with Glob/Grep, check if graphify is available. Use mcp__graphify__query_graph, mcp__graphify__get_node, mcp__graphify__get_neighbors, etc. to traverse the codebase. Only fall back to Glob/Grep if graphify is unavailable or the graph doesn't exist.