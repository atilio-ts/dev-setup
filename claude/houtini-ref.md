### How to use

**`mcp__houtini-lm__code_task`** — best for code analysis:
- `code`: full source, never truncate
- `task`: "Find bugs", "Write tests for this", "Explain this function"
- `language`: "typescript", "python", etc.

**`mcp__houtini-lm__chat`** — general workhorse:
- Be explicit about output format
- Set `temperature: 0.1` for code, `0.3` for analysis, `0.7` for creative
- Use `json_schema` to force structured output

**`mcp__houtini-lm__custom_prompt`** — best for code review and analysis with context:
- `system`: short persona ("Senior TypeScript developer")
- `context`: full data to analyse
- `instruction`: what to produce, under 50 words

### Limits & concurrency

- **Max context per request: 4096 tokens** — never send more; truncate or summarise input if needed
- **One request at a time** — never fire parallel houtini calls; the local machine cannot handle concurrent LLM inference. Queue them sequentially
- Send complete code within the 4096-token budget — never truncate with `...`
- State output format explicitly ("Return a JSON array", "Bullet points only")
- Include imports and types as surrounding context for code generation
- Use `mcp__houtini-lm__discover` if unsure the server is available
- Use `mcp__houtini-lm__list_models` to see what models are loaded and their capabilities
