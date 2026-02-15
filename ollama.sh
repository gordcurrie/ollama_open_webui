#!/usr/bin/env bash

# Script to restart Ollama service
# Usage: ./ollama.sh

# Set up basic logging
LOG_TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
LOG_FILE="/tmp/ollama-script-${LOG_TIMESTAMP}.log"
# Clean up old log files (older than 7 days)
find /tmp -maxdepth 1 -type f -name 'ollama-script-*.log' -mtime +7 -delete >/dev/null 2>&1
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Ollama Service Restart ==="
echo "Starting Ollama service restart at $(date)"

# Check if brew is installed
if ! command -v brew >/dev/null 2>&1; then
    echo "ERROR: Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

# Log brew version for informational purposes
BREW_VERSION=$(brew --version 2>/dev/null | head -1 | cut -d' ' -f2)
if [ -n "$BREW_VERSION" ]; then
    echo "INFO: Homebrew version $BREW_VERSION installed"
fi

# Check if ollama service is installed
if ! brew services list | grep -q ollama; then
    echo "ERROR: Ollama service is not installed via Homebrew."
    exit 1
fi

# Restart the ollama service
echo "INFO: Restarting Ollama service..."
if brew services restart ollama; then
    echo "SUCCESS: Ollama service restarted successfully"
else
    echo "ERROR: Failed to restart Ollama service"
    exit 1
fi

echo "=== Ollama Service Restart Complete ==="
