# Variables
BIN_DIR = $(HOME)/.local/bin
LIB_DIR = $(HOME)/.local/share/ml4w-dotfiles-settings

install:
	@echo "Installing ml4w-dotfiles-settings..."
	mkdir -p $(BIN_DIR)
	mkdir -p $(LIB_DIR)
	
	@echo "Installing binary..."
	install -m 755 bin/ml4w-dotfiles-settings $(BIN_DIR)/
	
	@echo "Installing libraries..."
	cp -r lib/* $(LIB_DIR)/
	@echo "Done! Make sure $(BIN_DIR) is in your PATH."

uninstall:
	rm -f $(BIN_DIR)/ml4w-dotfiles-settings
	rm -rf $(LIB_DIR)
	@echo "Removed ml4w-dotfiles-settings."
