#!/bin/bash

# Social-DL Installer
# Installiert social-dl systemweit oder lokal für den aktuellen User
# Version: 1.1

set -o errexit
set -o nounset
set -o pipefail

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Icons (Emojis für besseres visuelles Feedback)
ICON_CHECK="✓"
ICON_CROSS="✗"
ICON_INFO="ℹ"
ICON_WARN="⚠"
ICON_ROCKET="🚀"
ICON_PACKAGE="📦"
ICON_SPARKLES="✨"

# Variablen
SCRIPT_NAME="social-dl"
TEMP_DIR="/tmp/social-dl-install-$$"

# Helper-Funktionen
print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════╗"
    echo "║                                        ║"
    echo "║     ${ICON_PACKAGE} Social-DL Installer v1.1     ║"
    echo "║                                        ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}${ICON_CHECK}${NC} $1"
}

print_error() {
    echo -e "${RED}${ICON_CROSS}${NC} $1" >&2
}

print_info() {
    echo -e "${BLUE}${ICON_INFO}${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}${ICON_WARN}${NC} $1"
}

print_step() {
    echo -e "${CYAN}${1}${NC}"
}

confirm() {
    local prompt="$1"
    local default="${2:-N}"

    if [[ "$default" == "Y" ]]; then
        read -r -p "$(echo -e ${BLUE}${prompt}${NC}) (J/n) " -n 1
    else
        read -r -p "$(echo -e ${BLUE}${prompt}${NC}) (j/N) " -n 1
    fi

    echo

    if [[ "$default" == "Y" ]]; then
        [[ ! "$REPLY" =~ ^[Nn]$ ]]
    else
        [[ "$REPLY" =~ ^[JjYy]$ ]]
    fi
}

cleanup() {
    rm -rf "$TEMP_DIR" 2>/dev/null || true
}
trap cleanup EXIT

show_progress() {
    local text="$1"
    echo -n -e "${CYAN}  ${text}...${NC} "
}

show_progress_done() {
    echo -e "${GREEN}${ICON_CHECK}${NC}"
}

check_dependencies() {
    local missing=()

    print_step "${ICON_PACKAGE} Prüfe Abhängigkeiten..."
    echo ""

    # Pflicht-Tools
    for tool in yt-dlp timeout; do
        show_progress "Prüfe $tool"
        if command -v "$tool" >/dev/null 2>&1; then
            show_progress_done
        else
            echo -e "${RED}${ICON_CROSS}${NC}"
            missing+=("$tool")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        echo ""
        print_error "Fehlende Abhängigkeiten: ${missing[*]}"
        echo ""
        echo -e "${YELLOW}Installationsanleitung:${NC}"
        echo ""

        # Distro-spezifische Anleitungen
        if [ -f /etc/debian_version ]; then
            echo "  ${CYAN}Debian/Ubuntu/Mint:${NC}"
            echo "    sudo apt update"
            echo "    sudo apt install yt-dlp"
        elif [ -f /etc/arch-release ]; then
            echo "  ${CYAN}Arch/Manjaro/CachyOS:${NC}"
            echo "    sudo pacman -S yt-dlp"
        elif [ -f /etc/fedora-release ]; then
            echo "  ${CYAN}Fedora:${NC}"
            echo "    sudo dnf install yt-dlp"
        elif [ -f /etc/opensuse-release ]; then
            echo "  ${CYAN}openSUSE:${NC}"
            echo "    sudo zypper install yt-dlp"
        else
            echo "  ${CYAN}Universal (pip):${NC}"
            echo "    python3 -m pip install --user yt-dlp"
        fi

        echo ""
        return 1
    fi

    echo ""
    print_success "Alle Pflicht-Abhängigkeiten gefunden"

    # Optionale Tools prüfen
    echo ""
    print_step "${ICON_SPARKLES} Optionale Tools:"
    echo ""

    local optional_tools=(
        "xclip:Clipboard-Support (X11)"
        "wl-paste:Clipboard-Support (Wayland)"
        "notify-send:Desktop-Benachrichtigungen"
        "shotcut:Video-Bearbeitung"
    )

    for tool_desc in "${optional_tools[@]}"; do
        IFS=':' read -r tool desc <<< "$tool_desc"
        show_progress "$desc"
        if command -v "$tool" >/dev/null 2>&1; then
            show_progress_done
        else
            echo -e "${YELLOW}${ICON_WARN}${NC} (optional)"
        fi
    done

    echo ""
    return 0
}

