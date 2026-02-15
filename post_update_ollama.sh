#!/bin/bash

# Script to configure OLLAMA_HOST environment variable after Ollama updates
# This resolves an issue where Homebrew updates remove the OLLAMA_HOST variable
# Usage: ./post_update_ollama.sh

# Set up basic logging
LOG_FILE="/tmp/post-update-ollama-script.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Ollama Post-Update Configuration ==="
echo "Starting Ollama post-update configuration at $(date)"

# Check if brew is installed
if ! command -v brew >/dev/null 2>&1; then
    echo "ERROR: Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

# Check brew version (minimum recommended version)
BREW_VERSION=$(brew --version 2>/dev/null | head -1 | cut -d' ' -f2)
if [ -n "$BREW_VERSION" ]; then
    echo "INFO: Homebrew version $BREW_VERSION installed"
fi

# Check if ollama is installed
if ! brew list | grep -q ollama; then
    echo "ERROR: Ollama is not installed via Homebrew."
    exit 1
fi

# Get the plist path
PLIST_PATH="$(brew --prefix)/opt/ollama/homebrew.mxcl.ollama.plist"

# Verify the plist file exists
if [ ! -f "$PLIST_PATH" ]; then
    echo "ERROR: Ollama plist file not found at $PLIST_PATH"
    exit 1
fi

echo "INFO: Configuring OLLAMA_HOST environment variable..."

# Try to set the value (works for both existing and new entries)
if /usr/libexec/PlistBuddy -c "Set EnvironmentVariables:OLLAMA_HOST 0.0.0.0" "$PLIST_PATH" 2>/dev/null; then
    echo "SUCCESS: Updated existing OLLAMA_HOST to 0.0.0.0"
else
    # If the key doesn't exist, add it
    if /usr/libexec/PlistBuddy -c "Add EnvironmentVariables:OLLAMA_HOST string 0.0.0.0" "$PLIST_PATH" 2>/dev/null; then
        echo "SUCCESS: Added OLLAMA_HOST=0.0.0.0"
    else
        echo "ERROR: Failed to configure OLLAMA_HOST environment variable"
        exit 1
    fi
fi

echo "INFO: Restarting Ollama service..."
if brew services restart ollama; then
    echo "SUCCESS: Ollama service restarted successfully"
else
    echo "ERROR: Failed to restart Ollama service"
    exit 1
fi

echo "=== Ollama Post-Update Configuration Complete ==="
