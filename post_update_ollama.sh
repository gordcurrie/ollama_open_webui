#!/usr/bin/env bash

# Script to configure OLLAMA_HOST environment variable for the Ollama native macOS app.
# Creates a persistent LaunchAgent that sets OLLAMA_HOST=0.0.0.0 at login so it
# survives app updates (which manage themselves via the built-in auto-updater).
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

# Check if the Ollama native app is installed
OLLAMA_APP="/Applications/Ollama.app"
OLLAMA_BIN="/usr/local/bin/ollama"

if [ ! -d "$OLLAMA_APP" ]; then
    log_error "ERROR: Ollama native app not found at $OLLAMA_APP"
    log_error "Please install Ollama from https://ollama.com/download"
    exit 1
fi

if [ ! -x "$OLLAMA_BIN" ]; then
    log_error "ERROR: Ollama CLI not found at $OLLAMA_BIN"
    exit 1
fi

OLLAMA_VERSION=$("$OLLAMA_BIN" --version 2>/dev/null | head -1)
if [ -n "$OLLAMA_VERSION" ]; then
    log "INFO: $OLLAMA_VERSION installed"
fi

# Clean up leftover Homebrew LaunchAgent if present
BREW_PLIST="$HOME/Library/LaunchAgents/homebrew.mxcl.ollama.plist"
if [ -f "$BREW_PLIST" ]; then
    log "INFO: Removing leftover Homebrew LaunchAgent..."
    launchctl unload "$BREW_PLIST" 2>/dev/null
    rm -f "$BREW_PLIST"
    log "SUCCESS: Removed $BREW_PLIST"
fi

# Create a LaunchAgent that persistently sets OLLAMA_HOST via launchctl setenv at login.
# This ensures the env var is present in the launchd user session before Ollama starts,
# and survives reboots and app updates.
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
LAUNCH_AGENT_PLIST="$LAUNCH_AGENT_DIR/com.ollama.environment.plist"

log "INFO: Configuring OLLAMA_HOST environment variable..."
mkdir -p "$LAUNCH_AGENT_DIR"

cat > "$LAUNCH_AGENT_PLIST" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ollama.environment</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/launchctl</string>
        <string>setenv</string>
        <string>OLLAMA_HOST</string>
        <string>0.0.0.0</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

if [ $? -ne 0 ]; then
    log_error "ERROR: Failed to write LaunchAgent plist to $LAUNCH_AGENT_PLIST"
    exit 1
fi

log "SUCCESS: Wrote LaunchAgent to $LAUNCH_AGENT_PLIST"

# Reload the LaunchAgent so the env var is applied immediately without a reboot
launchctl unload "$LAUNCH_AGENT_PLIST" 2>/dev/null
if launchctl load "$LAUNCH_AGENT_PLIST" 2>/dev/null; then
    log "SUCCESS: LaunchAgent loaded"
else
    log_error "ERROR: Failed to load LaunchAgent"
    exit 1
fi

# Apply immediately to the current launchd session so Ollama picks it up on restart
launchctl setenv OLLAMA_HOST 0.0.0.0
log "SUCCESS: OLLAMA_HOST=0.0.0.0 set in current launchd session"

# Restart the Ollama app so it picks up the new environment variable
log "INFO: Restarting Ollama app..."
if pgrep -x "Ollama" >/dev/null 2>&1; then
    osascript -e 'quit app "Ollama"' 2>/dev/null || killall Ollama 2>/dev/null
    sleep 2
fi

if open -a Ollama 2>/dev/null; then
    log "SUCCESS: Ollama app restarted"
else
    log_error "ERROR: Failed to start Ollama app"
    exit 1
fi

log "=== Ollama Post-Update Configuration Complete ==="
