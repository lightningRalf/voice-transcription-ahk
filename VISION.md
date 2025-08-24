# Vision: Bavaria Dictation (voice-transcription-ahk)

Local, privacy-first, real-time dictation that transcribes your voice with high accuracy, low latency, and zero cloud dependencies. Centered on a single Rust core (orchestrator) for cross‑platform reliability; integrates Whisper.cpp (accuracy) and Vosk (speed) as pluggable engines. Optional Windows tray UI can exist as a plugin, not a dependency.

## Product Pillars
- Offline-only: 100% on-device; no telemetry by default.
- Single core binary: Rust orchestrator handles hotkeys/voice activation, audio I/O, engines, and output.
- Accuracy vs. latency: Whisper (chunked, accurate) + Vosk (streaming, fast with biasing).
- Minimal friction: push‑to‑talk hotkey or voice activation (VAD/wake word); paste or type into the focused app.
- Config-first: strict, versioned config with schema; user overrides and CLI/env for quick tweaks.
- Extensible: plugin APIs for engines, post‑processors (incl. DSPy/LLM), output adapters, hotkeys, model providers, MCP server.

## Success Metrics (from PRD)
- Accuracy: <= 10% WER on in-class sample.
- Latency: ~1s time-to-text after utterance end (Whisper), ~400ms/word (Vosk stream).
- Setup: ~5 minutes first run; 90% user satisfaction (>= 4/5) in pilot.
- Privacy: 100% offline; only opt-in manual update checks.

## System Architecture
```mermaid
flowchart LR
  user((User)) --> hk[Hotkey Manager\nWinAPI/X11/Wayland]
  user --> va[Voice Activation\nVAD + optional Wake Word]
  hk --> core
  va --> core

  subgraph core[Orchestrator (Rust)]
    ac[Audio Capture\nWASAPI/ALSA/AAudio via cpal]
    rb[Audio Buffer\nPCM 16 kHz mono]
    sw{Engine Switch}
    wW[Whisper Engine]
    wV[Vosk Engine]
    pp[Post-Processor\nPunctuation, Replacements, Casing]
    oa{Output Adapter}
    bus[Event Bus\nJSONL over STDOUT\n(local socket optional)]
  end

  ac --> rb --> sw --> wW --> pp
  sw --> wV --> pp
  pp --> oa --> app[Focused Application]
  core --> bus

  subgraph adapters[Platform Adapters]
    win[Windows: SendInput/Clipboard]
    lin[Linux: xdotool | wl-clipboard | portals]
    and[Android: Termux clipboard]
    tray[(Optional Windows tray UI)]
  end
  oa --> win
  oa --> lin
  oa --> and
  hk --> tray

  subgraph cfg[Config + Assets]
    config[(config/app.json + app.user.toml\nCLI/env overrides)]
    models[(models: Whisper ggml, Vosk)]
    logs[(logs: per-session, structured)]
  end

  config --> core
  models --> wW
  models --> wV
  core --> logs
```

## Privacy & Safety
- Offline by default; no background network. Any remote enrichment is explicit opt-in and visibly labeled.
- Logs are local-only with user-controlled retention and PII redaction.
- Robust error handling: clipboard restore on failure; path quoting; Unicode-safe I/O.

Config layers
- Canonical: `config/app.json` (schema-validated)
- User overrides: `config/app.user.toml` (merged on load)
- Fast overrides: CLI flags and environment variables

