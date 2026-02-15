#!/bin/bash

# Script to update and restart Open-WebUI container
# Usage: ./open-webui.sh

# Set up basic logging
LOG_FILE="/tmp/open-webui-script.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Open-WebUI Container Update ==="
echo "Starting Open-WebUI update at $(date)"

# Check if podman is installed
if ! command -v podman >/dev/null 2>&1; then
    echo "ERROR: Podman is not installed. Please install Podman first."
    exit 1
fi

# Check podman version (minimum recommended version)
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

# Remove existing image if it exists
echo "INFO: Checking for existing image..."
IMAGE_ID=$(podman images -q 'ghcr.io/open-webui/open-webui')

if [ -n "$IMAGE_ID" ]; then
    echo "INFO: Removing existing image..."
    if podman rmi "$IMAGE_ID" >/dev/null 2>&1; then
        echo "SUCCESS: Image removed successfully"
    else
        echo "WARNING: Failed to remove image"
    fi
else
    echo "INFO: No existing image found"
fi

# Pull and run the updated container
echo "INFO: Pulling and running updated container..."
if podman run -d -p 3000:8080 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main; then
    echo "SUCCESS: Open-WebUI container started successfully"
else
    echo "ERROR: Failed to start Open-WebUI container"
    exit 1
fi

echo "=== Open-WebUI Container Update Complete ==="
