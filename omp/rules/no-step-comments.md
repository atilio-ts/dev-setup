---
description: No step-by-step or narrating comments
condition:
  - "(?i)(//|#)\\s*step\\s*\\d+"
  - "(?i)(//|#)\\s*this (method|function|class) (does|is used|will)"
scope:
  - tool:edit
  - tool:write
---
Delete this comment. Comment only non-obvious logic, in one short line.
