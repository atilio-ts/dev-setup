import { existsSync, readFileSync } from "node:fs"
import { join } from "node:path"

const DESTRUCTIVE = [
  "git reset --hard",
  "git push --force",
  "git push -f ",
  "git push -f$",
  "git push.*--force-with-lease",
  "git rebase( .*)? (-i|--interactive)( |$)",
  "git rebase.*--onto",
  "git filter-branch",
  "git filter-repo",
  "git commit.*--amend",
  "git reflog.*delete",
  "git reflog.*expire",
  "git clean -f",
  "git checkout \\.",
  "git restore \\.",
  "git checkout( .*)? -- ",
  "git branch -D",
  "git branch -d",
  "git tag -d",
  "git push.*:refs/tags/",
  "git push.*--delete",
  "git push.*--prune",
  "git remote.*remove",
  "git remote.*rm",
  "git config.*--global",
  "git config.*--system",
  "rm -rf /",
  "rm -rf \\*",
  "rm -rf \\$",
  "rm -rf ~",
  "rm -rf \\.",
  "rm -fr ",
  "rmdir.*--ignore-fail",
  "dd if=",
  "dd of=",
  "> /etc/",
  "> /usr/",
  "> /bin/",
  "> /sbin/",
  "chmod -R 777",
  "chmod 777",
  "chown -R root",
  "chown root",
  "sudo chmod",
  "sudo chown",
  "DROP TABLE",
  "DROP DATABASE",
  "DROP SCHEMA",
  "TRUNCATE ",
  "DELETE FROM.*WHERE.*1=1",
  "DELETE FROM.*WHERE.*true",
  "kill -9",
  "kill -KILL",
  "pkill",
  "killall",
  "npm publish",
  "pip publish",
  "twine upload",
  "cargo publish",
  "gem push",
  "sudo su",
  "sudo -i",
  "sudo bash",
  "sudo sh",
  "sudo rm",
  "shred ",
  "wipe ",
  "mkfs\\.",
  "mkfs ",
  "truncate -s",
  "curl.*\\| *(sh|bash|python|node)",
  "wget.*\\| *(sh|bash)",
  "psql.*(DROP|TRUNCATE)",
  "mysql.*(DROP|TRUNCATE)",
  "sqlite3.*(DROP|DELETE FROM)",
].map((p) => new RegExp(p))

const RAW_TRIGGER =
  /(^|[^\w])((ba|z)?sh\s+-c|eval|xargs|ssh|docker\s+(exec|run)|kubectl\s+exec|psql|mysql|mariadb|sqlite3|sqlcmd|mongosh|duckdb)([^\w]|$)/

const CMD_POS = "(^|[|;&(`]|\\$\\()\\s*(sudo\\s+|xargs\\s+)?(rtk\\s+(proxy\\s+)?)?"
const GREP = new RegExp(`${CMD_POS}(e|f)?grep(\\s|$)`)
const FIND_ROOT = new RegExp(`${CMD_POS}find\\s+/(\\s|$)`)

