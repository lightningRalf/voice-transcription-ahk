# Justfile for Bavaria Dictation

# Detect OS family
set shell := ["bash", "-cu"]

default: help

help:
  @echo "Available recipes:"
  @echo "  just setup          # Install deps/models based on config"
  @echo "  just dev            # Run app (Windows AHK now; CLI planned)"
  @echo "  just sanity         # Quick engine sanity check"
  @echo "  just test           # Run smoke/integration tests"
  @echo "  just logs           # Show latest session log path"
  @echo "  just stop           # Stop running processes (placeholder)"

# Cross-platform setup (Windows uses PowerShell if available; else no-op)
setup:
  if command -v powershell.exe >/dev/null 2>&1; then \
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/setup.ps1; \
  elif command -v pwsh >/dev/null 2>&1; then \
    pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/setup.ps1; \
  elif [ -f scripts/setup.sh ]; then \
    bash scripts/setup.sh; \
  else \
    echo "No setup script for this platform yet. See README and VISION."; \
  fi

# Development entrypoint
dev:
  if command -v AutoHotkey64.exe >/dev/null 2>&1; then \
    AutoHotkey64.exe ./src/dictate.ahk; \
  else \
    echo "No AHK runtime found. Planned cross-platform CLI orchestrator not yet implemented."; \
    echo "See VISION.md: Orchestrator & Adapters."
  fi

# Whisper sanity check (paths from config/app.json if present)
sanity:
  if [ -x ./engines/whispercpp/main.exe ]; then \
    ./engines/whispercpp/main.exe -m ./models/ggml-medium.bin -f tests/fixtures/sample.wav || echo "Provide a small WAV at tests/fixtures/sample.wav"; \
  else \
    echo "Whisper binary not found. Run: just setup"; \
  fi

# Smoke/integration tests
test:
  if command -v powershell.exe >/dev/null 2>&1; then \
    powershell.exe -NoProfile -File scripts/test.ps1; \
  elif command -v pwsh >/dev/null 2>&1; then \
    pwsh -NoProfile -File scripts/test.ps1; \
  elif [ -f scripts/test.sh ]; then \
    bash scripts/test.sh; \
  else \
    echo "No test runner available on this platform yet."; \
  fi

# Show latest log file location
logs:
  @echo "Logs folder (Windows): %USERPROFILE%\\.bavariaDictation\\logs\\YYYY-MM-DD.txt"
  @echo "Logs folder (Linux/Android): $HOME/.bavariaDictation/logs/YYYY-MM-DD.txt"

# Placeholder for graceful shutdown
stop:
  @echo "If engines are running, stop them via your OS tools (Task Manager / kill)."
  @echo "Future: orchestrator will manage PID files for stop."

