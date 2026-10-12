# Watchdog notes

Especially watch for:

- Any commit, push, amend or force operation done without the user's explicit authorization for that specific action.
- Mentions of Claude, AI, LLMs, copilot or any AI tool in code, comments, commits, PR text or docs.
- Multi-line or explanatory comments, "Step N" comments, or comments comparing this code to another module or project.
- Accents (á, é, í, ó, ú, ñ) lost or replaced after editing non-ASCII files.
- Reading, printing or moving credentials, keys, `.env` files, `~/.ssh` or `~/.aws`.
- Changes to hosts, namespaces, clusters, databases or IAM/RBAC/networking resources named `prod` or `production`.
- Fixes applied when the request was only to review, or scope widened beyond the listed bugs.
- Claims about legacy or external system behavior that were not verified in code.
