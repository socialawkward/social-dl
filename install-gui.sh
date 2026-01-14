#!/bin/bash

# Social-DL GUI Installer (Multilingual)
# Grafische Installation mit Zenity (kein Terminal nötig)
# Version: 1.2 (Security Fixes)

set -o errexit
set -o nounset
set -o pipefail

# Konstanten (hardcoded - nicht von User-Input abhängig)
readonly SCRIPT_NAME="social-dl"
readonly SCRIPT_SOURCE="social-dl.sh"
readonly VALID_LANGS="en de"

# Language Selection
select_language() {
    zenity --list \
        --title="Social-DL Installer - Language / Sprache" \
        --text="Please select your language / Bitte wähle deine Sprache:" \
        --radiolist \
        --column="☑" --column="Code" --column="Language / Sprache" \
        TRUE "en" "English" \
        FALSE "de" "Deutsch" \
        --width=550 --height=300
}

LANG_CHOICE=$(select_language)
if [ -z "$LANG_CHOICE" ]; then
    exit 0
fi

# SICHERHEIT: Validiere Sprachwahl (Whitelist)
validate_lang() {
    local lang="$1"
    for valid in $VALID_LANGS; do
        if [ "$lang" = "$valid" ]; then
            return 0
        fi
    done
    return 1
}

if ! validate_lang "$LANG_CHOICE"; then
    zenity --error --title="Error" --text="Invalid language selection!"
    exit 1
fi

# Set language for all subsequent operations
export SOCIAL_DL_LANG="$LANG_CHOICE"

