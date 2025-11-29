#!/bin/sh

# After updating Ollama via Homebrew, the OLLAMA_HOST environment variable
# gets removed from the plist file, which prevents external access to Ollama.
# This script re-adds/updates the OLLAMA_HOST setting and restarts the service.

PLIST_PATH="$(brew --prefix)/opt/ollama/homebrew.mxcl.ollama.plist"

echo "Configuring OLLAMA_HOST environment variable..."

# Try to set the value (works for both existing and new entries)
if /usr/libexec/PlistBuddy -c "Set EnvironmentVariables:OLLAMA_HOST 0.0.0.0" "$PLIST_PATH" 2>/dev/null; then
    echo "✓ Updated existing OLLAMA_HOST to 0.0.0.0"
else
    /usr/libexec/PlistBuddy -c "Add EnvironmentVariables:OLLAMA_HOST string 0.0.0.0" "$PLIST_PATH"
    echo "✓ Added OLLAMA_HOST=0.0.0.0"
fi

echo "Restarting Ollama service..."
brew services restart ollama
echo "✓ Ollama service restarted"
