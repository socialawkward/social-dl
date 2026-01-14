#!/bin/bash
# ============================================================================
# SETTINGS ACTION HANDLERS for Social-DL
# ============================================================================
# These functions are called by the UI module when settings actions are triggered
# They are designed to be called within the settings loop to keep it open

handle_config_edit() {
    local lang_mode="$1"
    local temp_dir="$2"
    CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/social-dl/config"
    
    # Create config from example if it doesn't exist
    if [ ! -f "$CONFIG_FILE" ]; then
        mkdir -p "$(dirname "$CONFIG_FILE")"
        [ -f "$temp_dir/config.example" ] && cp "$temp_dir/config.example" "$CONFIG_FILE" 2>/dev/null || true
    fi
    
    # Try to find a text editor
    EDITOR_CMD=""
    for editor in gedit kate mousepad pluma xed leafpad nano; do
        if command -v "$editor" >/dev/null 2>&1; then
            EDITOR_CMD="$editor"
            break
        fi
    done
    
    if [ -n "$EDITOR_CMD" ]; then
        $EDITOR_CMD "$CONFIG_FILE" &
    else
        if [ "$lang_mode" = "de" ]; then
            yad --info --width=400 --image="dialog-information" --title="Info" \
                --text="<b>Kein Texteditor gefunden!</b>\n\nÖffne die Datei manuell:\n\n<tt>$CONFIG_FILE</tt>" \
                --button="OK:0" 2>/dev/null || true
        else
            yad --info --width=400 --image="dialog-information" --title="Info" \
                --text="<b>No text editor found!</b>\n\nOpen the file manually:\n\n<tt>$CONFIG_FILE</tt>" \
                --button="OK:0" 2>/dev/null || true
        fi
    fi
}

handle_download_folder() {
    local lang_mode="$1"
    NEW_DIR=$(yad --file --directory --title="Select Download Folder / Download-Ordner wählen" \
        --button="Abbrechen/Cancel:1" --button="Auswählen/Select:0" 2>/dev/null)
    
    if [ -n "$NEW_DIR" ]; then
        CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/social-dl/config"
        mkdir -p "$(dirname "$CONFIG_FILE")"
        
        if [ -f "$CONFIG_FILE" ]; then
            if grep -q "^DOWNLOAD_DIR=" "$CONFIG_FILE"; then
                sed -i "s|^DOWNLOAD_DIR=.*|DOWNLOAD_DIR=\"$NEW_DIR/Videos\"|" "$CONFIG_FILE"
            else
                echo "DOWNLOAD_DIR=\"$NEW_DIR/Videos\"" >> "$CONFIG_FILE"
            fi
            if grep -q "^AUDIO_DIR=" "$CONFIG_FILE"; then
                sed -i "s|^AUDIO_DIR=.*|AUDIO_DIR=\"$NEW_DIR/Audio\"|" "$CONFIG_FILE"
            else
                echo "AUDIO_DIR=\"$NEW_DIR/Audio\"" >> "$CONFIG_FILE"
            fi
        else
            cat > "$CONFIG_FILE" << EOF
# Social-DL Configuration
DOWNLOAD_DIR="$NEW_DIR/Videos"
AUDIO_DIR="$NEW_DIR/Audio"
EOF
        fi
        
        if [ "$lang_mode" = "de" ]; then
            yad --info --width=320 --image="dialog-information" --title="Erfolg" \
                --text="<b>Download-Ordner gesetzt!</b>\n\n<tt>$NEW_DIR</tt>" \
                --button="OK:0" 2>/dev/null || true
        else
            yad --info --width=320 --image="dialog-information" --title="Success" \
                --text="<b>Download folder set!</b>\n\n<tt>$NEW_DIR</tt>" \
                --button="OK:0" 2>/dev/null || true
        fi
    fi
}

