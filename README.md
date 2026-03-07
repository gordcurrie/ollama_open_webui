# Project: Ollama and Open-WebUI Management

This repository contains shell scripts and a Makefile to manage services related to Ollama and Open-WebUI using Homebrew and Podman.

## Prerequisites

Before using the scripts and Makefile in this repository, ensure you have the following installed:

- **Homebrew**: A package manager for macOS.
  - Install Homebrew by following the instructions at [https://brew.sh/](https://brew.sh/)
- **Podman**: A container management tool similar to Docker.
  - Install Podman using Homebrew:

    ```sh
    brew install podman
    ```

- **Ollama**: A service that needs to be managed.
  - Install Ollama using Homebrew (if not already installed):

    ```sh
    brew install ollama
    ```

## Setup

1. Clone the repository:

   ```sh
   git clone https://github.com/gordcurrie/ollama_open_webui.git
   cd ollama_open_webui
   ```

2. Ensure that your shell scripts have executable permissions:

   ```sh
   chmod +x ollama.sh open-webui.sh post_update_ollama.sh
   ```

## Usage

1. Restart Ollama service

   ```sh
   make restart-ollama
   ```

2. Run post-update configuration for Ollama

   ```sh
   make ollama-post-update
   ```

   **Note**: Run this after updating Ollama via Homebrew (`brew upgrade ollama`). Ollama updates remove the `OLLAMA_HOST` environment variable, which prevents external access. This command restores the setting and restarts the service.

3. Update and restart Open_WebUI

   ```sh
   make update-open-webui
   ```

4. Run smoke tests

   ```sh
   make test
   ```

   Tests validate that each script exists, is executable, and passes a bash syntax check. When required dependencies are available, tests may also briefly execute the script, which can have side effects (e.g. restarting services). Tests for scripts with unavailable dependencies are automatically skipped.

## Scripts Features

### test-scripts.sh
Smoke test runner that checks each script for existence, executable permissions, and syntax validity. When dependencies (Homebrew, Podman, Ollama) are available, it may briefly execute each script as part of the smoke check — which can have side effects. Tests requiring unavailable dependencies are automatically skipped.

### ollama.sh
Script to restart the Ollama service with proper error handling, logging, and version checking.

### open-webui.sh
Script to stop, remove, and restart the Open-WebUI container with comprehensive cleanup, logging, and version checking.

### post_update_ollama.sh
Script to restore the OLLAMA_HOST environment variable after Ollama updates with logging and version checking.

## Logging

All scripts now include logging functionality that:
- Writes log entries to log files under `/tmp` (file names may vary by script and can include timestamps)
- Provides detailed operational feedback
- Outputs log-related messages to both the terminal and the log files for troubleshooting

