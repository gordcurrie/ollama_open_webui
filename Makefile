# Makefile

# Define paths to your scripts
RESTART_OLLAMA_SCRIPT = ollama.sh
UPDATE_OPEN_WEBUI_SCRIPT = open-webui.sh

# Default target (optional)
all: help

# Target to restart ollama service
restart-ollama:
	@echo "Restarting Ollama service..."
	@sh $(RESTART_OLLAMA_SCRIPT)

# Target to update open-webui container
update-open-webui:
	@echo "Updating open-webui container..."
	@sh $(UPDATE_OPEN_WEBUI_SCRIPT)

# Help target to display available commands
help:
	@echo "Available commands:"
	@echo "  make restart-ollama      - Restart Ollama service"
	@echo "  make update-open-webui   - Update and run the open-webui container"

.PHONY: all restart-ollama update-open-webui help
