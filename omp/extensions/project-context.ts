import { existsSync, readdirSync, readFileSync } from "node:fs"
import { homedir } from "node:os"
import { dirname, join } from "node:path"

const FILE = join(".vscode", "CLAUDE.md")
const CLAUDE_PROJECTS = join(homedir(), ".claude", "projects")
const MAX_INDEX_LINES = 200
const MAX_INDEX_CHARS = 8000
const GRAPH_REMINDER =
  "REMINDER: This project has a code-review-graph database. Use the mcp__code_review_graph_* tools (query_graph_tool, semantic_search_nodes_tool, get_impact_radius_tool, etc.) as the primary navigation/impact tool BEFORE glob or grep."

function ancestors(start: string) {
  const home = homedir()
  const dirs: string[] = []
  for (let dir = start; dir !== home && dir !== dirname(dir); dir = dirname(dir)) dirs.push(dir)
  return dirs
}

function hasGraph(start: string) {
  const root = ancestors(start).find((d) => existsSync(join(d, ".git")))
  return !!root && (existsSync(join(root, ".code-review-graph")) || existsSync(join(root, ".vscode", "code-review-graph")))
}

function memoryDir(start: string) {
  for (const dir of ancestors(start)) {
    for (const key of [dir.replace(/[^a-zA-Z0-9]/g, "-"), dir.replace(/[/.]/g, "-")]) {
      const mem = join(CLAUDE_PROJECTS, key, "memory")
      if (existsSync(mem) && readdirSync(mem).some((f) => f.endsWith(".md") && f !== "MEMORY.md")) return mem
    }
  }
  return null
}

function memoryIndex(mem: string) {
  const index = join(mem, "MEMORY.md")
  let lines = existsSync(index) ? readFileSync(index, "utf-8").split("\n").filter((l) => l.startsWith("- ")) : []
  if (!lines.length) {
    lines = readdirSync(mem)
      .filter((f) => f.endsWith(".md") && f !== "MEMORY.md")
      .map((f) => `- [${f}](${f}) — ${readFileSync(join(mem, f), "utf-8").match(/^description:\s*"?(.*?)"?\s*$/m)?.[1] ?? ""}`)
  }
  return lines.slice(0, MAX_INDEX_LINES).join("\n").slice(0, MAX_INDEX_CHARS)
}

function memoryBlock(mem: string) {
  return [
    `Project memory (shared with Claude Code), notes in ${mem}. Index only; read a note with the read tool when it is relevant to the task:`,
    memoryIndex(mem),
    `To save a durable fact, write ${mem}/<type>_<slug>.md with frontmatter (name, description, metadata.type: user|feedback|project|reference), a body with **Why:** and **How to apply:** for feedback/project notes, and add one line "- [Title](file.md) — hook" to ${mem}/MEMORY.md. Check for an existing note first and update it instead of duplicating. Never store secrets or facts derivable from the code.`,
  ].join("\n\n")
}

export default function (pi: any) {
  let injected = false

  pi.on("session_switch", () => {
    injected = false
  })
  pi.on("session_compact", () => {
    injected = false
  })

  pi.on("before_agent_start", async (_event: any, ctx: any) => {
    if (injected) return
    const parts: string[] = []
    const file = ancestors(ctx.cwd).map((d) => join(d, FILE)).find(existsSync)
    if (file) parts.push(`Project instructions from ${file}:\n\n${readFileSync(file, "utf-8")}`)
    if (hasGraph(ctx.cwd)) parts.push(GRAPH_REMINDER)
    const mem = ctx.agent?.kind === "sub" ? null : memoryDir(ctx.cwd)
    if (mem) parts.push(memoryBlock(mem))
    if (!parts.length) return
    injected = true
    return { message: { customType: "project-context", content: parts.join("\n\n"), display: false } }
  })
}
