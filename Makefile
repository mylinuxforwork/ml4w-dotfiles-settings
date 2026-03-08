PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
LIBDIR = $(PREFIX)/lib/ml4w-dotfiles-settings
DEMODIR = $(PREFIX)/share/ml4w-dotfiles-settings/demo

install:
	@echo "Installing ml4w-dotfiles-settings..."
	install -d $(BINDIR)
	install -d $(LIBDIR)
	install -d $(DEMODIR)
	install -m 755 bin/ml4w-dotfiles-settings $(BINDIR)/ml4w-dotfiles-settings
	install -m 644 lib/utils.sh $(LIBDIR)/utils.sh
	install -m 644 demo/settings.json $(DEMODIR)/settings.json
	
	@# Patch script to point to global lib and demo directories during install
	sed -i 's|APP_DIR=.*|APP_DIR="$(PREFIX)/share/ml4w-dotfiles-settings"|' $(BINDIR)/ml4w-dotfiles-settings
	sed -i 's|LIB_FILE=.*|LIB_FILE="$(LIBDIR)/utils.sh"|' $(BINDIR)/ml4w-dotfiles-settings
	sed -i 's|DEMO_FILE=.*|DEMO_FILE="$(DEMODIR)/settings.json"|' $(BINDIR)/ml4w-dotfiles-settings
	
	@echo "Installation complete."

uninstall:
	@echo "Uninstalling ml4w-dotfiles-settings..."
	rm -f $(BINDIR)/ml4w-dotfiles-settings
	rm -rf $(LIBDIR)
	rm -rf $(DEMODIR)
	@echo "Uninstallation complete."