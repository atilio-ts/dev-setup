# Coding Style

- Functions under ~50 lines, files under ~800, nesting no deeper than 4 levels
- Handle errors explicitly at every level; never swallow an exception
- Validate input at system boundaries (APIs, files, external data); fail fast with a clear message
- No hardcoded values that belong in constants or config
- Before committing: no secrets in code, parameterized SQL, error messages that don't leak sensitive data
- Before a large refactor, run `/compact` or `/clear` instead of starting it with the context nearly full
