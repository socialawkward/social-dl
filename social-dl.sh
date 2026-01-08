#!/usr/bin/env bash

# Improved Instagram/Twitter/YouTube/Reddit/TikTok Video/Audio Downloader
# Features: Clipboard detection, duplicate check, atomic counter, optional Shotcut editing
# Version: 2.4 (Quick Wins + Version Check)

set -o errexit
set -o nounset
set -o pipefail

# Version Info
SCRIPT_VERSION="2.4"
GITHUB_REPO="socialawkward/social-dl"

# Language Detection
detect_language() {
    # Check SOCIAL_DL_LANG first (set by installer)
    if [ -n "${SOCIAL_DL_LANG:-}" ]; then
        echo "$SOCIAL_DL_LANG"
        return
    fi

    # Check system locale
    local lang="${LANG:-en_US.UTF-8}"
    if [[ "$lang" == de* ]]; then
        echo "de"
    else
        echo "en"
    fi
}

SCRIPT_LANG=$(detect_language)

# Translations
msg() {
    local key="$1"

    case "$key" in
        # Help messages
        "help_usage")
            [ "$SCRIPT_LANG" = "de" ] && echo "VERWENDUNG:" || echo "USAGE:"
            ;;
        "help_examples")
            [ "$SCRIPT_LANG" = "de" ] && echo "BEISPIELE:" || echo "EXAMPLES:"
            ;;
        "help_platforms")
            [ "$SCRIPT_LANG" = "de" ] && echo "UNTERSTÜTZTE PLATTFORMEN:" || echo "SUPPORTED PLATFORMS:"
            ;;
        "help_features")
            [ "$SCRIPT_LANG" = "de" ] && echo "FEATURES:" || echo "FEATURES:"
            ;;
        "help_dependencies")
            [ "$SCRIPT_LANG" = "de" ] && echo "ABHÄNGIGKEITEN:" || echo "DEPENDENCIES:"
            ;;
        "help_required")
            [ "$SCRIPT_LANG" = "de" ] && echo "Pflicht" || echo "Required"
            ;;
        "help_optional")
            [ "$SCRIPT_LANG" = "de" ] && echo "optional" || echo "optional"
            ;;
        "help_clipboard")
            [ "$SCRIPT_LANG" = "de" ] && echo "für Clipboard" || echo "for clipboard"
            ;;
        "help_editing")
            [ "$SCRIPT_LANG" = "de" ] && echo "für Bearbeitung" || echo "for editing"
            ;;
        "help_notifications")
            [ "$SCRIPT_LANG" = "de" ] && echo "für Benachrichtigungen" || echo "for notifications"
            ;;

        # Tool hints
        "hint_shotcut")
            [ "$SCRIPT_LANG" = "de" ] && echo "Hinweis: 'shotcut' nicht gefunden. Bearbeiten wird übersprungen." || echo "Note: 'shotcut' not found. Editing will be skipped."
            ;;
        "hint_clipboard")
            [ "$SCRIPT_LANG" = "de" ] && echo "Hinweis: Kein Clipboard-Tool (xclip/wl-paste) gefunden." || echo "Note: No clipboard tool (xclip/wl-paste) found."
            ;;

        # Errors
        "error_missing_tools")
            [ "$SCRIPT_LANG" = "de" ] && echo "Fehler: Pflicht-Tools fehlen:" || echo "Error: Required tools missing:"
            ;;
        "error_install_hint")
            [ "$SCRIPT_LANG" = "de" ] && echo "Installation: sudo apt install yt-dlp (oder: pip install yt-dlp)" || echo "Install: sudo apt install yt-dlp (or: pip install yt-dlp)"
            ;;
        "error_no_clipboard")
            [ "$SCRIPT_LANG" = "de" ] && echo "Fehler: Kein Link in der Zwischenablage gefunden!" || echo "Error: No link found in clipboard!"
            ;;
        "error_clipboard_hint")
            [ "$SCRIPT_LANG" = "de" ] && echo "Kopiere einen Link und führe erneut aus." || echo "Copy a link and run again."
            ;;
        "error_invalid_url")
            [ "$SCRIPT_LANG" = "de" ] && echo "Fehler: URL enthält ungültige nicht-druckbare Zeichen!" || echo "Error: URL contains invalid non-printable characters!"
            ;;
        "error_dangerous_chars")
            [ "$SCRIPT_LANG" = "de" ] && echo "Fehler: URL enthält potentiell gefährliche Zeichen!" || echo "Error: URL contains potentially dangerous characters!"
            ;;
        "error_not_url")
            [ "$SCRIPT_LANG" = "de" ] && echo "Fehler: sieht nicht nach URL aus!" || echo "Error: doesn't look like a URL!"
            ;;
        "error_unsupported")
            [ "$SCRIPT_LANG" = "de" ] && echo "Fehler: Nicht unterstützter Link:" || echo "Error: Unsupported link:"
            ;;
        "error_supported_hint")
            [ "$SCRIPT_LANG" = "de" ] && echo "Unterstützt: Instagram, Twitter/X, YouTube, Reddit, TikTok." || echo "Supported: Instagram, Twitter/X, YouTube, Reddit, TikTok."
            ;;
        "error_download_failed")
            [ "$SCRIPT_LANG" = "de" ] && echo "Download fehlgeschlagen!" || echo "Download failed!"
            ;;
        "error_file_empty")
            [ "$SCRIPT_LANG" = "de" ] && echo "Download-Datei leer oder fehlerhaft!" || echo "Download file empty or corrupted!"
            ;;
        "error_details")
            [ "$SCRIPT_LANG" = "de" ] && echo "Fehlerdetails:" || echo "Error details:"
            ;;

        # Messages
        "msg_duplicate")
            [ "$SCRIPT_LANG" = "de" ] && echo "Warnung: URL bereits heruntergeladen:" || echo "Warning: URL already downloaded:"
            ;;
        "msg_duplicate_confirm")
            [ "$SCRIPT_LANG" = "de" ] && echo "Trotzdem erneut herunterladen?" || echo "Download again anyway?"
            ;;
        "msg_aborted")
            [ "$SCRIPT_LANG" = "de" ] && echo "Abgebrochen." || echo "Aborted."
            ;;
        "msg_audio_question")
            [ "$SCRIPT_LANG" = "de" ] && echo "Nur Audio herunterladen (MP3)?" || echo "Download audio only (MP3)?"
            ;;
        "msg_edit_question")
            [ "$SCRIPT_LANG" = "de" ] && echo "Video nach Download bearbeiten (Shotcut)?" || echo "Edit video after download (Shotcut)?"
            ;;
        "msg_edit_background")
            [ "$SCRIPT_LANG" = "de" ] && echo "Shotcut im Hintergrund starten?" || echo "Start Shotcut in background?"
            ;;
        "msg_quality_select")
            [ "$SCRIPT_LANG" = "de" ] && echo "Qualität wählen:" || echo "Select quality:"
            ;;
        "msg_quality_best")
            [ "$SCRIPT_LANG" = "de" ] && echo "Beste Qualität (Standard)" || echo "Best quality (default)"
            ;;
        "msg_quality_small")
            [ "$SCRIPT_LANG" = "de" ] && echo "klein" || echo "small"
            ;;
        "msg_quality_prompt")
            [ "$SCRIPT_LANG" = "de" ] && echo "Auswahl [1-4, Enter=1]:" || echo "Choice [1-4, Enter=1]:"
            ;;
        "msg_quality_invalid")
            [ "$SCRIPT_LANG" = "de" ] && echo "Ungültige Eingabe" || echo "Invalid input"
            ;;
        "msg_quality_using_default")
            [ "$SCRIPT_LANG" = "de" ] && echo "nutze Standard-Qualität" || echo "using default quality"
            ;;
        "msg_log_rotate")
            [ "$SCRIPT_LANG" = "de" ] && echo "Rotiere Log-Datei" || echo "Rotating log file"
            ;;
        "msg_tracker_removed")
            [ "$SCRIPT_LANG" = "de" ] && echo "Tracking-Parameter entfernt" || echo "Tracking parameters removed"
            ;;
        "msg_tracker_original")
            [ "$SCRIPT_LANG" = "de" ] && echo "Original:" || echo "Original:"
            ;;
        "msg_tracker_cleaned")
            [ "$SCRIPT_LANG" = "de" ] && echo "Bereinigt:" || echo "Cleaned:"
            ;;
        "msg_download_starting")
            [ "$SCRIPT_LANG" = "de" ] && echo "Starte Download..." || echo "Starting download..."
            ;;
        "msg_starting_shotcut")
            [ "$SCRIPT_LANG" = "de" ] && echo "Starte Shotcut..." || echo "Starting Shotcut..."
            ;;
        "msg_background")
            [ "$SCRIPT_LANG" = "de" ] && echo "(im Hintergrund)" || echo "(in background)"
            ;;
        "msg_success")
            [ "$SCRIPT_LANG" = "de" ] && echo "Download erfolgreich:" || echo "Download successful:"
            ;;
        "msg_searching")
            [ "$SCRIPT_LANG" = "de" ] && echo "Gesucht:" || echo "Searched:"
            ;;
        "msg_not_found")
            [ "$SCRIPT_LANG" = "de" ] && echo "Keine Dateien gefunden" || echo "No files found"
            ;;

        # Version Check messages
        "version_current")
            [ "$SCRIPT_LANG" = "de" ] && echo "Aktuelle Version:" || echo "Current version:"
            ;;
        "version_checking")
            [ "$SCRIPT_LANG" = "de" ] && echo "Prüfe auf Updates..." || echo "Checking for updates..."
            ;;
        "version_latest")
            [ "$SCRIPT_LANG" = "de" ] && echo "Neueste Version:" || echo "Latest version:"
            ;;
        "version_uptodate")
            [ "$SCRIPT_LANG" = "de" ] && echo "Du hast bereits die neueste Version!" || echo "You already have the latest version!"
            ;;
        "version_available")
            [ "$SCRIPT_LANG" = "de" ] && echo "Neue Version verfügbar!" || echo "New version available!"
            ;;
        "version_download")
            [ "$SCRIPT_LANG" = "de" ] && echo "Download:" || echo "Download:"
            ;;
        "version_error")
            [ "$SCRIPT_LANG" = "de" ] && echo "Fehler beim Prüfen der Version" || echo "Error checking version"
            ;;
        "version_no_network")
            [ "$SCRIPT_LANG" = "de" ] && echo "Keine Netzwerkverbindung" || echo "No network connection"
            ;;

        # Notifications
        "notif_no_link")
            [ "$SCRIPT_LANG" = "de" ] && echo "Kein Link gefunden!" || echo "No link found!"
            ;;
        "notif_invalid_url")
            [ "$SCRIPT_LANG" = "de" ] && echo "Ungültige URL!" || echo "Invalid URL!"
            ;;
        "notif_unsupported")
            [ "$SCRIPT_LANG" = "de" ] && echo "Nicht unterstützte Quelle!" || echo "Unsupported source!"
            ;;
        "notif_failed")
            [ "$SCRIPT_LANG" = "de" ] && echo "Download fehlgeschlagen" || echo "Download failed"
            ;;
        "notif_corrupt")
            [ "$SCRIPT_LANG" = "de" ] && echo "Fehlerhafte Datei" || echo "Corrupted file"
            ;;
        "notif_success")
            [ "$SCRIPT_LANG" = "de" ] && echo "Download erfolgreich" || echo "Download successful"
            ;;
        "notif_error")
            [ "$SCRIPT_LANG" = "de" ] && echo "Download-Fehler" || echo "Download error"
            ;;
        "notif_empty")
            [ "$SCRIPT_LANG" = "de" ] && echo "Leere Datei" || echo "Empty file"
            ;;

        *)
            echo "$key"
            ;;
    esac
}