## Domain Ontology
```mermaid
classDiagram
  direction LR

  class User { <<Actor>> +pushToTalk(); +configure() }
  class Admin { <<Actor>> +deploy(); +update() }

  class Orchestrator { <<Core>> +run(); +emit() }
  class HotkeyManager { +register(); +toggle() }
  class VoiceActivation { +detect(); +threshold }
  class Recorder { +start(); +stop() }
  class AudioBuffer { <<Artifact>> +pcm16kMono }
  class EngineSwitch { <<Control>> }
  class Engine { <<Engine>> +transcribe(audio) }
  class WhisperEngine { +mode: chunked }
  class VoskEngine { +mode: streaming; +bias(vocab) }
  class PostProcessor { +punctuate(); +replace(); +case() }
  class LLMEnricher { <<Plugin>> +enrich(text): text }
  class OutputDispatcher { +paste(); +typeChars() }
  class WindowsAdapter { +sendInput(); +clipboard() }
  class LinuxAdapter { +xdotool(); +wlClipboard() }
  class AndroidAdapter { +termuxClipboard() }
  class Clipboard
  class ActiveApplication
  class ConfigStore { <<Config>> +load(); +mergeOverrides() }
  class Prompt { <<Config>> +text }
  class Vocabulary { <<Config>> +entries }
  class ReplaceMap { <<Config>> +pairs }
  class Settings { <<Config>> +hotkeys; +engine; +output }
  class Models { <<Artifact>> +whisperGGML; +voskModel }
  class Logger { +log(); +metrics() }
  class SessionLog { <<Artifact>> }
  class MCPServer { <<Plugin>> +serve() }

  User --> Orchestrator : uses
  Admin --> Orchestrator : deploys

  Orchestrator o-- HotkeyManager
  Orchestrator o-- VoiceActivation
  Orchestrator o-- Recorder
  Recorder --> AudioBuffer
  Orchestrator o-- EngineSwitch
  EngineSwitch --> Engine
  Engine <|-- WhisperEngine
  Engine <|-- VoskEngine
  WhisperEngine --> Models
  VoskEngine --> Models
  Engine --> PostProcessor
  PostProcessor <|.. LLMEnricher
  PostProcessor ..> ReplaceMap
  VoskEngine ..> Vocabulary
  PostProcessor --> OutputDispatcher
  OutputDispatcher <|.. WindowsAdapter
  OutputDispatcher <|.. LinuxAdapter
  OutputDispatcher <|.. AndroidAdapter
  OutputDispatcher --> Clipboard
  OutputDispatcher --> ActiveApplication
  Orchestrator o-- ConfigStore
  ConfigStore --> Prompt
  ConfigStore --> Vocabulary
  ConfigStore --> ReplaceMap
  ConfigStore --> Settings
  Orchestrator --> Logger
  Logger o-- SessionLog
  Orchestrator o-- MCPServer
```

## User Flow (Push‑to‑Talk or Voice Activation)
```mermaid
sequenceDiagram
  actor User
  participant HK as Hotkey Manager
  participant VA as Voice Activation
  participant OR as Orchestrator
  participant Rec as Recorder
  participant Eng as Engine (Whisper/Vosk)
  participant Post as Post-Processor
  participant Out as Output Adapter
  participant App as Target App

  User->>HK: Press PTT key (e.g., F8)
  alt Voice activation path
    VA-->>OR: Speech detected (VAD / wake word)
  end
  HK-->>OR: Toggle recording
  OR->>Rec: Start capture
  Rec-->>Eng: PCM frames (16 kHz)
  Note over Eng: Whisper (chunked) or Vosk (stream)
  Eng-->>Post: Partial/Final text
  Post-->>Out: Normalized text
  Out->>App: Paste (Ctrl+V) or Type
  User->>HK: Release PTT / silence met
  OR->>Rec: Stop capture
  OR-->>User: Audible cue / toast (optional)
```

## Runtime States
```mermaid
stateDiagram-v2
  [*] --> Idle
  Idle --> Listening: Voice activation enabled
  Idle --> Recording: PTT hotkey
  Listening --> Recording: Speech detected (VAD / wake word)
  Recording --> Transcribing: Buffer ready / partial
  Transcribing --> Recording: Continue streaming
  Transcribing --> Output: Final segment ready
  Output --> Idle: Completed
  Recording --> Idle: PTT released / silence timeout
  Idle --> Error: Engine failure
  Error --> Idle: Recover / Reset
```

## SLOs & Budgets
- Accuracy: ≤ 10% WER on domain samples (Whisper default); document tradeoffs by model size.
- Latency: ≤ 1s end-of-utterance (Whisper); ~400ms/word streaming (Vosk) on target hardware.
- CPU/RAM: stay within device budgets; degrade gracefully (smaller model, engine switch) if exceeded.
- Energy/Thermal (2nd–5th order): avoid sustained max CPU; provide power-aware presets; warn on thermal throttling (mobile/laptops).

