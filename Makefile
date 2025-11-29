# Makefile

# Define paths to your scripts
RESTART_OLLAMA_SCRIPT = ollama.sh
UPDATE_OPEN_WEBUI_SCRIPT = open-webui.sh
OLLAMA_POST_UPDATE_SCRIPT = post_update_ollama.sh

# Default target (optional)
all: help

# Target to restart ollama service
restart-ollama:
	@echo "Restarting Ollama service..."
	@sh $(RESTART_OLLAMA_SCRIPT)

ollama-post-update:
	@echo "Running post update script"
	@sh $(OLLAMA_POST_UPDATE_SCRIPT)

# Target to update open-webui container
update-open-webui:
	@echo "Updating open-webui container..."
	@sh $(UPDATE_OPEN_WEBUI_SCRIPT)

# Help target to display available commands
help:
	@echo "Available commands:"
	@echo "  make restart-ollama      - Restart Ollama service"
	@echo "  make ollama-post-update  - Run Ollama post-update script"
	@echo "  make update-open-webui   - Update and run the open-webui container"

.PHONY: all restart-ollama ollama-post-update update-open-webui help
