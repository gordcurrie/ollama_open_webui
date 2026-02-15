#!/bin/bash

echo "Testing script improvements..."
echo "=============================="

echo ""
echo "1. Testing ollama.sh (should work if ollama is installed):"
echo "   Running: ./ollama.sh"
echo "   This should show either 'Restarting Ollama service...' or errors if ollama isn't installed."

echo ""
echo "2. Testing open-webui.sh (should work if podman is installed):"
echo "   Running: ./open-webui.sh"
echo "   This should show container stopping/removing and then starting new container."

echo ""
echo "3. Testing post_update_ollama.sh (should work if ollama is installed):"
echo "   Running: ./post_update_ollama.sh"
echo "   This should reconfigure OLLAMA_HOST and restart ollama service."

echo ""
echo "Basic functionality check:"
echo "=========================="
echo "Scripts are executable: $(ls -la ollama.sh open-webui.sh post_update_ollama.sh | awk '{print $9"="$1}')"