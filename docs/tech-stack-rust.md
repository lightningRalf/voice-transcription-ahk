# Tech Stack — Rust Core (Default)

Single Rust binary orchestrates hotkeys/voice activation, audio capture, engines, post-processing, and output — cross-platform by design (Windows, Linux/WSL2, Android via Termux).

## Core Crates & System Deps
- Audio I/O: `cpal` (WASAPI/ALSA/AAudio). Optional VAD via `webrtc-vad` or a lightweight energy VAD.
- Engines: invoke `whisper.cpp` and `vosk` as subprocesses with well-defined CLI contracts (stdout JSONL/text). Keep an EnginePlugin interface for FFI in the future.
- Hotkeys: `rdev` or `global-hotkey` for Windows/X11; on Wayland, prefer OS keybindings that trigger the CLI (no true global grabs).
- Output/Clipboard:
  - Windows: `windows` crate (SendInput) + clipboard via `arboard`/`copypasta`.
  - Linux: prefer `wl-clipboard`/portals on Wayland; `xdotool`/`xclip` on X11 (via adapter subprocesses).
  - Android/Termux: shell out to `termux-clipboard-set`.
- Config/CLI: `serde`, `serde_json`, `toml`, `clap`. Validate with `jsonschema` at startup.
- Logging/Events: `tracing`, `tracing-subscriber` (JSON), line-oriented JSONL sink for the event bus.

## Contracts (CLI & JSONL Events)
- CLI args:
  - `--config ./config/app.json` (canonical), merge `./config/app.user.toml`, then apply CLI/env overrides.
  - `session` mode (default), `sanity` (engine check), `test` (self-checks).
- Events (stdout, JSONL): `partial`, `final`, `metric`, `error` with stable fields to decouple tools/UIs.

## Config Conventions
- Canonical: `config/app.json` (schema enforced).
- Overrides: `config/app.user.toml` merged on load; CLI/env for fast tweaks.
- Paths are quoted; Unicode-safe; cross-platform separators normalized internally.

## Testing Strategy
- Unit/property tests (audio segmentation, VAD thresholds, replacement rules) using `proptest` where useful.
- Integration tests for engine subprocess contracts with fixtures (WER/latency sampling offline).
- Adapter e2e by platform (SendInput/clipboard on Windows; X11/Wayland; Termux clipboard).
- Deterministic post-processing with golden files.

## Build & Release
- Build: `cargo build --release`
- Cross-compile:
  - Windows: `x86_64-pc-windows-msvc`
  - Linux: `x86_64-unknown-linux-gnu` (consider musl for static where possible)
  - Android (Termux): `aarch64-linux-android` via NDK or compile natively in Termux
- Package: single binary + minimal adapters; ship checksums; sign Windows binaries when distributing.

## Observability & Safety
- No telemetry; network disabled by default. Any remote enrichment must be explicit opt-in.
- Logs: per-session file; redacted PII; user controls retention.
- Clipboard safety: restore on failure; retries; Unicode handling.

## Justfile Mapping
- `just setup` — download engines/models according to config (platform-aware script).
- `just dev` — run the orchestrator (when present) or Windows AHK stub.
- `just sanity` — run engine sanity check.
- `just test` — run core tests + integration checks.
- `just logs` — show log locations.

