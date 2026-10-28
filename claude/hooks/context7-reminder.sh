#!/usr/bin/env bash
# UserPromptSubmit: when the prompt names a library/framework AND asks a how-to/config/migration/version question,
# remind to fetch current docs through Context7 before answering.

prompt=$(jq -r '.prompt // empty')
[ -z "$prompt" ] && exit 0
case "$prompt" in /*) exit 0 ;; esac

libs='react|next\.?js|vue|angular|svelte|vite|tailwind|prisma|drizzle|nest\.?js|django|flask|fastapi|spring( ?boot)?|hibernate|jpa|flyway|liquibase|gradle|maven|testcontainers|archunit|jacoco|spotless|nullaway|keycloak|traefik|postgres(ql)?|docker( compose)?|kubernetes|terraform|supabase|firebase|stripe|openapi|springdoc|swagger|typescript|node\.?js|deno|zod|tanstack|redux|jest|vitest|playwright|cypress|langchain|anthropic sdk|aws sdk'
intent='how|c[oó]mo|configur|instal|migra|upgrad|actualiz|version|versi[oó]n|deprecat|sintaxis|syntax|api|docs|documentaci|set ?up|usar|use|error|no funciona|compatib'

if echo "$prompt" | grep -qiE "\b($libs)\b" && echo "$prompt" | grep -qiE "($intent)"; then
  jq -n '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: "CONTEXT7: this prompt asks about a library, framework, SDK or CLI. Before answering from memory, call mcp__context7__resolve-library-id and then mcp__context7__query-docs (one query per concept) and answer from the fetched docs. Skip only for pure refactors, business-logic debugging or code review."}}'
fi
exit 0