install_system() {
    print_step "${ICON_ROCKET} Systemweite Installation..."
    echo ""

    # Prüfe Root-Rechte
    if [ "$EUID" -ne 0 ]; then
        print_error "Systemweite Installation benötigt Root-Rechte!"
        echo ""
        echo "Bitte führe aus:"
        echo -e "  ${CYAN}sudo $0${NC}"
        echo ""
        echo "Oder wähle lokale Installation (nur für aktuellen User)."
        return 1
    fi

    # Kopiere Script
    local target="/usr/local/bin/$SCRIPT_NAME"
    show_progress "Kopiere Script nach $target"
    cp "$TEMP_DIR/$SCRIPT_NAME" "$target"
    chmod +x "$target"
    show_progress_done

    # Desktop Entry automatisch erstellen
    show_progress "Erstelle Desktop-Eintrag"
    local desktop_file="/usr/share/applications/$SCRIPT_NAME.desktop"
    cat > "$desktop_file" << EOF
[Desktop Entry]
Name=Social Media Downloader
Comment=Download videos/audio from Instagram, YouTube, Twitter, Reddit, TikTok
Exec=/usr/local/bin/$SCRIPT_NAME
Icon=browser-download
Terminal=true
Type=Application
Categories=Network;AudioVideo;
Keywords=download;video;instagram;youtube;twitter;reddit;tiktok;
EOF
    chmod 644 "$desktop_file"
    show_progress_done

    echo ""
    print_success "Systemweite Installation abgeschlossen!"
    echo ""
    echo -e "${CYAN}Nutzung:${NC}"
    echo -e "  ${GREEN}$SCRIPT_NAME${NC}                    # Clipboard-URL verwenden"
    echo -e "  ${GREEN}$SCRIPT_NAME <URL>${NC}              # Direkte URL"
    echo -e "  ${GREEN}$SCRIPT_NAME --help${NC}             # Hilfe anzeigen"
}