## Orchestrator & Plugin Ecosystem
```mermaid
flowchart LR
  subgraph Orchestrator [Cross-Platform Orchestrator]
    loader[Plugin Loader]
    registry[Plugin Registry]
    cfg[Config Reader]
    cli[CLI JSONL Interface]
  end

  loader --> registry
  cfg --> registry
  registry --> ep1[EnginePlugin]
  registry --> ep2[OutputAdapterPlugin]
  registry --> ep3[PostProcessorPlugin]
  registry --> ep4[HotkeyPlugin]
  registry --> ep5[ModelProviderPlugin]

  ep1 -.implements.-> Engine
  ep2 -.implements.-> OutputDispatcher
  ep3 -.extends.-> PostProcessor

  cli --> registry
  registry --> Engines[(Engines: Whisper, Vosk, future)]
```

### Plugin Contracts
- EnginePlugin: spawn/attach, stream partials, emit finals, report metrics; deterministic test mode.
- OutputAdapterPlugin: paste/type with retries; Unicode-safe; clipboard restore guarantees.
- PostProcessorPlugin: punctuation, casing, replacements; idempotent; optional LLM/DSPy enrichment path.
- HotkeyPlugin: register/capture/toggle across platforms; fall back to OS keybindings on Wayland.
- ModelProviderPlugin: discover/download/verify models (checksums, sizes, memory hints).
- MCPServerPlugin: expose local commands (start/stop, switch engine, vocab ops, logs) to IDEs/agents.

## Config Model
```mermaid
classDiagram
  class AppConfig {
    platform: auto|windows|linux|android
    engine.active: whisper|vosk
    promptFile: path
    vocabFile: path
    replaceFile: path
    output.mode: clipboard|type
    logging.enabled: bool
  }
  AppConfig --> EngineConfig
  class EngineConfig {
    whisper.model: path
    whisper.args: string[]
    vosk.model: path
    vosk.hotwordBoost: number
  }
```

## CLI Contract (JSONL)
```text
> orchestrator --config ./config/app.json --mode session
< {"event":"partial","text":"...","ts":123.4}
< {"event":"final","text":"Guten Morgen.","latency_ms":980}
< {"event":"metric","cpu":0.42,"ram_mb":3200}
< {"event":"error","code":"ENGINE_NOT_FOUND","detail":"..."}
```

## Justfile Tasks (normative)
```makefile
just setup   # install engines/models per config
just dev     # run Windows AHK now; CLI later
just sanity  # engine sanity check with fixture
just test    # smoke/integration tests
just logs    # print log locations
just stop    # stop processes (future: orchestrator-managed)
```

## Extensions & Plugins (Future)
- EnginePlugin: ONNX/GPU engines; multilingual packs; local VAD/wake-word modules.
- OutputAdapterPlugin: Android IME integration; Wayland-native typing (portals); sandbox bridges.
- PostProcessorPlugin: DSPy/LLM enrichment; command lexicon ("Komma", "Punkt"); profanity filter; diacritics fixer.
- HotkeyPlugin: Wayland-specific strategies; Android intents; hardware button bindings.
- ModelProviderPlugin: LAN cache; delta updates; checksum verification; hardware-aware auto-selection.
- MCPServerPlugin: local automation/API for IDEs/agents with capability gating.

## Guardrails
- Offline only by default; no telemetry; explicit opt-in for any remote enrichment.
- Cross-platform reliability: avoid OS-specific hacks unless behind adapters.
- Performance: fit within CPU/RAM/energy budgets; degrade gracefully.
- Accessibility: audible cues; minimal UI assumptions; DE/EN text normalization.
- Supply chain: signed binaries and checksums; model integrity verification.

## Out of Scope (Core)
- OCR and system audio captioning (this is microphone dictation).
- Cloud engines by default (privacy-first). Optional remote enrichment only with explicit opt-in.
- iOS/macOS UI; Android IME (clipboard adapter only initially).

## Testing Strategy
- Core: Rust unit/property tests for audio/VAD/segmentation; contract tests for plugin APIs.
- Engines: CLI integration tests with fixtures; WER/latency sampling.
- Adapters: OS-level e2e (Windows SendInput/clipboard; X11/Wayland; Termux clipboard) using headless runners.
- Deterministic modes and golden files for post-processing.

## Open Questions
- Bundle optional language aids (e.g., Turkish) in future?
- Tray-only vs. floating toolbar preference?
- Punctuation commands ("Komma", "Punkt"): interpret vs. literal?

---
This vision defines a Rust-first, privacy-only dictation system with pluggable engines and adapters, delivering fast local transcription with a lean default path and room for optional enrichment and integrations.