handle_retry_count() {
    local lang_mode="$1"
    
    if [ "$lang_mode" = "de" ]; then
        RETRY_COUNT=$(yad --entry --title="Wiederholungsversuche" \
            --text="Anzahl der Wiederholungsversuche bei Netzwerkfehlern:" \
            --entry-text="3" \
            --button="Abbrechen:1" --button="OK:0" 2>/dev/null)
    else
        RETRY_COUNT=$(yad --entry --title="Retry Count" \
            --text="Number of retry attempts on network errors:" \
            --entry-text="3" \
            --button="Cancel:1" --button="OK:0" 2>/dev/null)
    fi
    
    if [ -n "$RETRY_COUNT" ] && [[ "$RETRY_COUNT" =~ ^[0-9]+$ ]]; then
        CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/social-dl/config"
        mkdir -p "$(dirname "$CONFIG_FILE")"
        
        if [ -f "$CONFIG_FILE" ]; then
            if grep -q "^MAX_RETRIES=" "$CONFIG_FILE"; then
                sed -i "s|^MAX_RETRIES=.*|MAX_RETRIES=$RETRY_COUNT|" "$CONFIG_FILE"
            else
                echo "MAX_RETRIES=$RETRY_COUNT" >> "$CONFIG_FILE"
            fi
        else
            echo "MAX_RETRIES=$RETRY_COUNT" > "$CONFIG_FILE"
        fi
        
        if [ "$lang_mode" = "de" ]; then
            yad --info --width=320 --image="dialog-information" --title="Erfolg" \
                --text="<b>Retry-Anzahl gesetzt!</b>\n\n$RETRY_COUNT Versuche" \
                --button="OK:0" 2>/dev/null || true
        else
            yad --info --width=320 --image="dialog-information" --title="Success" \
                --text="<b>Retry count set!</b>\n\n$RETRY_COUNT attempts" \
                --button="OK:0" 2>/dev/null || true
        fi
    fi
}

handle_github_repo() {
    local lang_mode="$1"
    
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "https://github.com/socialawkward/social-dl" 2>/dev/null &
    elif command -v firefox >/dev/null 2>&1; then
        firefox "https://github.com/socialawkward/social-dl" 2>/dev/null &
    elif command -v chromium >/dev/null 2>&1; then
        chromium "https://github.com/socialawkward/social-dl" 2>/dev/null &
    else
        if [ "$lang_mode" = "de" ]; then
            yad --info --width=400 --image="dialog-information" --title="GitHub Repository" \
                --text="<b>Repository URL:</b>\n\n<span foreground='#0969DA'>https://github.com/socialawkward/social-dl</span>" \
                --button="OK:0" 2>/dev/null || true
        else
            yad --info --width=400 --image="dialog-information" --title="GitHub Repository" \
                --text="<b>Repository URL:</b>\n\n<span foreground='#0969DA'>https://github.com/socialawkward/social-dl</span>" \
                --button="OK:0" 2>/dev/null || true
        fi
    fi
}

