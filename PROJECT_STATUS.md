<!--
PROJECT_STATUS.md — How to use this file

Update this file AFTER EVERY TASK. Keep it concise and factual.
Include:
- Current milestone and summary of the state
- What changed this session (files touched, commands run, results)
- What works vs. what’s broken (with exact error messages + file paths)
- Test commands and outcomes (pass/fail, snippets of output)
- Environment details (OS, AHK version, engine versions/models used)
- Risks, blockers, decisions made, and open questions

This file is consumed by headless workflows together with VISION.md and NEXT_STEPS.md.
Do not delete this comment block; append content below.
-->

# Project Status — Bavaria Dictation (voice-transcription-ahk)

- Last updated: <YYYY-MM-DD HH:MM UTC>
- Current milestone: <M0/M1/M2/M3/M4>
- Overall health: <green|yellow|red>

## Summary
- Short paragraph summarizing current state and progress.

## Changes This Session
- Files modified: <paths>
- Commands run: <commands>
- Results: <brief outcomes>

## Component Status
- AHK Tray/Hotkeys: <state>
- Audio Capture/Buffer: <state>
- Whisper.cpp Wrapper: <state>
- Vosk Wrapper + Vocabulary: <state>
- Post-processing (punctuation, replace.csv): <state>
- Output Dispatcher (clipboard/type): <state>
- Config & Models: <state>
- Tests/Smoke: <state>

## Tests & Evidence
- Test command: <cmd>
- Expected vs. actual: <notes>
- Logs/artifacts: <paths>

## Metrics (target vs. observed)
- WER: <target 10%> | <observed>
- Latency: <target ~1s end-of-utterance / ~400ms per word> | <observed>
- CPU/RAM: <targets> | <observed>

## Risks & Blockers
- <risk/blocker and mitigation or owner>

## Decisions
- <decision> — Rationale: <why> — Date: <YYYY-MM-DD>

## Open Questions
- <question>

## Next Review
- Date/time: <YYYY-MM-DD>
- Owner: <name>