# Konfiguration
DOWNLOAD_DIR="$HOME/Downloads/Videos"
AUDIO_DIR="$HOME/Downloads/Audio"
LOG_FILE="$HOME/.social-dl.log"
LOG_LOCK="$LOG_FILE.lock"
LOG_MAX_LINES=10000
DOWNLOAD_TIMEOUT=300

# Cleanup bei Script-Ende (defensive programming)
cleanup() {
    rm -f "${LOG_LOCK:-}" 2>/dev/null || true
    if [ -n "${TEMP_PATTERN:-}" ] && [ -n "${TARGET_DIR:-}" ]; then
        rm -f "$TARGET_DIR/${TEMP_PATTERN}".* 2>/dev/null || true
    fi
}
trap cleanup EXIT

# Version Check Funktion
check_version() {
    echo ""
    echo "📦 Social-DL $(msg "version_current") $SCRIPT_VERSION"
    echo ""
    
    if [[ "${1:-}" == "--check-update" ]]; then
        echo "🔍 $(msg "version_checking")"
        echo ""
        
        # Check if curl/wget available
        if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
            echo "⚠️  $(msg "version_error"): curl/wget not found"
            return 1
        fi
        
        # TODO: Replace with actual GitHub API call when repo exists
        # For now, show placeholder
        echo "ℹ️  GitHub Repository: $GITHUB_REPO"
        echo ""
        echo "⚠️  $(msg "version_checking") $([ "$SCRIPT_LANG" = "de" ] && echo "noch nicht verfügbar" || echo "not yet available")"
        echo "   $([ "$SCRIPT_LANG" = "de" ] && echo "Repository wird noch erstellt" || echo "Repository being created")"
        echo ""
        
        local latest_version
if command -v curl >/dev/null 2>&1; then
    latest_version=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v?([0-9.]+)".*/\1/')
elif command -v wget >/dev/null 2>&1; then
    latest_version=$(wget -qO- "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v?([0-9.]+)".*/\1/')
else
    echo "❌ $(msg "version_error"): curl/wget nicht gefunden"
    return 1
fi

if [ -z "$latest_version" ]; then
    echo "❌ $(msg "version_error")"
    return 1
fi

echo "$(msg "version_latest") $latest_version"
echo ""

if [ "$SCRIPT_VERSION" = "$latest_version" ]; then
    echo "✅ $(msg "version_uptodate")"
else
    echo "🆕 $(msg "version_available")"
    echo " $(msg "version_download") https://github.com/$GITHUB_REPO/releases/latest"
fi
}

# Help anzeigen
show_help() {
    cat << EOF
Social-DL v$SCRIPT_VERSION - Universal Social Media Downloader

$(msg "help_usage")
  $0                    # $([ "$SCRIPT_LANG" = "de" ] && echo "URL aus Zwischenablage" || echo "URL from clipboard")
  $0 <URL>              # $([ "$SCRIPT_LANG" = "de" ] && echo "Direkte URL" || echo "Direct URL")
  $0 --help             # $([ "$SCRIPT_LANG" = "de" ] && echo "Diese Hilfe" || echo "This help")
  $0 --version          # $([ "$SCRIPT_LANG" = "de" ] && echo "Version anzeigen" || echo "Show version")
  $0 --check-update     # $([ "$SCRIPT_LANG" = "de" ] && echo "Nach Updates suchen" || echo "Check for updates")

$(msg "help_examples")
  $0                    # $([ "$SCRIPT_LANG" = "de" ] && echo "Clipboard verwenden" || echo "Use clipboard")
  $0 https://youtube.com/watch?v=...
  $0 https://instagram.com/p/...
  $0 https://twitter.com/user/status/...

$(msg "help_platforms")
  • Instagram   (Stories, Reels, Posts)
  • Twitter/X   (Tweets, Videos)
  • YouTube     (Videos, Shorts, $([ "$SCRIPT_LANG" = "de" ] && echo "keine" || echo "no") Playlists)
  • Reddit      (v.redd.it, Gfycat)
  • TikTok      ($([ "$SCRIPT_LANG" = "de" ] && echo "ohne Wasserzeichen" || echo "watermark removal"))

$(msg "help_features")
  • $([ "$SCRIPT_LANG" = "de" ] && echo "Automatische Duplikat-Erkennung" || echo "Automatic duplicate detection")
  • $([ "$SCRIPT_LANG" = "de" ] && echo "Tracking-Parameter-Entfernung" || echo "Tracking parameter removal")
  • $([ "$SCRIPT_LANG" = "de" ] && echo "Shotcut-Integration für Bearbeitung" || echo "Shotcut integration for editing")
  • $([ "$SCRIPT_LANG" = "de" ] && echo "Audio-Extraktion als MP3" || echo "Audio extraction as MP3")
  • $([ "$SCRIPT_LANG" = "de" ] && echo "Mehrere Qualitätsoptionen" || echo "Multiple quality options")

$(msg "help_dependencies")
  $(msg "help_required"):
    • yt-dlp          ($([ "$SCRIPT_LANG" = "de" ] && echo "Video-Downloader" || echo "video downloader"))
    • timeout         ($([ "$SCRIPT_LANG" = "de" ] && echo "meist vorinstalliert" || echo "usually pre-installed"))

  $(msg "help_optional"):
    • xclip/wl-paste  ($(msg "help_clipboard"))
    • shotcut         ($(msg "help_editing"))
    • notify-send     ($(msg "help_notifications"))

$([ "$SCRIPT_LANG" = "de" ] && echo "Installation der Abhängigkeiten:" || echo "Install dependencies:")
  # Arch/Manjaro
  sudo pacman -S yt-dlp xclip wl-clipboard shotcut libnotify

  # Debian/Ubuntu
  sudo apt install yt-dlp xclip wl-clipboard shotcut libnotify-bin

  # Universal
  pip install --user yt-dlp

$([ "$SCRIPT_LANG" = "de" ] && echo "Dateien werden gespeichert in:" || echo "Files are saved to:")
  • $([ "$SCRIPT_LANG" = "de" ] && echo "Videos:" || echo "Videos:") ~/Downloads/Videos/
  • $([ "$SCRIPT_LANG" = "de" ] && echo "Audio:" || echo "Audio:")  ~/Downloads/Audio/

$([ "$SCRIPT_LANG" = "de" ] && echo "Log-Datei:" || echo "Log file:") ~/.social-dl.log
EOF
    exit 0
}

# Tools prüfen
MISSING_TOOLS=()
for tool in yt-dlp timeout; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo "$(msg "error_missing_tools") ${MISSING_TOOLS[*]}" >&2
    echo "$(msg "error_install_hint")" >&2
    exit 1
fi

HAS_SHOTCUT=0
if command -v shotcut >/dev/null 2>&1; then
    HAS_SHOTCUT=1
else
    echo "$(msg "hint_shotcut")" >&2
fi

# Verzeichnisse
mkdir -p "$DOWNLOAD_DIR" "$AUDIO_DIR"
touch "$LOG_FILE"

# Helper
trim() {
    local var="$1"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}

confirm() {
    local prompt="$1"
    read -r -p "$prompt (j/N) " -n 1
    echo
    [[ "$REPLY" =~ ^[JjYy]$ ]]
}

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$1" "$2" 2>/dev/null || true
    fi
}

