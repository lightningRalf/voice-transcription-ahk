#!/usr/bin/env bash
set -Eeuo pipefail

# Headless loop to summarize project status periodically using Codex CLI

PROMPT=$'Follow docs/CONTINUE.md to produce a concise status summary.\n\
Read these files from the current repo (open them from disk):\n\
- VISION.md\n\
- PROJECT_STATUS.md\n\
- NEXT_STEPS.md\n\
- AGENTS.md\n\
- docs/tech-stack-rust.md\n\
- All Markdown files in docs/ (including docs/CONTINUE.md)\n\n\
Status content requirements (aligned with CONTINUE.md):\n\
- Key changes since last status (if detectable), major decisions, and any Decision Cards added/updated.\n\
- Open risks/issues with owners or files/paths referenced.\n\
- Next actions: 3-6 items, each actionable with an exact command to run (e.g., a Just recipe) and clear acceptance criteria.\n\
- Edge-cases coverage snapshot: list the EDGE_CASES marked as covered vs n/a with brief justification.\n\
- Complexity/throughput: note point estimates for current top items.\n\n\
Output format: At the very end, print EXACTLY the two markers on their own lines, and put the final status text between them.\n\
<<<LAST>>>\n\
<<<END>>>'

while true; do
  # SAFER default: sandboxed writes, only asks on failure
  codex exec -s workspace-write -a on-failure -C "$PWD" -- "$PROMPT" \
    | tee -a .headless.log \
    | awk '/^<<<LAST>>>/{p=1; next} /^<<<END>>>/{p=0} p' > .last.txt

  # Run every 60s
  sleep 60
done