# Translations
t() {
    local key="$1"
    case "$key" in
        "title") [ "$LANG_CHOICE" = "de" ] && echo "Social-DL Installer" || echo "Social-DL Installer" ;;
        "welcome_title") [ "$LANG_CHOICE" = "de" ] && echo "Willkommen!" || echo "Welcome!" ;;
        "welcome_text") [ "$LANG_CHOICE" = "de" ] && echo "Willkommen beim Social-DL Installer!\n\nDieses Tool installiert den Social Media Video/Audio Downloader.\n\n<b>Unterstützte Plattformen:</b>\n• Instagram\n• Twitter/X\n• YouTube\n• Reddit\n• TikTok\n\nMöchtest du fortfahren?" || echo "Welcome to the Social-DL Installer!\n\nThis tool installs the Social Media Video/Audio Downloader.\n\n<b>Supported platforms:</b>\n• Instagram\n• Twitter/X\n• YouTube\n• Reddit\n• TikTok\n\nDo you want to continue?" ;;
        "continue") [ "$LANG_CHOICE" = "de" ] && echo "Weiter" || echo "Continue" ;;
        "cancel") [ "$LANG_CHOICE" = "de" ] && echo "Abbrechen" || echo "Cancel" ;;
        "error_script_not_found") [ "$LANG_CHOICE" = "de" ] && echo "Fehler: $SCRIPT_SOURCE nicht gefunden!\n\nBitte führe den Installer im gleichen Ordner wie social-dl.sh aus." || echo "Error: $SCRIPT_SOURCE not found!\n\nPlease run the installer in the same folder as social-dl.sh." ;;
        "checking_deps") [ "$LANG_CHOICE" = "de" ] && echo "Prüfe Abhängigkeiten..." || echo "Checking dependencies..." ;;
        "missing_deps") [ "$LANG_CHOICE" = "de" ] && echo "<b>Fehlende Abhängigkeiten:</b>" || echo "<b>Missing dependencies:</b>" ;;
        "install_instructions") [ "$LANG_CHOICE" = "de" ] && echo "<b>Installation:</b>" || echo "<b>Installation:</b>" ;;
        "select_type") [ "$LANG_CHOICE" = "de" ] && echo "Wähle den Installationstyp:" || echo "Select installation type:" ;;
        "type_local") [ "$LANG_CHOICE" = "de" ] && echo "Nur für aktuellen User (empfohlen)" || echo "Only for current user (recommended)" ;;
        "type_system") [ "$LANG_CHOICE" = "de" ] && echo "Systemweit für alle User (benötigt sudo)" || echo "System-wide for all users (requires sudo)" ;;
        "installing") [ "$LANG_CHOICE" = "de" ] && echo "Installation läuft..." || echo "Installing..." ;;
        "creating_dirs") [ "$LANG_CHOICE" = "de" ] && echo "Erstelle Verzeichnisse..." || echo "Creating directories..." ;;
        "copying_script") [ "$LANG_CHOICE" = "de" ] && echo "Kopiere Script..." || echo "Copying script..." ;;
        "creating_desktop") [ "$LANG_CHOICE" = "de" ] && echo "Erstelle Desktop-Eintrag..." || echo "Creating desktop entry..." ;;
        "configuring_path") [ "$LANG_CHOICE" = "de" ] && echo "Konfiguriere PATH..." || echo "Configuring PATH..." ;;
        "done") [ "$LANG_CHOICE" = "de" ] && echo "Installation abgeschlossen!" || echo "Installation complete!" ;;
        "request_admin") [ "$LANG_CHOICE" = "de" ] && echo "Fordere Administrator-Rechte an..." || echo "Requesting admin rights..." ;;
        "need_sudo") [ "$LANG_CHOICE" = "de" ] && echo "Systemweite Installation benötigt Root-Rechte!\n\nBitte führe aus:\n  sudo $0\n\nOder wähle lokale Installation (nur für aktuellen User)." || echo "System-wide installation requires root privileges!\n\nPlease run:\n  sudo $0\n\nOr select local installation (current user only)." ;;
        "success") [ "$LANG_CHOICE" = "de" ] && echo "Social-DL wurde erfolgreich installiert!" || echo "Social-DL was successfully installed!" ;;
        "usage") [ "$LANG_CHOICE" = "de" ] && echo "<b>Verwendung:</b>" || echo "<b>Usage:</b>" ;;
        "usage_terminal") [ "$LANG_CHOICE" = "de" ] && echo "Terminal: <tt>social-dl</tt>" || echo "Terminal: <tt>social-dl</tt>" ;;
        "usage_menu") [ "$LANG_CHOICE" = "de" ] && echo "Anwendungsmenü: 'Social Media Downloader'" || echo "Application menu: 'Social Media Downloader'" ;;
        "note_shell") [ "$LANG_CHOICE" = "de" ] && echo "<b>Hinweis:</b> Bei manchen Shells muss ein neues Terminal geöffnet werden." || echo "<b>Note:</b> Some shells require opening a new terminal." ;;
        "test_question") [ "$LANG_CHOICE" = "de" ] && echo "Möchtest du einen Test-Download durchführen?\n\n(Öffnet Terminal mit Test-URL)" || echo "Would you like to perform a test download?\n\n(Opens terminal with test URL)" ;;
        "yes_test") [ "$LANG_CHOICE" = "de" ] && echo "Ja, testen" || echo "Yes, test" ;;
        "no_thanks") [ "$LANG_CHOICE" = "de" ] && echo "Nein, danke" || echo "No, thanks" ;;
        "no_terminal") [ "$LANG_CHOICE" = "de" ] && echo "Kein Terminal-Emulator gefunden.\n\nÖffne manuell ein Terminal und führe aus:\n" || echo "No terminal emulator found.\n\nOpen a terminal manually and run:\n" ;;
        "failed") [ "$LANG_CHOICE" = "de" ] && echo "Installation fehlgeschlagen!\n\nBitte prüfe die Fehlermeldungen." || echo "Installation failed!\n\nPlease check the error messages." ;;
        "press_enter") [ "$LANG_CHOICE" = "de" ] && echo "Drücke Enter zum Beenden..." || echo "Press Enter to exit..." ;;
        *) echo "$key" ;;
    esac
}

# Prüfe ob Zenity verfügbar ist
if ! command -v zenity >/dev/null 2>&1; then
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Social-DL Installer" "Error: 'zenity' not installed!\n\nInstall: sudo apt install zenity"
    fi
    echo "Error: zenity not found. Install: sudo apt install zenity" >&2
    exit 1
fi

# Willkommens-Dialog
zenity --question \
    --title="$(t "title")" \
    --text="$(t "welcome_text")" \
    --width=400 \
    --ok-label="$(t "continue")" \
    --cancel-label="$(t "cancel")" || exit 0

# Prüfe ob social-dl.sh existiert
if [ ! -f "$SCRIPT_SOURCE" ]; then
    zenity --error \
        --title="$(t "title")" \
        --text="$(t "error_script_not_found")" \
        --width=400
    exit 1
