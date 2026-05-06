---
name: Use houtini without asking permission
description: Never ask the user for permission before using houtini MCP tools
type: feedback
---

Use houtini tools (mcp__houtini-lm__*) freely without asking the user for permission first.

**Why:** User explicitly said not to ask for permission — just use it. User also flagged that falling back to Claude immediately when houtini returns empty is wrong — wastes tokens that should stay offloaded. User also flagged that failing to use houtini for analysis and evaluation tasks (e.g. reviewing an improvements list, assessing code before editing) is a missed opportunity every time.

**How to apply:** Any time houtini would be useful (code review, analysis, evaluating a list of options, test stubs, commit messages, quick factual queries, explaining a file before editing it), invoke it directly without prompting. This especially includes tasks that feel like "thinking work" — if you are about to reason through something bounded and self-contained, offload it. Context window is **9,216 tokens** — never send full multi-file dumps in a single call; split by file or topic. If a call returns empty or TRUNCATED output, retry in this order before falling back to Claude:
1. `code_task_files` returns empty → retry with `custom_prompt` (source as `context`)
2. `custom_prompt` returns empty → retry with `chat` (source inlined)
3. Only use Claude after both retries fail

---

Before every houtini call, evaluate whether the delegation actually saves tokens net of overhead. The round-trip cost (tool call params + result + interpretation) can exceed the cost of doing the task inline.

**Why:** User flagged that small or already-in-context tasks cost more via houtini than doing them directly — the preparation and result handling eat more tokens than the task itself.

**How to apply:**
- Worth delegating: code > ~100 lines not yet in context, mechanical/repetitive tasks (commit drafts, test stubs, fixture data), tasks that would require extended reasoning
- Not worth delegating: code already in context, tasks with < 3-line output, small files where prep cost exceeds analysis cost