install_local() {
    print_step "${ICON_ROCKET} Lokale Installation (nur für $USER)..."
    echo ""

    # Erstelle lokales bin-Verzeichnis
    local local_bin="$HOME/.local/bin"
    show_progress "Erstelle $local_bin"
    mkdir -p "$local_bin"
    show_progress_done

    # Kopiere Script
    local target="$local_bin/$SCRIPT_NAME"
    show_progress "Kopiere Script"
    cp "$TEMP_DIR/$SCRIPT_NAME" "$target"
    chmod +x "$target"
    show_progress_done

    # Desktop Entry automatisch erstellen
    show_progress "Erstelle Desktop-Eintrag"
    local desktop_dir="$HOME/.local/share/applications"
    mkdir -p "$desktop_dir"
    local desktop_file="$desktop_dir/$SCRIPT_NAME.desktop"
    cat > "$desktop_file" << EOF
[Desktop Entry]
Name=Social Media Downloader
Comment=Download videos/audio from Instagram, YouTube, Twitter, Reddit, TikTok
Exec=$HOME/.local/bin/$SCRIPT_NAME
Icon=browser-download
Terminal=true
Type=Application
Categories=Network;AudioVideo;
Keywords=download;video;instagram;youtube;twitter;reddit;tiktok;
EOF
    chmod 644 "$desktop_file"
    show_progress_done

    # Prüfe und konfiguriere PATH automatisch
    if [[ ":$PATH:" != *":$local_bin:"* ]]; then
        echo ""
        print_warning "~/.local/bin ist nicht im PATH!"
        echo ""

        # Erkenne Shell und füge PATH automatisch hinzu
        CURRENT_SHELL=$(basename "$SHELL")

        case "$CURRENT_SHELL" in
            fish)
                show_progress "Konfiguriere PATH für Fish Shell"
                if command -v fish >/dev/null 2>&1; then
                    fish -c "fish_add_path ~/.local/bin" 2>/dev/null || true
                    show_progress_done
                    echo ""
                    print_success "PATH automatisch konfiguriert!"
                    echo ""
                    echo -e "${CYAN}Starte ein neues Terminal oder führe aus:${NC}"
                    echo -e "  ${GREEN}exec fish${NC}"
                fi
                ;;
            zsh)
                show_progress "Konfiguriere PATH für Zsh"
                if ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$HOME/.zshrc" 2>/dev/null; then
                    echo '' >> "$HOME/.zshrc"
                    echo '# Added by social-dl installer' >> "$HOME/.zshrc"
                    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
                    show_progress_done
                    echo ""
                    print_success "PATH zu ~/.zshrc hinzugefügt!"
                    echo ""
                    echo -e "${CYAN}Führe aus:${NC}"
                    echo -e "  ${GREEN}source ~/.zshrc${NC}"
                else
                    echo -e "${GREEN}${ICON_CHECK}${NC} (bereits konfiguriert)"
                fi
                ;;
            bash)
                show_progress "Konfiguriere PATH für Bash"
                if ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$HOME/.bashrc" 2>/dev/null; then
                    echo '' >> "$HOME/.bashrc"
                    echo '# Added by social-dl installer' >> "$HOME/.bashrc"
                    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
                    show_progress_done
                    echo ""
                    print_success "PATH zu ~/.bashrc hinzugefügt!"
                    echo ""
                    echo -e "${CYAN}Führe aus:${NC}"
                    echo -e "  ${GREEN}source ~/.bashrc${NC}"
                else
                    echo -e "${GREEN}${ICON_CHECK}${NC} (bereits konfiguriert)"
                fi
                ;;
            *)
                echo ""
                print_warning "Shell '$CURRENT_SHELL' nicht automatisch konfigurierbar"
                echo ""
                echo "Füge manuell zu deiner Shell-Config hinzu:"
                echo -e "  ${CYAN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
                echo ""
                ;;
        esac
    else
        show_progress "Prüfe PATH"
        show_progress_done
    fi

    echo ""
    print_success "Lokale Installation abgeschlossen!"
    echo ""
    echo -e "${CYAN}Nutzung:${NC}"
    echo -e "  ${GREEN}$SCRIPT_NAME${NC}                    # Clipboard-URL verwenden"
    echo -e "  ${GREEN}$SCRIPT_NAME <URL>${NC}              # Direkte URL"
    echo -e "  ${GREEN}$SCRIPT_NAME --help${NC}             # Hilfe anzeigen"
}

post_install_test() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""

    if confirm "Möchtest du einen Test-Download durchführen?" "N"; then
        echo ""
        print_info "Starte Test mit Rick Astley - Never Gonna Give You Up..."
        echo ""

        # Test mit bekanntem Video
        if command -v $SCRIPT_NAME >/dev/null 2>&1; then
            $SCRIPT_NAME "https://www.youtube.com/watch?v=dQw4w9WgXcQ" || true
        else
            print_warning "Script noch nicht im PATH. Starte neues Terminal und versuche erneut."
        fi
    fi
}