handle_ytdlp_update() {
    local lang_mode="$1"
    
    if [ "$lang_mode" = "de" ]; then
        TERM_TITLE="System-Check"
        UPDATE_CMD="
echo '🔍 Social-DL System-Check'
echo '================================'
echo ''

# Erkenne Package-Manager
PKG_MGR='Unbekannt'
if command -v pacman >/dev/null 2>&1; then
    PKG_MGR='pacman (Arch/Manjaro/CachyOS)'
elif command -v apt >/dev/null 2>&1; then
    PKG_MGR='apt (Debian/Ubuntu)'
elif command -v dnf >/dev/null 2>&1; then
    PKG_MGR='dnf (Fedora)'
fi

echo '📦 System: '\$PKG_MGR
echo ''

# Check yt-dlp
if command -v yt-dlp >/dev/null 2>&1; then
    YTDLP_VER=\$(yt-dlp --version 2>/dev/null)
    echo '✅ yt-dlp: '\$YTDLP_VER' (installiert)'
else
    echo '❌ yt-dlp: Nicht installiert'
    if command -v pacman >/dev/null 2>&1; then
        echo '   Installation: sudo pacman -S yt-dlp'
    elif command -v apt >/dev/null 2>&1; then
        echo '   Installation: sudo apt install yt-dlp'
    elif command -v dnf >/dev/null 2>&1; then
        echo '   Installation: sudo dnf install yt-dlp'
    fi
fi

# Check YAD
if command -v yad >/dev/null 2>&1; then
    YAD_VER=\$(yad --version 2>&1 | head -1)
    echo '✅ YAD: '\$YAD_VER' (installiert)'
else
    echo '⚠️  YAD: Nicht installiert (empfohlen)'
    if command -v pacman >/dev/null 2>&1; then
        echo '   Installation: sudo pacman -S yad'
    elif command -v apt >/dev/null 2>&1; then
        echo '   Installation: sudo apt install yad'
    elif command -v dnf >/dev/null 2>&1; then
        echo '   Installation: sudo dnf install yad'
    fi
fi

# Check Zenity
if command -v zenity >/dev/null 2>&1; then
    ZENITY_VER=\$(zenity --version 2>&1)
    echo '✅ Zenity: '\$ZENITY_VER' (installiert)'
else
    echo '⚠️  Zenity: Nicht installiert (Fallback)'
    if command -v pacman >/dev/null 2>&1; then
        echo '   Installation: sudo pacman -S zenity'
    elif command -v apt >/dev/null 2>&1; then
        echo '   Installation: sudo apt install zenity'
    elif command -v dnf >/dev/null 2>&1; then
        echo '   Installation: sudo dnf install zenity'
    fi
fi

# Check ffmpeg
if command -v ffmpeg >/dev/null 2>&1; then
    FFMPEG_VER=\$(ffmpeg -version 2>&1 | head -1 | awk '{print \$3}')
    echo '✅ ffmpeg: '\$FFMPEG_VER' (installiert)'
else
    echo '⚠️  ffmpeg: Nicht installiert (für MP3-Konvertierung)'
    if command -v pacman >/dev/null 2>&1; then
        echo '   Installation: sudo pacman -S ffmpeg'
    elif command -v apt >/dev/null 2>&1; then
        echo '   Installation: sudo apt install ffmpeg'
    elif command -v dnf >/dev/null 2>&1; then
        echo '   Installation: sudo dnf install ffmpeg'
    fi
fi

echo ''
echo '================================'
echo '💡 Zum Updaten aller Pakete:'
if command -v pacman >/dev/null 2>&1; then
    echo '   sudo pacman -Syu'
elif command -v apt >/dev/null 2>&1; then
    echo '   sudo apt update && sudo apt upgrade'
elif command -v dnf >/dev/null 2>&1; then
    echo '   sudo dnf upgrade'
fi
echo ''
read -p 'Enter zum Schließen...'
"
    else
        TERM_TITLE="System Check"
        UPDATE_CMD="
echo '🔍 Social-DL System Check'
echo '================================'
echo ''

# Detect Package Manager
PKG_MGR='Unknown'
if command -v pacman >/dev/null 2>&1; then
    PKG_MGR='pacman (Arch/Manjaro/CachyOS)'
elif command -v apt >/dev/null 2>&1; then
    PKG_MGR='apt (Debian/Ubuntu)'
elif command -v dnf >/dev/null 2>&1; then
    PKG_MGR='dnf (Fedora)'
fi

echo '📦 System: '\$PKG_MGR
echo ''

# Check yt-dlp
if command -v yt-dlp >/dev/null 2>&1; then
    YTDLP_VER=\$(yt-dlp --version 2>/dev/null)
    echo '✅ yt-dlp: '\$YTDLP_VER' (installed)'
else
    echo '❌ yt-dlp: Not installed'
    if command -v pacman >/dev/null 2>&1; then
        echo '   Installation: sudo pacman -S yt-dlp'
    elif command -v apt >/dev/null 2>&1; then
        echo '   Installation: sudo apt install yt-dlp'
    elif command -v dnf >/dev/null 2>&1; then
        echo '   Installation: sudo dnf install yt-dlp'
    fi
fi

# Check YAD
if command -v yad >/dev/null 2>&1; then
    YAD_VER=\$(yad --version 2>&1 | head -1)
    echo '✅ YAD: '\$YAD_VER' (installed)'
else
    echo '⚠️  YAD: Not installed (recommended)'
    if command -v pacman >/dev/null 2>&1; then
        echo '   Installation: sudo pacman -S yad'
    elif command -v apt >/dev/null 2>&1; then
        echo '   Installation: sudo apt install yad'
    elif command -v dnf >/dev/null 2>&1; then
        echo '   Installation: sudo dnf install yad'
    fi
fi

# Check Zenity
if command -v zenity >/dev/null 2>&1; then
    ZENITY_VER=\$(zenity --version 2>&1)
    echo '✅ Zenity: '\$ZENITY_VER' (installed)'
else
    echo '⚠️  Zenity: Not installed (fallback)'
    if command -v pacman >/dev/null 2>&1; then
        echo '   Installation: sudo pacman -S zenity'
    elif command -v apt >/dev/null 2>&1; then
        echo '   Installation: sudo apt install zenity'
    elif command -v dnf >/dev/null 2>&1; then
        echo '   Installation: sudo dnf install zenity'
    fi
fi

# Check ffmpeg
if command -v ffmpeg >/dev/null 2>&1; then
    FFMPEG_VER=\$(ffmpeg -version 2>&1 | head -1 | awk '{print \$3}')
    echo '✅ ffmpeg: '\$FFMPEG_VER' (installed)'
else
    echo '⚠️  ffmpeg: Not installed (for MP3 conversion)'
    if command -v pacman >/dev/null 2>&1; then
        echo '   Installation: sudo pacman -S ffmpeg'
    elif command -v apt >/dev/null 2>&1; then
        echo '   Installation: sudo apt install ffmpeg'
    elif command -v dnf >/dev/null 2>&1; then
        echo '   Installation: sudo dnf install ffmpeg'
    fi
fi

echo ''
echo '================================'
echo '💡 To update all packages:'
if command -v pacman >/dev/null 2>&1; then
    echo '   sudo pacman -Syu'
elif command -v apt >/dev/null 2>&1; then
    echo '   sudo apt update && sudo apt upgrade'
elif command -v dnf >/dev/null 2>&1; then
    echo '   sudo dnf upgrade'
fi
echo ''
read -p 'Press Enter to close...'
"
    fi
    
    TERMINAL=""
    for term in x-terminal-emulator konsole gnome-terminal xfce4-terminal xterm; do
        if command -v "$term" >/dev/null 2>&1; then
            TERMINAL="$term"
            break
        fi
    done
    
    if [ -n "$TERMINAL" ]; then
        case "$TERMINAL" in
            konsole)
                konsole --title "$TERM_TITLE" -e bash -c "$UPDATE_CMD" &
                ;;
            gnome-terminal|xfce4-terminal)
                $TERMINAL --title="$TERM_TITLE" -- bash -c "$UPDATE_CMD" &
                ;;
            *)
                $TERMINAL -e bash -c "$UPDATE_CMD" &
                ;;
        esac
    else
        if [ "$lang_mode" = "de" ]; then
            yad --info --width=450 --image="dialog-information" --title="System-Check" \
                --text="<b>Kein Terminal gefunden!</b>\n\nPrüfe manuell mit:\n<tt>yt-dlp --version</tt>\n<tt>yad --version</tt>\n<tt>zenity --version</tt>\n<tt>ffmpeg -version</tt>" \
                --button="OK:0" 2>/dev/null || true
        else
            yad --info --width=450 --image="dialog-information" --title="System Check" \
                --text="<b>No terminal found!</b>\n\nCheck manually with:\n<tt>yt-dlp --version</tt>\n<tt>yad --version</tt>\n<tt>zenity --version</tt>\n<tt>ffmpeg -version</tt>" \
                --button="OK:0" 2>/dev/null || true
        fi
    fi
}

# Export all handlers
export -f handle_config_edit
export -f handle_download_folder
export -f handle_retry_count
export -f handle_github_repo
export -f handle_ytdlp_update
