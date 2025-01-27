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
  chmod +x ollama.sh open-webui.sh
  ```

## Usage

1. Restart Ollama service
  ```
  make restart-ollama
  ```

2. Update and restart Open_WebUI
  ```
  make restart-open-webui
  ```

