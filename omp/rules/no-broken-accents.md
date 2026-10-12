---
description: Detect broken UTF-8 accents (mojibake) in written files
condition:
  - "Ã[¡©³ºñ¿±]"
  - "\uFFFD"
scope:
  - tool:edit
  - tool:write
---
The text contains broken accent characters. Rewrite it keeping the original UTF-8 accents (á, é, í, ó, ú, ñ).
