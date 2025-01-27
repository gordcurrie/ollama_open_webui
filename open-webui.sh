#!/bin/sh

echo "Stopping open-webui..."
podman stop open-webui

echo "Removing open-webui container..."
podman rm open-webui

IMAGE_ID=$(podman images | grep 'ghcr.io/open-webui/open-webui' | awk '{print $3}')

if [ -z "$IMAGE_ID" ]; then
  echo "No image found for ghcr.io/open-webui/open-webui"
else
  # Remove the podman image
  podman rmi "$IMAGE_ID"
  if [ $? -eq 0 ]; then
    echo "Image with ID $IMAGE_ID has been removed."
  else
    echo "Failed to remove image with ID $IMAGE_ID."
  fi
fi

echo "Pulling and running updated container"
podman run -d -p 3000:8080 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