function stripQuoted(raw: string) {
  if (RAW_TRIGGER.test(raw)) return raw
  return raw
    .replace(/<<-?\s*(['"]?)(\w+)\1([^\n]*)\n[\s\S]*?\n[ \t]*\2[ \t]*(?:\n|$)/g, "$3\n")
    .replace(/"(?:[^"\\]|\\.)*"/g, '""')
    .replace(/'[^']*'/g, "''")
}

function checkBash(cmd: string) {
  const stripped = stripQuoted(cmd)
  const lines = stripped.split(/&&|\|\||;/).flatMap((l: string) => l.split("\n"))
  if (lines.some((l: string) => DESTRUCTIVE.some((re) => re.test(l)))) {
    throw new Error(`Destructive command blocked: ${cmd}`)
  }
  if (GREP.test(stripped)) {
    throw new Error(`Bloqueado: usa rg (ripgrep) en vez de grep. Comando: ${cmd}`)
  }
  if (FIND_ROOT.test(stripped) && !/-maxdepth\b/.test(stripped)) {
    throw new Error(`Bloqueado: find / sin acotar. Usa fd o agrega -maxdepth. Comando: ${cmd}`)
  }
}

function notUtf8(file: string) {
  try {
    new TextDecoder("utf-8", { fatal: true }).decode(readFileSync(file))
    return false
  } catch {
    return true
  }
}

const SENSITIVE_PATH = [/\.env(\.(?!example$)[^/]*)?$/, /\.pem$/, /\.key$/, /(^|\/)\.ssh(\/|$)/, /(^|\/)\.aws(\/|$)/]
const SENSITIVE_IN_CODE = /(\.ssh\/|\.aws\/|(^|[\s"'/])\.env(\.(?!example\b)\w+)?(\s|["']|$))/
const BASH_READERS = /^(cat|less|more|head|tail|bat|nl|tac|xxd|od|strings|base64|cp|mv|scp|rg|awk|sed|source|\.|read)$/

const home = process.env.HOME ?? ""

const isSensitivePath = (p: string) => {
  const bare = p.replace(/^~(?=\/|$)/, home).replace(/:[^/:]*$/, "")
  return SENSITIVE_PATH.some((re) => re.test(bare))
}

function toolPaths(name: string, input: any): string[] {
  const out: string[] = []
  if (typeof input.path === "string") out.push(...input.path.split(/;\s*/))
  if (Array.isArray(input.paths)) out.push(...input.paths.filter((p: unknown) => typeof p === "string"))
  if (name === "edit" && typeof input.input === "string") {
    for (const m of input.input.matchAll(/^\[([^\]#\n]+)#/gm)) out.push(m[1])
  }
  return out
}

function readsSensitive(cmd: string) {
  return cmd.split(/&&|\|\||;|\||\n/).some((seg) => {
    const words = seg.trim().replace(/^(sudo|rtk)\s+(proxy\s+)?/, "").split(/\s+/)
    if (!BASH_READERS.test(words[0] ?? "")) return false
    return words.slice(1).some((w) => isSensitivePath(w.replace(/^['"]|['"]$/g, "")))
  })
}
const hasGraph = (root: string) =>
  existsSync(join(root, ".git")) &&
  (existsSync(join(root, ".code-review-graph")) || existsSync(join(root, ".vscode", "code-review-graph")))

export default function safetyGuards(pi: any) {
  const seenReads = new Set<string>()
  const editedPaths = new Map<string, string[]>()

  pi.on("tool_call", async (event: any, ctx: any) => {
    const input = event.input ?? {}
    const root = ctx?.cwd ?? process.cwd()
    if (event.toolName === "bash" && input.command) {
      try {
        checkBash(String(input.command))
      } catch (e: any) {
        return { block: true, reason: e.message }
      }
      if (readsSensitive(String(input.command))) {
        return { block: true, reason: `Bloqueado: lectura de archivo sensible por bash. Comando: ${input.command}` }
      }
    }
    if (event.toolName === "eval" && typeof input.code === "string") {
      const risky = input.code.split(/\n|;/).some((l: string) => DESTRUCTIVE.some((re) => re.test(l)))
      if (risky || SENSITIVE_IN_CODE.test(input.code)) {
        return { block: true, reason: "Bloqueado: eval con comando destructivo o archivo sensible." }
      }
    }
    const sensitive = event.toolName === "bash" ? undefined : toolPaths(event.toolName, input).find(isSensitivePath)
    if (sensitive) {
      return { block: true, reason: `Bloqueado: acceso a archivo sensible '${sensitive}'.` }
    }
    if ((event.toolName === "glob" || event.toolName === "grep") && hasGraph(root)) {
      return {
        block: true,
        reason: `Bloqueado: este repo tiene code-review-graph. Usa mcp__code_review_graph_query_graph_tool / semantic_search_nodes_tool / get_impact_radius_tool en vez de ${event.toolName}.`,
      }
    }
    if (event.toolName === "read" && typeof input.path === "string") {
      const abs = input.path.startsWith("~") ? input.path.replace("~", home) : input.path
      if (!input.path.includes("://") && existsSync(join(home, ".file-stash"))) {
        if (!seenReads.has(abs)) {
          seenReads.add(abs)
          return {
            block: true,
            reason: `Bloqueado (primer intento): usa mcp__filestash_read_file para explorar '${input.path}'. Si vas a editar este archivo ahora, repite read y continua con edit.`,
          }
        }
      }
    }
    if (event.toolName === "edit" || event.toolName === "write") {
      editedPaths.set(event.toolCallId, toolPaths(event.toolName, input))
    }
  })

  pi.on("tool_result", async (event: any) => {
    const paths = editedPaths.get(event.toolCallId)
    if (!paths) return
    editedPaths.delete(event.toolCallId)
    const bad = paths.filter((p: string) => existsSync(p) && notUtf8(p))
    if (bad.length) {
      return {
        additionalContext: `WARNING: ${bad.join(", ")} is not valid UTF-8. Re-read it and verify accent characters are intact.`,
      }
    }
  })
}