sanitize_url() {
    local url="$1"

    if [[ "$url" =~ [^[:print:]] ]]; then
        echo "$(msg "error_invalid_url")" >&2
        notify "Video-Download" "$(msg "notif_invalid_url")"
        return 1
    fi

    local dangerous_chars='[;&|`$<>(){}]'
    if [[ "$url" =~ $dangerous_chars ]]; then
        echo "$(msg "error_dangerous_chars")" >&2
        echo "URL: $url" >&2
        notify "Video-Download" "$(msg "notif_invalid_url")"
        return 1
    fi

    return 0
}

clean_url() {
    local url="$1"
    url=$(echo "$url" | sed -E 's/(\?|&)(utm_[^&]*|fbclid=[^&]*|gclid=[^&]*|msclkid=[^&]*|mc_[^&]*)//g')
    url=$(echo "$url" | sed 's/\?&/\?/g' | sed 's/\?$//')
    echo "$url"
}

rotate_log() {
    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE"
        return
    fi

    local line_count
    line_count=$(wc -l < "$LOG_FILE")

    if [ "$line_count" -ge "$LOG_MAX_LINES" ]; then
        echo "🔄 $(msg "msg_log_rotate") (${line_count}/${LOG_MAX_LINES})" >&2

        [ -f "${LOG_FILE}.2.old" ] && mv "${LOG_FILE}.2.old" "${LOG_FILE}.3.old"
        [ -f "${LOG_FILE}.1.old" ] && mv "${LOG_FILE}.1.old" "${LOG_FILE}.2.old"
        mv "$LOG_FILE" "${LOG_FILE}.1.old"
        touch "$LOG_FILE"
    fi
}

