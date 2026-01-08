# Makefile for Social-DL
# Simple installation system for cross-distribution compatibility

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
DESKTOPDIR = $(PREFIX)/share/applications

SCRIPT_NAME = social-dl
SCRIPT_SOURCE = social-dl.sh
DESKTOP_FILE = social-dl.desktop

# Farben für Output
GREEN = \033[0;32m
BLUE = \033[0;34m
YELLOW = \033[1;33m
NC = \033[0m

.PHONY: all help install install-local uninstall uninstall-local check clean

all: help

help:
	@echo "$(BLUE)Social-DL Makefile$(NC)"
	@echo ""
	@echo "Verfügbare Targets:"
	@echo "  $(GREEN)make install$(NC)         - Systemweite Installation (benötigt sudo)"
	@echo "  $(GREEN)make install-local$(NC)   - Lokale Installation (nur aktueller User)"
	@echo "  $(GREEN)make uninstall$(NC)       - Systemweite Deinstallation"
	@echo "  $(GREEN)make uninstall-local$(NC) - Lokale Deinstallation"
	@echo "  $(GREEN)make check$(NC)           - Abhängigkeiten prüfen"
	@echo "  $(GREEN)make clean$(NC)           - Temporäre Dateien löschen"
	@echo ""
	@echo "Beispiele:"
	@echo "  sudo make install              # System-Installation"
	@echo "  make install-local             # User-Installation"
	@echo "  PREFIX=~/.local make install   # Custom-Pfad"

check:
	@echo "$(BLUE)Prüfe Abhängigkeiten...$(NC)"
	@command -v yt-dlp >/dev/null 2>&1 || { echo "$(YELLOW)⚠ yt-dlp nicht gefunden$(NC)"; exit 1; }
	@echo "$(GREEN)✓ yt-dlp gefunden$(NC)"
	@command -v timeout >/dev/null 2>&1 || { echo "$(YELLOW)⚠ timeout nicht gefunden$(NC)"; exit 1; }
	@echo "$(GREEN)✓ timeout gefunden$(NC)"
	@echo ""
	@echo "Optionale Tools:"
	@command -v xclip >/dev/null 2>&1 && echo "$(GREEN)✓ xclip$(NC)" || echo "$(YELLOW)⚠ xclip nicht gefunden (Clipboard-Support)$(NC)"
	@command -v wl-paste >/dev/null 2>&1 && echo "$(GREEN)✓ wl-paste$(NC)" || echo "$(YELLOW)⚠ wl-paste nicht gefunden (Wayland-Clipboard)$(NC)"
	@command -v notify-send >/dev/null 2>&1 && echo "$(GREEN)✓ notify-send$(NC)" || echo "$(YELLOW)⚠ notify-send nicht gefunden (Benachrichtigungen)$(NC)"
	@command -v shotcut >/dev/null 2>&1 && echo "$(GREEN)✓ shotcut$(NC)" || echo "$(YELLOW)⚠ shotcut nicht gefunden (Video-Bearbeitung)$(NC)"

install: check
	@echo "$(BLUE)Installiere social-dl systemweit...$(NC)"
	@if [ ! -f "$(SCRIPT_SOURCE)" ]; then \
		echo "$(YELLOW)Fehler: $(SCRIPT_SOURCE) nicht gefunden!$(NC)"; \
		exit 1; \
	fi
	@mkdir -p $(DESTDIR)$(BINDIR)
	@install -m 755 $(SCRIPT_SOURCE) $(DESTDIR)$(BINDIR)/$(SCRIPT_NAME)
	@echo "$(GREEN)✓ Script installiert: $(BINDIR)/$(SCRIPT_NAME)$(NC)"
	@if [ -f "$(DESKTOP_FILE)" ]; then \
		mkdir -p $(DESTDIR)$(DESKTOPDIR); \
		install -m 644 $(DESKTOP_FILE) $(DESTDIR)$(DESKTOPDIR)/$(DESKTOP_FILE); \
		echo "$(GREEN)✓ Desktop-Entry installiert$(NC)"; \
	fi
	@echo ""
	@echo "$(GREEN)Installation erfolgreich!$(NC)"
	@echo "Nutzung: $(SCRIPT_NAME) --help"

install-local: check
	@echo "$(BLUE)Installiere social-dl lokal (nur für $$USER)...$(NC)"
	@if [ ! -f "$(SCRIPT_SOURCE)" ]; then \
		echo "$(YELLOW)Fehler: $(SCRIPT_SOURCE) nicht gefunden!$(NC)"; \
		exit 1; \
	fi
	@mkdir -p $$HOME/.local/bin
	@install -m 755 $(SCRIPT_SOURCE) $$HOME/.local/bin/$(SCRIPT_NAME)
	@echo "$(GREEN)✓ Script installiert: $$HOME/.local/bin/$(SCRIPT_NAME)$(NC)"
	@if [ -f "$(DESKTOP_FILE)" ]; then \
		mkdir -p $$HOME/.local/share/applications; \
		install -m 644 $(DESKTOP_FILE) $$HOME/.local/share/applications/$(DESKTOP_FILE); \
		echo "$(GREEN)✓ Desktop-Entry installiert$(NC)"; \
	fi
	@echo ""
	@if ! echo $$PATH | grep -q "$$HOME/.local/bin"; then \
		echo "$(YELLOW)⚠ $$HOME/.local/bin ist nicht im PATH!$(NC)"; \
		echo ""; \
		echo "Füge zu ~/.bashrc hinzu:"; \
		echo "  export PATH=\"\$$HOME/.local/bin:\$$PATH\""; \
		echo ""; \
		echo "Dann: source ~/.bashrc"; \
		echo ""; \
	fi
	@echo "$(GREEN)Installation erfolgreich!$(NC)"
	@echo "Nutzung: $(SCRIPT_NAME) --help"

uninstall:
	@echo "$(BLUE)Deinstalliere social-dl (systemweit)...$(NC)"
	@rm -f $(DESTDIR)$(BINDIR)/$(SCRIPT_NAME)
	@rm -f $(DESTDIR)$(DESKTOPDIR)/$(DESKTOP_FILE)
	@echo "$(GREEN)✓ Deinstallation abgeschlossen$(NC)"

uninstall-local:
	@echo "$(BLUE)Deinstalliere social-dl (lokal)...$(NC)"
	@rm -f $$HOME/.local/bin/$(SCRIPT_NAME)
	@rm -f $$HOME/.local/share/applications/$(DESKTOP_FILE)
	@echo "$(GREEN)✓ Deinstallation abgeschlossen$(NC)"
	@echo ""
	@read -p "Auch Logs löschen ($$HOME/.social-dl.log*)? [j/N] " answer; \
	if [ "$$answer" = "j" ] || [ "$$answer" = "J" ]; then \
		rm -f $$HOME/.social-dl.log*; \
		echo "$(GREEN)✓ Logs gelöscht$(NC)"; \
	fi

clean:
	@echo "$(BLUE)Räume temporäre Dateien auf...$(NC)"
	@rm -f *~ *.bak
	@echo "$(GREEN)✓ Fertig$(NC)"