fi

# Prüfe Abhängigkeiten
MISSING_DEPS=""
for tool in yt-dlp timeout; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        MISSING_DEPS="${MISSING_DEPS}• $tool\n"
    fi
done

if [ -n "$MISSING_DEPS" ]; then
    INSTALL_MSG="$(t "install_instructions")\n"
    [ "$LANG_CHOICE" = "de" ] && INSTALL_MSG="${INSTALL_MSG}Arch/Manjaro: sudo pacman -S yt-dlp\nDebian/Ubuntu: sudo apt install yt-dlp\nFedora: sudo dnf install yt-dlp\nUniversal: pip install yt-dlp" || INSTALL_MSG="${INSTALL_MSG}Arch/Manjaro: sudo pacman -S yt-dlp\nDebian/Ubuntu: sudo apt install yt-dlp\nFedora: sudo dnf install yt-dlp\nUniversal: pip install yt-dlp"

    zenity --error \
        --title="$(t "title")" \
        --text="$(t "missing_deps")\n\n${MISSING_DEPS}\n${INSTALL_MSG}" \
        --width=550
    exit 1
fi

# Installationstyp wählen
INSTALL_TYPE=$(zenity --list \
    --title="$(t "title")" \
    --text="$(t "select_type")" \
    --radiolist \
    --column="☑" --column="Typ" --column="Beschreibung" \
    TRUE "local" "$(t "type_local")" \
    FALSE "system" "$(t "type_system")" \
    --width=650 --height=350)

if [ -z "$INSTALL_TYPE" ]; then
    exit 0
fi

# Installation durchführen
(
echo "10" ; sleep 0.5
echo "# $(t "creating_dirs")" ; sleep 0.5

if [ "$INSTALL_TYPE" = "local" ]; then
    echo "30"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share/applications"

    echo "50"
    echo "# $(t "copying_script")"
    cp "$SCRIPT_SOURCE" "$HOME/.local/bin/$SCRIPT_NAME"
    chmod +x "$HOME/.local/bin/$SCRIPT_NAME"

    # Set language preference in wrapper
    cat > "$HOME/.local/bin/.social-dl-lang" << EOF
export SOCIAL_DL_LANG="$LANG_CHOICE"
EOF

    echo "70"
    echo "# $(t "creating_desktop")"
    cat > "$HOME/.local/share/applications/$SCRIPT_NAME.desktop" << EOF
[Desktop Entry]
Name=Social Media Downloader
Comment=Download videos/audio from Instagram, YouTube, Twitter, Reddit, TikTok
Exec=bash -c 'source $HOME/.local/bin/.social-dl-lang 2>/dev/null; $HOME/.local/bin/$SCRIPT_NAME'
Icon=applications-multimedia
Terminal=true
Type=Application
Categories=Network;AudioVideo;
Keywords=download;video;instagram;youtube;twitter;reddit;tiktok;
EOF
    chmod 644 "$HOME/.local/share/applications/$SCRIPT_NAME.desktop"
    
    # Desktop-Database aktualisieren
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    fi

    echo "90"
    echo "# $(t "configuring_path")"

    CURRENT_SHELL=$(basename "$SHELL")
    case "$CURRENT_SHELL" in
        fish)
            if command -v fish >/dev/null 2>&1; then
                fish -c "fish_add_path ~/.local/bin" 2>/dev/null || true
            fi
            ;;
        zsh)
            if ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$HOME/.zshrc" 2>/dev/null; then
                echo '' >> "$HOME/.zshrc"
                echo '# Added by social-dl installer' >> "$HOME/.zshrc"
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
            fi
            ;;
        bash)
            if ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$HOME/.bashrc" 2>/dev/null; then
                echo '' >> "$HOME/.bashrc"
                echo '# Added by social-dl installer' >> "$HOME/.bashrc"
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
            fi
            ;;
    esac

    echo "100"
    echo "# $(t "done")"