# Parameter
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    show_help
fi

if [[ "${1:-}" == "--version" || "${1:-}" == "-v" ]]; then
    check_version
    exit 0
fi

if [[ "${1:-}" == "--check-update" || "${1:-}" == "-u" ]]; then
    check_version --check-update
    exit 0
fi

# Link
LINK="${1:-}"

if [ -z "$LINK" ]; then
    if ! command -v wl-paste >/dev/null 2>&1 && ! command -v xclip >/dev/null 2>&1; then
        echo "$(msg "hint_clipboard")" >&2
    fi

    LINK=$(wl-paste 2>/dev/null || wl-paste --primary 2>/dev/null || \
           xclip -selection clipboard -o 2>/dev/null || \
           xclip -selection primary -o 2>/dev/null || \
           echo "")

    LINK=$(trim "$LINK")

    if [ -z "$LINK" ]; then
        echo "$(msg "error_no_clipboard")" >&2
        echo "$(msg "error_clipboard_hint")" >&2
        echo "$([ "$SCRIPT_LANG" = "de" ] && echo "Oder nutze:" || echo "Or use:") $0 <URL>" >&2
        notify "Video-Download" "$(msg "notif_no_link")"
        exit 1
    fi
else
    LINK=$(trim "$LINK")
fi

if [[ ! "$LINK" =~ ^https?:// ]]; then
    echo "$(msg "error_not_url") '$LINK'" >&2
    notify "Video-Download" "$(msg "notif_invalid_url")"
    exit 1
fi

if ! sanitize_url "$LINK"; then
    exit 1
fi

# URL-Cleaning
ORIGINAL_LINK="$LINK"
LINK=$(clean_url "$LINK")

if [ "$ORIGINAL_LINK" != "$LINK" ]; then
    echo "🧹 $(msg "msg_tracker_removed")"
    echo "   $(msg "msg_tracker_original") ${ORIGINAL_LINK:0:60}..."
    echo "   $(msg "msg_tracker_cleaned") $LINK"
    echo ""
fi

# Quelle erkennen
SOURCE=""
if [[ "$LINK" == *"instagram.com"* ]]; then
    SOURCE="Insta"
elif [[ "$LINK" == *"twitter.com"* || "$LINK" == *"x.com"* ]]; then
    SOURCE="Twitter"
elif [[ "$LINK" == *"youtube.com"* || "$LINK" == *"youtu.be"* ]]; then
    SOURCE="YouTube"
elif [[ "$LINK" == *"reddit.com"* ]]; then
    SOURCE="Reddit"
elif [[ "$LINK" == *"tiktok.com"* ]]; then
    SOURCE="TikTok"
else
    echo "$(msg "error_unsupported") $LINK" >&2
    echo "$(msg "error_supported_hint")" >&2
    notify "Video-Download" "$(msg "notif_unsupported")"
    exit 1
fi

# Duplicate-Check
{
    flock -x 200
    if grep -Fxq "$LINK" "$LOG_FILE"; then
        echo "$(msg "msg_duplicate")"
        echo "  $LINK"
        if ! confirm "$(msg "msg_duplicate_confirm")"; then
            echo "$(msg "msg_aborted")"
            exit 0
        fi
    fi
} 200>"$LOG_LOCK"

# Audio oder Video?
echo ""
if confirm "$(msg "msg_audio_question")"; then
    DOWNLOAD_TYPE="audio"
    TARGET_DIR="$AUDIO_DIR"
    FILE_EXT="mp3"
else
    DOWNLOAD_TYPE="video"
    TARGET_DIR="$DOWNLOAD_DIR"
    FILE_EXT="mp4"
fi

# Bearbeiten
EDIT=no
EDIT_BACKGROUND=no
if [ "$DOWNLOAD_TYPE" = "video" ] && [ "$HAS_SHOTCUT" -eq 1 ]; then
    if confirm "$(msg "msg_edit_question")"; then
        EDIT=yes
        if confirm "$(msg "msg_edit_background")"; then
            EDIT_BACKGROUND=yes
        fi
    fi
fi

# Format-String
FORMAT_STRING=""
YTDLP_EXTRA_ARGS=""

if [ "$DOWNLOAD_TYPE" = "audio" ]; then
    FORMAT_STRING="bestaudio[ext=m4a]/bestaudio"
    # QUICK WIN 1: Audio-Thumbnail hinzugefügt
    YTDLP_EXTRA_ARGS="-x --audio-format mp3 --audio-quality 0 --embed-thumbnail"
else
    echo ""
    echo "$(msg "msg_quality_select")"
    echo "  [1] $(msg "msg_quality_best")"
    echo "  [2] 1080p max"
    echo "  [3] 720p max"
    echo "  [4] 480p ($(msg "msg_quality_small"))"
    read -r -p "$(msg "msg_quality_prompt") " -n 1 QUALITY_CHOICE
    echo ""

    QUALITY_CHOICE="${QUALITY_CHOICE:-1}"

    case "$QUALITY_CHOICE" in
        1) FORMAT_STRING="bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" ;;
        2) FORMAT_STRING="bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[height<=1080][ext=mp4]/best" ;;
        3) FORMAT_STRING="bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/best[height<=720][ext=mp4]/best" ;;
        4) FORMAT_STRING="bestvideo[height<=480][ext=mp4]+bestaudio[ext=m4a]/best[height<=480][ext=mp4]/best" ;;
        *)
            echo "⚠️  $(msg "msg_quality_invalid") '$QUALITY_CHOICE', $(msg "msg_quality_using_default")"
            FORMAT_STRING="bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
            ;;
    esac
