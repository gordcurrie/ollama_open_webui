#!/usr/bin/env bash

# Script to configure OLLAMA_HOST environment variable after Ollama updates
# This resolves an issue where Homebrew updates remove the OLLAMA_HOST variable
# Usage: ./post_update_ollama.sh

# Set up basic logging
LOG_TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
LOG_FILE="/tmp/post-update-ollama-script-${LOG_TIMESTAMP}.log"
# Clean up old log files (older than 7 days)
find /tmp -maxdepth 1 -type f -name 'post-update-ollama-script-*.log' -mtime +7 -delete >/dev/null 2>&1

# Logging function used by this script
log() {
    printf '%s\n' "$*" | tee -a "$LOG_FILE"
}

log_error() {
    # Write to both stderr and log file
    printf '%s\n' "$*" >&2
    printf '%s\n' "$*" >> "$LOG_FILE"
}

log "=== Ollama Post-Update Configuration ==="
log "Starting Ollama post-update configuration at $(date)"

# Check if brew is installed
if ! command -v brew >/dev/null 2>&1; then
    log_error "ERROR: Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

# Display brew version for informational purposes
BREW_VERSION=$(brew --version 2>/dev/null | head -1 | cut -d' ' -f2)
if [ -n "$BREW_VERSION" ]; then
    log "INFO: Homebrew version $BREW_VERSION installed"
fi

# Check if ollama is installed
if ! brew list --formula ollama >/dev/null 2>&1; then
    log_error "ERROR: Ollama is not installed via Homebrew."
    exit 1
fi

# Get the plist path
PLIST_PATH="$(brew --prefix)/opt/ollama/homebrew.mxcl.ollama.plist"

# Verify the plist file exists
if [ ! -f "$PLIST_PATH" ]; then
    log_error "ERROR: Ollama plist file not found at $PLIST_PATH"
    exit 1
fi

log "INFO: Configuring OLLAMA_HOST environment variable..."

# Try to set the value (works for both existing and new entries)
if /usr/libexec/PlistBuddy -c "Set EnvironmentVariables:OLLAMA_HOST 0.0.0.0" "$PLIST_PATH" 2>/dev/null; then
    log "SUCCESS: Updated existing OLLAMA_HOST to 0.0.0.0"
else
    # If the key doesn't exist, add it
    if /usr/libexec/PlistBuddy -c "Add EnvironmentVariables:OLLAMA_HOST string 0.0.0.0" "$PLIST_PATH" 2>/dev/null; then
        log "SUCCESS: Added OLLAMA_HOST=0.0.0.0"
    else
        log_error "ERROR: Failed to configure OLLAMA_HOST environment variable"
        exit 1
    fi
fi

log "INFO: Restarting Ollama service..."
if brew services restart ollama; then
    log "SUCCESS: Ollama service restarted successfully"
else
    log_error "ERROR: Failed to restart Ollama service"
    exit 1
fi

log "=== Ollama Post-Update Configuration Complete ==="
