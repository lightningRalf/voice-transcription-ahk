<!--
NEXT_STEPS.md — How to use this file

Keep this file ACTIONABLE. It drives TodoWrite in headless sessions.
Each item should include:
- Clear description starting with a verb
- Priority (P0/P1/P2), Owner, Estimate (S/M/L)
- Affected files/paths and exact commands to run (tests/builds)
- Acceptance criteria (what success looks like)

Maintain only upcoming work here (no historical notes). Remove completed items after updating PROJECT_STATUS.md.
Do not delete this comment block; append content below.
-->

# Next Steps — Bavaria Dictation (voice-transcription-ahk)

## P0 — Immediate
- [ ] <Task title>
  - Priority: P0 | Owner: <name> | ETA: <S/M/L>
  - Files: <paths>
  - Commands: <exact commands>
  - Acceptance: <criteria>

## P1 — Near Term
- [ ] <Task title>
  - Priority: P1 | Owner: <name> | ETA: <S/M/L>
  - Files: <paths>
  - Commands: <exact commands>
  - Acceptance: <criteria>

## P2 — Later
- [ ] <Task title>
  - Priority: P2 | Owner: <name> | ETA: <S/M/L>
  - Files: <paths>
  - Commands: <exact commands>
  - Acceptance: <criteria>

## Reference Commands
- Whisper sanity: `./engines/whispercpp/main.exe -m ./models/ggml-medium.bin -f tests/fixtures/sample.wav`
- Run app locally: `AutoHotkey64.exe ./src/dictate.ahk`
- Smoke tests: `powershell -File scripts/test.ps1`