fi

# TikTok
if [[ "$SOURCE" == "TikTok" ]] && [ "$DOWNLOAD_TYPE" = "video" ]; then
    YTDLP_EXTRA_ARGS="$YTDLP_EXTRA_ARGS --remux-video mp4"
    FORMAT_STRING="best"
fi

# Counter
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DATE_PREFIX=$(date +"%Y-%m-%d")

{
    flock -x 200
    rotate_log
    COUNTER=$(find "$TARGET_DIR" -maxdepth 1 -type f -name "${DATE_PREFIX}-${SOURCE}-[0-9][0-9][0-9].${FILE_EXT}" 2>/dev/null | wc -l)
    COUNTER=$((COUNTER + 1))
    COUNTER_PAD=$(printf "%03d" "$COUNTER")
} 200>"$LOG_LOCK"

FILENAME="${TIMESTAMP}-${SOURCE}-${COUNTER_PAD}.${FILE_EXT}"
TEMP_PATTERN="${TIMESTAMP}-${SOURCE}-${COUNTER_PAD}-dl"
TEMP_FILE="$TARGET_DIR/${TEMP_PATTERN}"
FULLPATH="$TARGET_DIR/$FILENAME"

echo ""
echo "📥 Download: $SOURCE ($DOWNLOAD_TYPE)"
echo "   Link: $LINK"
if [ "$DOWNLOAD_TYPE" = "video" ]; then
    echo "   $([ "$SCRIPT_LANG" = "de" ] && echo "Qualität: Option" || echo "Quality: Option") ${QUALITY_CHOICE:-1}"