else
    echo "30"
    echo "# $(t "request_admin")"

    if command -v pkexec >/dev/null 2>&1; then
        echo "50"
        echo "# $(t "copying_script")"

        pkexec bash -c "
            mkdir -p /usr/local/bin
            mkdir -p /usr/share/applications
            cp '$SCRIPT_SOURCE' '/usr/local/bin/$SCRIPT_NAME'
            chmod +x '/usr/local/bin/$SCRIPT_NAME'

            echo 'export SOCIAL_DL_LANG=\"$LANG_CHOICE\"' > /usr/local/bin/.social-dl-lang

            cat > '/usr/share/applications/$SCRIPT_NAME.desktop' << 'EOF'
[Desktop Entry]
Name=Social Media Downloader
Comment=Download videos/audio from Instagram, YouTube, Twitter, Reddit, TikTok
Exec=bash -c 'source /usr/local/bin/.social-dl-lang 2>/dev/null; /usr/local/bin/$SCRIPT_NAME'
Icon=applications-multimedia
Terminal=true
Type=Application
Categories=Network;AudioVideo;
Keywords=download;video;instagram;youtube;twitter;reddit;tiktok;
EOF
            chmod 644 '/usr/share/applications/$SCRIPT_NAME.desktop'
            
            # Desktop-Database aktualisieren
            if command -v update-desktop-database >/dev/null 2>&1; then
                update-desktop-database /usr/share/applications 2>/dev/null || true
            fi
        " || exit 1
    else
        zenity --error \
            --title="$(t "title")" \
            --text="$(t "need_sudo")" \
            --width=400
        exit 1
    fi

    echo "100"
    echo "# $(t "done")"
fi

) | zenity --progress \
    --title="$(t "title")" \
    --text="$(t "installing")" \
    --percentage=0 \
    --auto-close \
    --no-cancel \
    --width=400

ZENITY_EXIT=$?

if [ $ZENITY_EXIT -eq 0 ] || [ $ZENITY_EXIT -eq 143 ]; then
    MSG="$(t "success")\n\n$(t "usage")\n• $(t "usage_terminal")\n• $(t "usage_menu")\n\n"

    if [ "$INSTALL_TYPE" = "local" ]; then
        MSG="${MSG}$(t "note_shell")"
    fi

    zenity --info \
        --title="$(t "title")" \
        --text="$MSG" \
        --width=550

    if zenity --question \
        --title="$(t "title")" \
        --text="$(t "test_question")" \
        --width=400 \
        --ok-label="$(t "yes_test")" \
        --cancel-label="$(t "no_thanks")"; then

        if [ "$INSTALL_TYPE" = "local" ]; then
            SCRIPT_PATH="$HOME/.local/bin/$SCRIPT_NAME"
        else
            SCRIPT_PATH="/usr/local/bin/$SCRIPT_NAME"
        fi

        USER_SHELL=$(basename "$SHELL")

        if command -v gnome-terminal >/dev/null 2>&1; then
            case "$USER_SHELL" in
                fish)
                    gnome-terminal -- fish -l -c "SOCIAL_DL_LANG='$LANG_CHOICE' '$SCRIPT_PATH' 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'; echo ''; echo '$(t "press_enter")'; read"
                    ;;
                zsh)
                    gnome-terminal -- zsh -l -c "SOCIAL_DL_LANG='$LANG_CHOICE' '$SCRIPT_PATH' 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'; echo ''; echo '$(t "press_enter")'; read"
                    ;;
                *)
                    gnome-terminal -- bash -l -c "SOCIAL_DL_LANG='$LANG_CHOICE' '$SCRIPT_PATH' 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'; echo ''; echo '$(t "press_enter")'; read"
                    ;;
            esac
        elif command -v konsole >/dev/null 2>&1; then
            case "$USER_SHELL" in
                fish)
                    konsole -e fish -l -c "SOCIAL_DL_LANG='$LANG_CHOICE' '$SCRIPT_PATH' 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'; echo ''; echo '$(t "press_enter")'; read"
                    ;;
                *)
                    konsole -e bash -l -c "SOCIAL_DL_LANG='$LANG_CHOICE' '$SCRIPT_PATH' 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'; echo ''; echo '$(t "press_enter")'; read"
                    ;;
            esac
        else
            zenity --info \
                --title="$(t "title")" \
                --text="$(t "no_terminal")$SCRIPT_PATH --help" \
                --width=400
        fi
    fi
else
    zenity --error \
        --title="$(t "title")" \
        --text="$(t "failed")" \
        --width=400
    exit 1
fi
