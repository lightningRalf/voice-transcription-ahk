# Product Requirements Document (PRD)

## 0. Revision History

| Date (YYYY-MM-DD) | Version | Author  | Notes         |
| ----------------- | ------- | ------- | ------------- |
| 2025-06-07        | 0.1     | ChatGPT | Initial draft |

---

## 1. Purpose

Design and deliver a **local, real-time speech-to-text dictation tool** for Windows 11 that:

1. Uses **Whisper.cpp** for high-accuracy transcription in German with Bavarian accents.
2. Integrates **Vosk’s large German model** as an optional fast/streaming engine with reconfigurable vocabulary.
3. Employs **AutoHotkey (AHK)** to provide global hotkeys and inject transcribed text at the current cursor position.
4. Allows teachers to add or boost custom words (student names, multicultural terminology, subject jargon).
5. Supplies an editable **initial prompt** tailored to a Bavarian middle-school classroom with a high immigrant percentage.

## 2. Background & Problem Statement

Bavarian Mittelschule teachers often write digital lesson plans, assessments, and emails while juggling classroom duties. Existing cloud dictation tools violate privacy rules (GDPR) and struggle with regional accents. Teachers need an **offline** solution that respects data privacy, handles diverse student names, and seamlessly types where the caret is, saving preparation time and increasing inclusivity for teachers with repetitive-strain injuries.

## 3. Goals & Success Criteria

| Goal                              | KPI / Success Metric                                                                                      |
| --------------------------------- | --------------------------------------------------------------------------------------------------------- |
| High accuracy for Bavarian German | Word Error Rate (WER) =?10?% on 10-minute in-class recording sample                                       |
| Low latency                       | Time-to-text =?1?s after end of utterance for sentences =?10?s on target PC (i7/Ryzen, 64?GB RAM, no GPU) |
| Ease of use                       | =?5?min first-time setup; =?90?% of teachers rate usability =?4/5 in pilot survey                         |
| Privacy compliance                | 100?% offline processing; no outbound network traffic except update checks (opt-in)                       |
| Custom vocabulary satisfaction    | Teacher can add/edit a word and observe recognition improvement within one session                        |

## 4. Out of Scope

* Mobile platforms (iOS/Android).
* OCR of printed material.
* Real-time captions for audio playing **from** the PC (focus is microphone/mic array input).

## 5. Personas

* **Petra K.** – 43-year-old Bavarian Mittelschule teacher (history & ethics); native Bavarian accent; moderate tech skills; classroom PC with headset mic.
* **Fatih A.** – 14-year-old student whose Turkish name is often mis-recognized; Petra wants his name transcribed correctly.
* **IT-Admin** – maintains Windows images, prefers portable apps, minimal registry changes.

## 6. User Stories

1. *As Petra, I press **F8** and dictate a homework assignment; the text appears instantly in Word.*
2. *As Petra, I add new student names in a simple UI and notice they are recognized the next time I dictate.*
3. *As the IT-admin, I deploy the tool via a zipped folder without needing administrator rights or an installer.*
4. *As Petra, I toggle between "High-Accuracy" (Whisper) and "Low-Latency" (Vosk) modes depending on lesson pace.*

## 7. Functional Requirements

### 7.1 Audio Capture

* Record from default Windows microphone (MMDevice API).
* Sample rate 16?kHz PCM mono (Whisper.cpp auto-resamples if needed).

### 7.2 Transcription Engines

| Engine            | Mode               | Purpose                                                                                   |
| ----------------- | ------------------ | ----------------------------------------------------------------------------------------- |
| **Whisper.cpp**   | Chunked (sentence) | Maximum accuracy; uses `medium` model by default; configurable to `large` if CPU permits. |
| **Vosk Large DE** | Streaming          | Near-zero latency; supports dynamic wordlist biasing.                                     |

Engine switching exposed in tray-menu or hotkey (e.g., Ctrl+Shift+F8).

### 7.3 Initial Prompt

Default:

```
Kontext: Unterricht in einer bayerischen Mittelschule mit hohem Anteil an Schüler:innen mit Migrationshintergrund. Häufige Eigennamen: Fatih, Aisha, Dragana, Ahmed, Leila. Unterrichtsfächer: Geschichte, Ethik, Deutsch als Zweitsprache. Verwende höfliche Anrede in Standarddeutsch.
```

Editable via `prompt.txt`; loaded on each recording session.

