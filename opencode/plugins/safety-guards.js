import { readFileSync } from "node:fs"

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

const CMD_POS = "(^|[|;&(`]|\\$\\()\\s*(sudo\\s+|xargs\\s+)?"
const GREP = new RegExp(`${CMD_POS}(e|f)?grep(\\s|$)`)
const FIND_ROOT = new RegExp(`${CMD_POS}find\\s+/(\\s|$)`)

function stripQuoted(raw) {
  if (RAW_TRIGGER.test(raw)) return raw
  return raw
    .replace(/<<-?\s*(['"]?)(\w+)\1([^\n]*)\n[\s\S]*?\n[ \t]*\2[ \t]*(?:\n|$)/g, "$3\n")
    .replace(/"(?:[^"\\]|\\.)*"/g, '""')
    .replace(/'[^']*'/g, "''")
}

function checkBash(cmd) {
  const stripped = stripQuoted(cmd)
  const lines = stripped.split(/&&|\|\||;/).flatMap((l) => l.split("\n"))
  if (lines.some((l) => DESTRUCTIVE.some((re) => re.test(l)))) {
    throw new Error(`Destructive command blocked: ${cmd}`)
  }
  if (GREP.test(stripped)) {
    throw new Error(`Bloqueado: usa rg (ripgrep) en vez de grep. Comando: ${cmd}`)
  }
  if (FIND_ROOT.test(stripped) && !/-maxdepth\b/.test(stripped)) {
    throw new Error(`Bloqueado: find / sin acotar. Usa fd o agrega -maxdepth. Comando: ${cmd}`)
  }
}

function notUtf8(file) {
  try {
    new TextDecoder("utf-8", { fatal: true }).decode(readFileSync(file))
    return false
  } catch {
    return true
  }
}

export const SafetyGuards = async () => ({
  "tool.execute.before": async (input, output) => {
    if (input.tool === "bash" && output.args?.command) checkBash(output.args.command)
  },
  "tool.execute.after": async (input, output) => {
    if (input.tool !== "edit" && input.tool !== "write") return
    const file = input.args?.filePath ?? output.metadata?.filepath
    if (file && notUtf8(file)) {
      output.output += `\nWARNING: ${file} is not valid UTF-8. Re-read it and verify accent characters are intact.`
    }
  },
})
