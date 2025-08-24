---
description: Continue work on project using headless/looped workflow
allowed-tools: Plan(update_plan), Shell(bash/rg/ls), Write(apply_patch), Just(just recipes)
---

## Session Workflow — Continue Development

Follow this workflow to continue development on this project using the Codex CLI. It aligns with AGENTS.md, the repository guidelines, and Justfile recipes.

### 1) Initialize Context
- Read `VISION.md` for goals, architecture, and SLOs.
- Read `PROJECT_STATUS.md` for current state and risks.
- Read `NEXT_STEPS.md` for actionable work.
- Skim `docs/tech-stack-rust.md` and `Justfile` for defaults and commands.

### 2) Create/Sync Task List
- Use the Plan tool (`update_plan`) to create a short task list from `NEXT_STEPS.md`.
- Keep tasks small, specific, and verifiable; start all as `pending`.
- Add a Fibonacci complexity estimate to each task in its description: {1,2,3,5,8,13,21}. Use SPIKE when unknown.

### 3) Execute Tasks
For each task:
- Mark it `in_progress` via `update_plan`.
- Do the work with `apply_patch` (editing files) and `Shell` (running commands).
- Prefer Just recipes:
  - Setup: `just setup`
  - Dev/run: `just dev`
  - Whisper sanity: `just sanity`
  - Smoke tests: `just test`
  - Logs: `just logs`
- When running shell commands that need escalated permissions (e.g., network, writes outside workspace), request approval and state why.
- Validate success against explicit criteria (tests pass, contract/CLI behavior, docs updated).
- Update docs immediately after each task:
  - Update `PROJECT_STATUS.md` with what changed, decisions, risks.
  - Update `NEXT_STEPS.md`: remove completed, add discoveries, keep actionable only.
- Mark the task `completed` in `update_plan`.

### 4) Handle Results & Discoveries
- If a task fails: capture exact error messages, file paths, and commands in `PROJECT_STATUS.md`; adjust `NEXT_STEPS.md`.
- If new work emerges: add new items (with estimates) to the Plan and `NEXT_STEPS.md`.
- Use Decision Cards for slices with meaningful risk/impact:
  - Objective, MUST/MUST-NOT, alternatives, risks/tail-risks, reversal/rollback, confidence.

### 5) Session Completion
- Update `PROJECT_STATUS.md` with the final state and any open risks.
- Update `NEXT_STEPS.md` with the remaining prioritized work.
- Summarize briefly: accomplished, still broken, next session focus.

## Important Rules
- Update docs after EACH task, not just at the end.
- Keep `NEXT_STEPS.md` actionable; remove stale items.
- Prefer reversible, low-blast-radius changes; feature-flag risky steps.
- Stay offline by default; no telemetry; do not commit models/logs/user data.
- Use the contract-first approach for any CLI/process boundaries; document args, exit codes, and JSONL events.
- Test before marking complete. Start with the narrowest tests that exercise the change, then broaden.
- Use logs under `%USERPROFILE%\\.bavariaDictation\\logs\\` or `$HOME/.bavariaDictation/logs/` to diagnose.

## Edge Cases Coverage
Track coverage in issues/docs and tests; mark each as `covered` or `n/a` with justification and links to tests/docs:
- Microphone unavailable or access denied
- Wrong sample rate/format (resampling or explicit error)
- Missing engines or models (actionable guidance, graceful disable)
- Insufficient RAM/CPU (suggest smaller model/engine switch)
- Invalid `vocab.json` or `replace.csv` (line/column errors)
- Clipboard blocked (fallback to SendInput; restore reliably)
- Unicode/umlaut handling (UTF-8 with BOM where required)
- Config missing/corrupt (safe defaults; repaired file + backup)
- Paths with spaces/non-ASCII (quote and test both engines)
- Antivirus false positive (signed artifacts + checksums; guidance)
- No elevation/locked-down env (avoid registry writes; portable)

## Complexity & Slices (Fibonacci)
- Use points {1,2,3,5,8,13,21}; SPIKE for unknowns.
- Split if a slice ≥13 points; largest child ≤8 unless atomic.
- Track throughput (points/session) to forecast capacity.

## Execution Examples

Example A — “Add engine wrapper contract test” (3 points)
- Plan: add a contract test that invokes the engine CLI with `--help` and validates JSONL schema for `stdout` when available.
- Steps:
  1) Create `tests/engine_contract_test.ps1` that runs `just sanity` or engine binary with sample input.
  2) Add fixtures under `tests/fixtures/` if needed.
  3) Run `just test`; ensure non-zero exit code on contract break.
  4) Update `PROJECT_STATUS.md` and `NEXT_STEPS.md`.
- Success: `just test` passes; logs contain expected entries; docs updated.

Example B — “Repair `NEXT_STEPS.md` to actionable” (1 point)
- Steps: prune vague items; add acceptance criteria and test/command per item.
- Success: Each item has a command to run and a clear expected result.

## Start Now
1) Read `VISION.md`, `PROJECT_STATUS.md`, and `NEXT_STEPS.md`.
2) Create/update the task list with `update_plan` (estimates included).
3) Execute tasks using `apply_patch` and `Shell`, validating with Just recipes.
4) Update docs after each task; keep iterating until the session goal is reached.

