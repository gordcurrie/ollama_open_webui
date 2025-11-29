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
  ```
  make restart-ollama
  ```

2. Run post-update configuration for Ollama
  ```
  make ollama-post-update
  ```
  **Note**: Run this after updating Ollama via Homebrew (`brew upgrade ollama`). Ollama updates remove the `OLLAMA_HOST` environment variable, which prevents external access. This command restores the setting and restarts the service.

3. Update and restart Open_WebUI
  ```
  make update-open-webui
  ```