uninstall() {
    print_step "${ICON_PACKAGE} Deinstallation..."
    echo ""

    local removed=0

    # System-Installation
    if [ -f "/usr/local/bin/$SCRIPT_NAME" ]; then
        if [ "$EUID" -ne 0 ]; then
            print_error "Systemweite Deinstallation benötigt Root-Rechte!"
            echo -e "Führe aus: ${CYAN}sudo $0 --uninstall${NC}"
            return 1
        fi
        show_progress "Entferne systemweite Installation"
        rm -f "/usr/local/bin/$SCRIPT_NAME"
        rm -f "/usr/share/applications/$SCRIPT_NAME.desktop"
        show_progress_done
        removed=1
    fi

    # Lokale Installation
    if [ -f "$HOME/.local/bin/$SCRIPT_NAME" ]; then
        show_progress "Entferne lokale Installation"
        rm -f "$HOME/.local/bin/$SCRIPT_NAME"
        rm -f "$HOME/.local/share/applications/$SCRIPT_NAME.desktop"
        show_progress_done
        removed=1
    fi

    if [ $removed -eq 0 ]; then
        print_warning "Keine Installation gefunden"
    else
        echo ""
        if confirm "Auch Konfiguration und Logs löschen?" "N"; then
            show_progress "Lösche Logs"
            rm -f "$HOME/.social-dl.log"*
            show_progress_done
        fi

        echo ""
        print_success "Deinstallation abgeschlossen!"
    fi
}

# Main Installation
main() {
    print_header

    # Uninstall-Modus
    if [[ "${1:-}" == "--uninstall" || "${1:-}" == "-u" ]]; then
        uninstall
        exit 0
    fi

    # Dependencies prüfen
    if ! check_dependencies; then
        exit 1
    fi

    # Temp-Verzeichnis erstellen
    mkdir -p "$TEMP_DIR"

    # Script holen (aus aktuellem Verzeichnis)
    if [ -f "./social-dl.sh" ]; then
        print_info "Verwende social-dl.sh aus aktuellem Verzeichnis"
        cp "./social-dl.sh" "$TEMP_DIR/$SCRIPT_NAME"
    elif [ -f "./$SCRIPT_NAME" ]; then
        print_info "Verwende $SCRIPT_NAME aus aktuellem Verzeichnis"
        cp "./$SCRIPT_NAME" "$TEMP_DIR/$SCRIPT_NAME"
    else
        print_error "social-dl.sh nicht gefunden!"
        echo ""
        echo "Bitte führe den Installer im selben Verzeichnis wie social-dl.sh aus."
        exit 1
    fi

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""

    # Installationstyp wählen
    echo -e "${CYAN}Installationstyp wählen:${NC}"
    echo ""
    echo -e "  ${GREEN}[1]${NC} Systemweit (alle User, benötigt sudo)"
    echo -e "  ${GREEN}[2]${NC} Lokal (nur für $USER, ${YELLOW}empfohlen${NC})"
    echo ""
    read -r -p "Auswahl [1-2]: " -n 1 INSTALL_CHOICE
    echo ""

    case "$INSTALL_CHOICE" in
        1)
            if ! install_system; then
                exit 1
            fi
            ;;
        2)
            if ! install_local; then
                exit 1
            fi
            ;;
        *)
            print_error "Ungültige Auswahl"
            exit 1
            ;;
    esac

    # Post-Install Test anbieten
    post_install_test

    # Finaler Success-Screen
    echo ""
    echo -e "${GREEN}${ICON_SPARKLES}═══════════════════════════════════════${ICON_SPARKLES}${NC}"
    echo -e "${GREEN}${ICON_SPARKLES}  Installation erfolgreich!            ${ICON_SPARKLES}${NC}"
    echo -e "${GREEN}${ICON_SPARKLES}═══════════════════════════════════════${ICON_SPARKLES}${NC}"
    echo ""
    print_info "Teste die Installation mit:"
    echo -e "  ${GREEN}$SCRIPT_NAME --help${NC}"
    echo ""
    print_info "Oder kopiere eine URL und führe aus:"
    echo -e "  ${GREEN}$SCRIPT_NAME${NC}"
    echo ""
}

# Script starten
main "$@"
