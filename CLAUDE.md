# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
make test                # Run smoke tests (syntax check + brief execution per script)
make restart-ollama      # Restart Ollama via brew services
make ollama-post-update  # Configure OLLAMA_HOST after updating the native macOS app
make update-open-webui   # Pull latest Open-WebUI container image and restart it
```

## Architecture

Four shell scripts, each with Makefile target. All scripts: dependency check → log setup → operation → success/error exit.

**Two distinct Ollama install modes — mutually exclusive:**

- `ollama.sh` — targets Homebrew-managed Ollama (`brew services restart ollama`)
- `post_update_ollama.sh` — targets native macOS Ollama.app (`/Applications/Ollama.app`), self-updating. Creates persistent `LaunchAgent` (`com.ollama.environment.plist`) setting `OLLAMA_HOST=0.0.0.0` at login — native app update wipes env config.

**open-webui.sh** — manages Open-WebUI as Podman container (`ghcr.io/open-webui/open-webui:latest`). Stops/removes existing container+image, runs fresh with `--pull=always`. Data persists via `open-webui` named volume.

**test-scripts.sh** — smoke test runner. Checks each script: existence, executable bit, bash syntax (`bash -n`). If required dependency present (brew+ollama service, podman, brew+ollama formula), briefly executes and kills after 5 seconds. Missing dependencies → skip, not fail.

## Key constraints

- Scripts use `#!/usr/bin/env bash`, must be compatible with macOS bash 3.2 — no `mapfile`/`readarray`.
- Scripts write timestamped logs to `/tmp`, clean files older than 7 days.
- `test-scripts.sh` runs scripts with real side effects (restarts services, recreates containers) when dependencies present.