fi
echo "   → $FILENAME"
echo ""

# yt-dlp
YTDLP_ARGS=(
    --no-playlist
    --restrict-filenames
    -N 4
    --add-metadata
    --progress
    -f "$FORMAT_STRING"
    --no-warnings
    -o "$TEMP_FILE"
)

if [ -n "$YTDLP_EXTRA_ARGS" ]; then
    IFS=' ' read -ra EXTRA_ARRAY <<< "$YTDLP_EXTRA_ARGS"
    YTDLP_ARGS+=("${EXTRA_ARRAY[@]}")
fi

YTDLP_ARGS+=("$LINK")

echo "⏬ $(msg "msg_download_starting")"
echo ""

if ! timeout "$DOWNLOAD_TIMEOUT" yt-dlp "${YTDLP_ARGS[@]}"; then
    echo ""
    echo "❌ $(msg "error_download_failed")" >&2
    notify "$(msg "notif_failed")" "$SOURCE ($DOWNLOAD_TYPE)"
    exit 1
fi

echo ""

# Temp-File verschieben
shopt -s nullglob
TEMP_FILES=("$TARGET_DIR/${TEMP_PATTERN}".*)
shopt -u nullglob

if [ ${#TEMP_FILES[@]} -gt 0 ] && [ -s "${TEMP_FILES[0]}" ]; then
    DOWNLOADED_FILE="${TEMP_FILES[0]}"
    mv "$DOWNLOADED_FILE" "$FULLPATH"
else
    echo "❌ $(msg "error_file_empty")" >&2
    echo "   $(msg "msg_searching") $TARGET_DIR/${TEMP_PATTERN}.*" >&2
    ls -lh "$TARGET_DIR/${TEMP_PATTERN}".* 2>/dev/null || echo "   $(msg "msg_not_found")" >&2
    notify "$(msg "notif_corrupt")" "$SOURCE ($DOWNLOAD_TYPE)"
    exit 1
fi

# Erfolg
if [ -s "$FULLPATH" ]; then
    {
        flock -x 200
        echo "$LINK" >> "$LOG_FILE"
    } 200>"$LOG_LOCK"

    FILE_SIZE=$(du -h "$FULLPATH" | cut -f1)
    echo ""
    echo "✅ $(msg "msg_success") $FILENAME ($FILE_SIZE)"
    notify "$(msg "notif_success")" "$FILENAME ($FILE_SIZE)"

    if [ "$EDIT" = yes ]; then
        echo "🎬 $(msg "msg_starting_shotcut")"
        if [ "$EDIT_BACKGROUND" = yes ]; then
            shotcut "$FULLPATH" >/dev/null 2>&1 &
            echo "   $(msg "msg_background")"
        else
            shotcut "$FULLPATH"
        fi
    fi
else
    echo "❌ $(msg "error_file_empty"), $([ "$SCRIPT_LANG" = "de" ] && echo "wird gelöscht" || echo "deleting")." >&2
    rm -f "$FULLPATH"
    notify "$(msg "notif_error")" "$(msg "notif_empty")"
    exit 1
fi
