#!/usr/bin/env bash

# Script to update and restart Open-WebUI container
# Usage: ./open-webui.sh

# Set up basic logging
LOG_TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
LOG_FILE="/tmp/open-webui-script-${LOG_TIMESTAMP}.log"
# Clean up old log files (older than 7 days)
find /tmp -maxdepth 1 -type f -name 'open-webui-script-*.log' -mtime +7 -delete >/dev/null 2>&1
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Open-WebUI Container Update ==="
echo "Starting Open-WebUI update at $(date)"

# Check if podman is installed
if ! command -v podman >/dev/null 2>&1; then
    echo "ERROR: Podman is not installed. Please install Podman first."
    exit 1
fi

# Display podman version for informational purposes
PODMAN_VERSION=$(podman --version 2>/dev/null | cut -d' ' -f3)
if [ -n "$PODMAN_VERSION" ]; then
    echo "INFO: Podman version $PODMAN_VERSION installed"
fi

# Stop and remove existing container if it exists
echo "INFO: Stopping Open-WebUI container..."
if podman stop open-webui >/dev/null 2>&1; then
    echo "SUCCESS: Container stopped successfully"
else
    echo "INFO: No running container to stop"
fi

echo "INFO: Removing Open-WebUI container..."
if podman rm open-webui >/dev/null 2>&1; then
    echo "SUCCESS: Container removed successfully"
else
    echo "INFO: No container to remove"
fi

# Remove existing image(s) if they exist
echo "INFO: Checking for existing image..."
IMAGE_IDS=$(podman images -q 'ghcr.io/open-webui/open-webui')

if [ -n "$IMAGE_IDS" ]; then
    echo "INFO: Removing existing image(s)..."
    if echo "$IMAGE_IDS" | xargs podman rmi >/dev/null 2>&1; then
        echo "SUCCESS: Image(s) removed successfully"
    else
        echo "WARNING: Failed to remove image(s)"
    fi
else
    echo "INFO: No existing image found"
fi

# Pull and run the updated container
echo "INFO: Pulling and running updated container..."
if podman run -d -p 3000:8080 -v open-webui:/app/backend/data --name open-webui --restart always --pull=always ghcr.io/open-webui/open-webui:latest; then
    echo "SUCCESS: Open-WebUI container started successfully"
else
    echo "ERROR: Failed to start Open-WebUI container"
    exit 1
fi

echo "=== Open-WebUI Container Update Complete ==="
