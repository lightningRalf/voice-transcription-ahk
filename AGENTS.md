# Repository Guidelines

This repository currently contains the PRD. Use these guidelines to keep upcoming AutoHotkey (AHK) and engine code consistent with the planned Whisper.cpp/Vosk architecture.

## Project Structure & Module Organization
- src/: AHK v2 scripts (e.g., dictate.ahk, tray.ahk, engine-switch.ahk)
- engines/: Engine binaries + wrappers (whispercpp/, vosk/)
- models/: Downloaded models (e.g., ggml-medium.bin, vosk-model-de)
- config/: Defaults and samples (prompt.txt, vocab.json, replace.csv)
- scripts/: Dev/setup/packaging helpers (PowerShell/Batch)
- tests/: Smoke and integration tests; fixtures/
- assets/: Icons/tray art; docs/: design notes; logs/: runtime logs (gitignored)

## Build, Test, and Development Commands
- Setup: powershell -ExecutionPolicy Bypass -File scripts/setup.ps1
  - Downloads engines/models and seeds %USERPROFILE%\.bavariaDictation\
- Run locally: AutoHotkey64.exe .\src\dictate.ahk
  - Starts tray app; F8 toggles recording; Ctrl+Alt+F8 switches engine
- Whisper sanity check: .\engines\whispercpp\main.exe -m .\models\ggml-medium.bin -f sample.wav
- Tests/smoke: powershell -File scripts/test.ps1
  - Verifies start/stop flow and paste/clipboard behavior

## Coding Style & Naming Conventions
- Language: AutoHotkey v2 only. Add #Requires AutoHotkey v2 at top.
- Encoding/EOL: UTF-8 (with BOM) and CRLF for Windows compatibility.
- Indentation: 4 spaces; max line ~120 chars.
- Names: Classes PascalCase; functions/variables lowerCamelCase; constants ALL_CAPS; scripts kebab-case where practical.
- File layout: One public class or cohesive script per file; co-locate small helpers under src/lib/.

## Testing Guidelines
- Prefer fast smoke tests that drive the AHK entrypoint and assert observable behavior (tray state, output text).
- Frameworks: Pester (PowerShell) for orchestration, or minimal AHK harness; name tests *_spec.ps1 or *_test.ahk.
- Coverage: Aim to cover engine wrappers and output dispatcher; include fixtures under tests/fixtures/.

## Commit & Pull Request Guidelines
- Commits: Use Conventional Commits (e.g., feat: add Vosk wrapper, fix: restore clipboard on error, docs: update PRD).
- PRs: Clear description, linked issues, steps to reproduce/test, screenshots or short GIFs for UI/tray changes, and notes on model/version impacts.
- Size: Prefer small, focused PRs; include rollback notes if touching engines/models.

## Security & Configuration Tips
- Keep everything offline; never add telemetry. Do not commit models/, logs/, or user data; ensure they’re gitignored.
- Default config path: %USERPROFILE%\.bavariaDictation\; provide safe defaults; avoid elevation and registry writes unless justified.

---

## Agent Operating Rules (Edge-Case Gated)
- Do not stop until edge cases are handled.
- STOP WHEN: Every EDGE_CASES item is covered or n/a with justification, and there is evidence (tests/docs/logs/links).

### Complexity Estimation (Fibonacci points)
- Use points {1, 2, 3, 5, 8, 13, 21}; never estimate calendar time.
- Heuristics: 1 trivial file; 2 small change + tests; 3 multi-file or new function with one external edge; 5 several edges or contract change; 8 cross-module or new component; 13 large redesign; 21+ split before starting.
- Unknowns: add a SPIKE (points only) to reduce uncertainty, convert later.
- Throughput: track points per slice (use recent median to forecast capacity).

### Change Safety
- Prefer reversible, low-blast-radius steps; feature-flag risky changes; define rollback paths.
- For each slice, write a Decision Card: objective, constraints (MUST), alternatives, main risks/tail-risks, what would change the decision, confidence.
- Split rule: If complexity ≥ 13, split into children where largest ≤ 8 unless a single atomic change is required (document why).

## Engineering Principles (Foundation)
1) Outcome-driven & constraint-aware — make objectives, MUST/MUST-NOT, and risk bounds explicit up front.
2) Contract-first boundaries — define CLI/process contracts clearly (args, exit codes, stdout/stderr JSONL); keep invariants & SLOs in those contracts.
3) Modular monolith first — separate AHK orchestration, engine wrappers, and config as modules; split only for distinct SLOs or compliance.
4) Reliability as a budget — define SLIs/SLOs (WER, latency); use error budgets to gate changes.
5) Delivery health — track deploy packaging cadence, change-fail rate, and time-to-restore.
6) Observability — structured logs with correlation IDs/session IDs; per-session log files.
7) 12-Factor hygiene — config in files under %USERPROFILE%\.bavariaDictation\; reproducible setup via scripts; one-command smoke tests.
8) Risk-proportionate testing — unit-like AHK harness pieces where feasible + Pester orchestration + contract/CLI tests for engines.
9) Security & privacy — offline by default; least privilege; signed binaries; no telemetry.
10) Change safety & reversibility — feature flags, staged rollouts, tested rollback; forward/backward-compatible config migrations.
11) Cost & capacity — model sizes vs. RAM/CPU budgets; document tuning guidance.
12) Knowledge compounding — ADRs for big decisions; status and next steps kept current.

## Default Execution Lane (Tech Stack)
- Default: @docs/tech-stack-rust.md
  - To switch lanes later, replace the import with another tech-stack doc (e.g., @docs/tech-stack-ts.md). Keep only one active to avoid conflicting defaults.

## Test & Run Pattern (Project-specific)
- Prefer Justfile recipes for all actions.
- Run locally: `just dev`
- Setup/downloads: `just setup`
- Whisper sanity: `just sanity`
- Smoke tests: `just test`
- Logs: `just logs`
- Logs folder: `%USERPROFILE%\\.bavariaDictation\\logs\\YYYY-MM-DD.txt` or `$HOME/.bavariaDictation/logs/`

## Headless Session Workflow
- See `docs/CONTINUE.md` for the “continue” workflow used in headless/looped sessions.
- Always update `PROJECT_STATUS.md` and `NEXT_STEPS.md` after EACH task.

## EDGE_CASES Checklist
- Microphone unavailable or access denied — fallback prompt, error messaging, and retry path.
- Wrong sample rate/format — resampling path verified; explicit error if unsupported.
- Missing engines or models — clear setup guidance; graceful disable with actionable error.
- Insufficient RAM/CPU for chosen model — suggest model downsize or engine switch.
- Invalid `vocab.json` or `replace.csv` — validate and surface line/column of failure.
- Clipboard blocked — fallback to SendInput typing; restore clipboard reliably on error.
- Unicode/umlaut handling — UTF-8 (with BOM) end-to-end; verify paste correctness.
- Config missing/corrupt — load safe defaults; write repaired file with backup.
- Paths with spaces/non-ASCII — quote paths and test both engines.
- Antivirus false positive — signed artifacts + checksums; user guidance.
- No elevation/locked-down environment — avoid registry writes; portable mode.

Mark each as `covered` or `n/a` with justification and link to tests/docs.