### 7.4 Custom Vocabulary / Hot-Words

* JSON file `vocab.json` with `{"word": boost}` pairs.
* On session start, if Vosk engine active, send list to recognizer.
* For Whisper, apply post-process replacement map `replace.csv` (`search,replace`).

### 7.5 AHK Integration

* **F8** – Start/Stop recording. While recording, tray icon changes color.
* **Ctrl+Alt+F8** – Switch engine.
* Script listens for completion event, copies text to clipboard (UTF-8), then sends `^v` (paste) to active window.
* Option: "Type character-by-character" mode to avoid clipboard (for secure apps).

### 7.6 Settings UI

* Single INI/JSON editor launched from tray.
* Options: model size, engine choice, hotkeys, noise gate threshold, auto-punctuation, start-on-boot.

### 7.7 Logging & Metrics

* Store per-session logs (`logs/YYYY-MM-DD.txt`) with WER vs. ground-truth if teacher opts in to provide corrections.

### 7.8 Updates

* Portable updater checks GitHub releases (manual trigger) respecting proxy settings; no background auto-update by default.

## 8. Non-Functional Requirements

| Category      | Requirement                                                      |
| ------------- | ---------------------------------------------------------------- |
| Performance   | =?30?% CPU on 8-core CPU during idle; =?60?% while transcribing. |
| Memory        | =?6?GB RAM for Whisper `medium`, =?3?GB for Vosk Large.          |
| Security      | Signed binaries; no elevation required.                          |
| Accessibility | Tooltips, high-contrast icon set.                                |
| Localization  | UI available in German and English.                              |

## 9. Technical Architecture

```
[Microphone] -> [Audio Buffer] -> (Engine Switch) ->
    [Whisper.cpp Worker] --or-- [Vosk Worker]
        -> [Post-process (punctuation, replacement)]
        -> [AHK Output Dispatcher]
            -> Clipboard / SendInput -> Active Application
```

* **AHK Output Dispatcher** implemented via AutoHotkey v2 script (`dictate.ahk`).
* Engines run as separate CLI processes; communicate with AHK via STDOUT pipes.
* Config files in `%USERPROFILE%\.bavariaDictation\`.

## 10. Security & Privacy

* All audio stays local; cached recordings auto-deleted after successful transcription unless logging is enabled.
* No telemetry. Optional opt-in error logging uploads stack traces only.
* GDPR-compliant by design.

## 11. Acceptance Criteria (Sample)

1. Pressing F8 starts recording; icon animates ? *Pass*.
2. Whisper mode returns correct transcription of sample Bavarian sentence with =?10?% WER on test hardware ? *Pass*.
3. Adding `Yusuf` with boost =?15 causes engine to output that spelling in next dictation ? *Pass*.
4. Switching to Vosk mode yields streaming transcription with average latency =?400?ms per word ? *Pass*.
5. Clipboard contents restored after dictation (edge case) ? *Pass*.

## 12. Milestones

| Milestone                     | Date       | Owner            |
| ----------------------------- | ---------- | ---------------- |
| M0 – PRD sign-off             | 2025-06-14 | Product Lead     |
| M1 – Prototype (Whisper only) | 2025-07-01 | Dev Team         |
| M2 – Add Vosk + vocabulary UI | 2025-08-01 | Dev Team         |
| M3 – Pilot in two schools     | 2025-09-15 | PM + QA          |
| M4 – GA Release v1.0          | 2025-10-15 | Cross-functional |

## 13. Risks & Mitigations

| Risk                                           | Impact | Likelihood | Mitigation                                                                      |
| ---------------------------------------------- | ------ | ---------- | ------------------------------------------------------------------------------- |
| CPU performance on older hardware insufficient | Med    | Med        | Provide preset with Vosk small model; instruct user to lower model size.        |
| Accent or code-switching accuracy              | High   | Med        | Continuous prompt tuning and word-boost edits; encourage teacher feedback loop. |
| Anti-virus false positives on AHK scripts      | Low    | Med        | Code-sign all binaries and scripts; distribute SHA-256 checksums.               |

## 14. Open Questions

1. Should we bundle language packs for non-German second languages (e.g., Turkish) for dual-language classrooms?
2. UI: Do teachers prefer a floating toolbar vs. tray-only?
3. Support for punctuation command words ("Komma", "Punkt") – parse or dictate literally?

---

*End of PRD v0.1*

