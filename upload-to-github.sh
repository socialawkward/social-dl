#!/bin/bash

# GitHub Release Upload Script für Social-DL
# Erstellt tar.gz + self-contained app, lädt hoch und erstellt GitHub Release
# Version: 4.2
#
# New in v4.2:
# - YAD Support: Auto-detects YAD for enhanced UI (optional)
# - Zenity Fallback: Works without YAD (backward compatible)
# - Modular UI: Separate UI modules for better maintainability
# - UI Test Script: test-mobile-ui.sh for GUI testing
#
# Breaking Changes v4.0:
# - README.md is now English (was German)
# - README.de.md is now German (was README.md)
# - Package files updated accordingly
#
# Features:
# - Smartphone-inspired design (420x520 - wider & shorter)
# - Shortened descriptions for better fit
# - DE/EN language switcher
# - Mobile-friendly interface
# - App included in tar.gz
# - App uploaded to GitHub
# - Fixed: curl argument limit via temp file
# - Fixed: GUI icons & sorting with ID column
# - Added: Window icon (applications-multimedia)
# - Added: .desktop launcher for app
# - Added: DEVELOPMENT-NOTES.md to package
# - Fixed: Delete old release assets before re-uploading
#
# Usage:
#   ./upload-to-github.sh              # Upload + create release + mobile app (branch: main)

set -o errexit
set -o nounset
set -o pipefail

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Icons
ICON_CHECK="✓"
ICON_CROSS="✗"
ICON_INFO="ℹ"
ICON_UPLOAD="⬆"
ICON_PACKAGE="📦"

# GitHub Config
GITHUB_USER="socialawkward"
GITHUB_REPO="social-dl"
GITHUB_API="https://api.github.com"

# Dateien für tar.gz
FILES_TO_PACK=(
    "social-dl.sh"
    "install.sh"
    "install-gui.sh"
    "uninstall-gui.sh"
    "README.md"
    "README.de.md"
    "CHANGELOG.md"
    "DEVELOPMENT-NOTES.md"
    "config.example"
    "settings-handlers.sh"
    "ui/mobile-app-ui-yad-tabs.sh"
    "ui/mobile-app-ui-zenity.sh"
    "ui/test-mobile-ui.sh"
    "LICENSE"
    "social-dl-installer.desktop"
    "social-dl-uninstaller.desktop"
)

# Script-Verzeichnis
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

print_success() {
    echo -e "${GREEN}${ICON_CHECK}${NC} $1"
}

print_error() {
    echo -e "${RED}${ICON_CROSS}${NC} $1" >&2
}

print_info() {
    echo -e "${BLUE}${ICON_INFO}${NC} $1"
}

print_header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════╗"
    echo "║                                        ║"
    echo "║  ${ICON_PACKAGE} Social-DL GitHub Upload      ║"
    echo "║                                        ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Cleanup alte Builds
cleanup_old_builds() {
    print_info "Cleaning up old builds..."
    local removed=0
    
    # Lösche alte Apps
    for file in social-dl-v*-app.sh; do
        if [ -f "$file" ]; then
            rm -f "$file"
            ((removed++)) || true
        fi
    done
    
    # Lösche alte .desktop Files
    for file in social-dl-v*.desktop; do
        if [ -f "$file" ]; then
            rm -f "$file"
            ((removed++)) || true
        fi
    done
    
    if [ $removed -gt 0 ]; then
        print_success "Removed $removed old build(s)"
    else
        print_info "No old builds found"
    fi
}

# Zeige Menü wenn kein Flag gegeben
show_menu() {
    echo "" >&2
    echo "╔════════════════════════════════════════╗" >&2
    echo "║  What do you want to do?               ║" >&2
    echo "╚════════════════════════════════════════╝" >&2
    echo "" >&2
    echo "1) 🔨 Build locally only (for testing)" >&2
    echo "   → Creates app + tarball" >&2
    echo "   → No GitHub upload" >&2
    echo "   → Fast testing" >&2
    echo "" >&2
    echo "2) 🚀 Full release (build + upload)" >&2
    echo "   → Creates app + tarball" >&2
    echo "   → Uploads to GitHub" >&2
    echo "   → Creates release" >&2
    echo "" >&2
    read -p "Choose [1-2]: " -n 1 -r choice
    echo "" >&2
    
    case "$choice" in
        1)
            echo "local"
            ;;
        2)
            echo "upload"
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
}


# Version aus social-dl.sh auslesen
get_version() {
    if [ ! -f "social-dl.sh" ]; then
        print_error "social-dl.sh not found!"
        exit 1
    fi
    
    VERSION=$(grep '^SCRIPT_VERSION=' social-dl.sh | cut -d'"' -f2)
    
    if [ -z "$VERSION" ]; then
        print_error "Could not extract version from social-dl.sh"
        exit 1
    fi
    
    echo "$VERSION"
}

# GitHub Token prüfen/laden - SICHER
check_github_token() {
    local token_file="$HOME/.config/social-dl/github-token"
    local token_dir
    token_dir="$(dirname "$token_file")"

    if [ -f "$token_file" ]; then
        # Sicherheitscheck: Keine Symlinks erlauben
        if [ -L "$token_file" ]; then
            print_error "Token file must not be a symlink! Removing..."
            rm -f "$token_file"
        else
            # Prüfe Berechtigungen
            local file_perms
            file_perms=$(stat -c %a "$token_file" 2>/dev/null || echo "644")
            if [ "$file_perms" != "600" ]; then
                print_info "Fixing token file permissions..."
                chmod 600 "$token_file"
            fi

            GITHUB_TOKEN=$(cat "$token_file")
            if [ -n "$GITHUB_TOKEN" ]; then
                print_success "GitHub token loaded from $token_file"
                return 0
            fi
        fi
    fi

    echo ""
    print_info "GitHub Personal Access Token needed"
    echo "Create one at: https://github.com/settings/tokens"
    echo "Required permissions: repo (full control)"
    echo ""
    read -rsp "Enter your GitHub token: " GITHUB_TOKEN
    echo ""

    if [ -z "$GITHUB_TOKEN" ]; then
        print_error "No token provided"
        exit 1
    fi

    # Token ATOMAR speichern (erst Datei mit korrekten Rechten erstellen)
    mkdir -p "$token_dir"
    chmod 700 "$token_dir"

    # Temp-Datei mit sicheren Berechtigungen erstellen
    local temp_token
    temp_token=$(mktemp "$token_dir/.token-XXXXXX")
    chmod 600 "$temp_token"
    echo "$GITHUB_TOKEN" > "$temp_token"

    # Atomar verschieben
    mv "$temp_token" "$token_file"

    print_success "Token saved securely to $token_file"
}

# Sichere API-Aufruf-Funktion (Token nicht in Prozessliste)
github_api() {
    local method="$1"
    local endpoint="$2"
    local data="${3:-}"

    if [ -n "$data" ]; then
        curl -s -X "$method" \
            -H "Content-Type: application/json" \
            -H @- \
            -d "$data" \
            "${GITHUB_API}${endpoint}" <<< "Authorization: token $GITHUB_TOKEN"
    else
        curl -s -X "$method" \
            -H @- \
            "${GITHUB_API}${endpoint}" <<< "Authorization: token $GITHUB_TOKEN"
    fi
}

# Sichere API-Aufruf mit Datei-Upload
github_api_file() {
    local method="$1"
    local endpoint="$2"
    local file="$3"

    curl -s -X "$method" \
        -H "Content-Type: application/json" \
        -H @- \
        --data-binary "@$file" \
        "${GITHUB_API}${endpoint}" <<< "Authorization: token $GITHUB_TOKEN"
}

# Debug-Flag (setze DEBUG=1 für Ausgaben)
DEBUG="${DEBUG:-0}"

debug_log() {
    [[ "$DEBUG" == "1" ]] && echo "DEBUG: $*" >&2
}

# Default Branch ermitteln (main oder master)
get_default_branch() {
    local response
    response=$(github_api "GET" "/repos/$GITHUB_USER/$GITHUB_REPO")
    
    # Debug: Zeige Antwort wenn leer
    if [ -z "$response" ]; then
        echo "Empty response from GitHub API" >&2
        echo "Falling back to 'main'" >&2
        echo "main"
        return
    fi
    
    # Prüfe auf Fehler
    if echo "$response" | grep -q '"message"'; then
        local error_msg
        error_msg=$(echo "$response" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
        echo "GitHub API Error: $error_msg" >&2
        echo "Falling back to 'main'" >&2
        echo "main"
        return
    fi
    
    local branch
    branch=$(echo "$response" | grep -o '"default_branch":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$branch" ]; then
        echo "Could not parse branch from response" >&2
        echo "Falling back to 'main'" >&2
        echo "main"
        return
    fi
    
    echo "$branch"
}

# Prüfe ob Datei auf GitHub existiert und ob sie sich geändert hat
check_file_changed() {
    local file="$1"
    local version="$2"
    local branch="$3"

    debug_log "check_file_changed: file='$file' branch='$branch'"

    # Hole SHA der Datei auf GitHub (falls existiert) - SICHER
    local response
    response=$(github_api "GET" "/repos/$GITHUB_USER/$GITHUB_REPO/contents/$file?ref=$branch")

    debug_log "API Response (first 200 chars): ${response:0:200}"

    # Prüfe ob Datei existiert
    if echo "$response" | grep -q '"message": "Not Found"'; then
        debug_log "File not found (NEW)"
        echo "NEW"
        return
    fi

    # Prüfe auf andere Fehler
    if echo "$response" | grep -q '"message"' && ! echo "$response" | grep -q '"sha"'; then
        debug_log "Error but no sha found (NEW)"
        echo "NEW"
        return
    fi

    # Hole SHA der Remote-Datei
    local remote_sha
    remote_sha=$(echo "$response" | grep -o '"sha"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)".*/\1/')

    if [ -z "$remote_sha" ]; then
        debug_log "No SHA extracted (NEW)"
        echo "NEW"
        return
    fi

    debug_log "Remote SHA found: $remote_sha"

    # Berechne lokalen SHA
    local local_sha
    if command -v git >/dev/null 2>&1; then
        local_sha=$(git hash-object "$file" 2>/dev/null || echo "")
    fi

    # Fallback: Berechne SHA manuell
    if [ -z "$local_sha" ]; then
        local_sha=$(printf "blob %s\0" "$(wc -c < "$file")" | cat - "$file" | sha1sum | cut -d' ' -f1)
    fi

    debug_log "Local SHA: $local_sha"

    if [ "$remote_sha" = "$local_sha" ]; then
        debug_log "Files match (UNCHANGED)"
        echo "UNCHANGED"
    else
        debug_log "Files differ (CHANGED)"
        echo "CHANGED:$remote_sha"
    fi
}

# Datei auf GitHub hochladen/aktualisieren
upload_file() {
    local file="$1"
    local version="$2"
    local branch="$3"
    local commit_message="$4"
    local sha="$5"

    print_info "Uploading $file..."

    debug_log "upload_file: file='$file' sha='$sha' has_sha='$([ -n "$sha" ] && echo yes || echo no)'"

    # Datei als base64 kodieren
    local content
    content=$(base64 -w 0 "$file" 2>/dev/null || base64 "$file")

    # JSON für API erstellen - SICHER mit mktemp
    local json_file
    json_file=$(mktemp /tmp/github-upload-XXXXXX.json)
    chmod 600 "$json_file"

    # Sicheres JSON-Escaping mit jq (falls verfügbar) oder manuell
    if command -v jq >/dev/null 2>&1; then
        if [ -n "$sha" ]; then
            jq -n \
                --arg msg "$commit_message" \
                --arg content "$content" \
                --arg branch "$branch" \
                --arg sha "$sha" \
                '{message: $msg, content: $content, branch: $branch, sha: $sha}' > "$json_file"
        else
            jq -n \
                --arg msg "$commit_message" \
                --arg content "$content" \
                --arg branch "$branch" \
                '{message: $msg, content: $content, branch: $branch}' > "$json_file"
        fi
    else
        # Fallback: Manuelles Escaping (erweitert für alle kritischen Zeichen)
        local escaped_message
        escaped_message="${commit_message//\\/\\\\}"  # Backslash zuerst
        escaped_message="${escaped_message//\"/\\\"}"  # Quotes
        escaped_message="${escaped_message//$'\n'/\\n}"  # Newlines
        escaped_message="${escaped_message//$'\r'/\\r}"  # Carriage Return
        escaped_message="${escaped_message//$'\t'/\\t}"  # Tabs

        if [ -n "$sha" ]; then
            debug_log "Creating JSON with SHA (manual escaping)"
            cat > "$json_file" <<EOF
{
  "message": "$escaped_message",
  "content": "$content",
  "branch": "$branch",
  "sha": "$sha"
}
EOF
        else
            debug_log "Creating JSON WITHOUT SHA (manual escaping)"
            cat > "$json_file" <<EOF
{
  "message": "$escaped_message",
  "content": "$content",
  "branch": "$branch"
}
EOF
        fi
    fi

    debug_log "JSON size: $(wc -c < "$json_file") bytes"

    # Upload via sichere API-Funktion
    local response
    response=$(github_api_file "PUT" "/repos/$GITHUB_USER/$GITHUB_REPO/contents/$file" "$json_file")

    # Cleanup
    rm -f "$json_file"

    if echo "$response" | grep -q '"sha"'; then
        print_success "$file uploaded successfully"
        return 0
    else
        print_error "Failed to upload $file"
        # Keine sensiblen Daten in Fehlermeldung zeigen
        if command -v jq >/dev/null 2>&1; then
            echo "$response" | jq -r '.message // "Unknown error"' 2>/dev/null || echo "Upload failed"
        else
            echo "Upload failed (enable DEBUG=1 for details)"
        fi
        debug_log "Full response: $response"
        return 1
    fi
}

# Erstelle tar.gz
create_tarball() {
    local version="$1"
    local tarball="social-dl-v${version}.tar.gz"
    local app_file="social-dl-v${version}-app.sh"
    
    print_info "Creating $tarball..." >&2
    
    # Prüfe ob alle Dateien existieren
    for file in "${FILES_TO_PACK[@]}"; do
        if [ ! -f "$file" ]; then
            print_error "File not found: $file" >&2
            exit 1
        fi
    done
    
    # Prüfe ob App existiert
    if [ ! -f "$app_file" ]; then
        print_error "App file not found: $app_file" >&2
        exit 1
    fi
    
    # Erstelle tar.gz (mit App!)
    tar -czf "$tarball" "${FILES_TO_PACK[@]}" "$app_file"
    
    if [ -f "$tarball" ]; then
        local size
        size=$(du -h "$tarball" | cut -f1)
        print_success "Created $tarball ($size, includes app)" >&2
        echo "$tarball"
    else
        print_error "Failed to create tarball" >&2
        exit 1
    fi
}

# Erstelle Self-Contained App
create_app() {
    local version="$1"
    local app_file="social-dl-v${version}-app.sh"
    
    print_info "Creating $app_file..." >&2
    
    # Prüfe ob alle Dateien existieren
    for file in "${FILES_TO_PACK[@]}"; do
        if [ ! -f "$file" ]; then
            print_error "File not found: $file" >&2
            exit 1
        fi
    done
    
    # Erstelle App Header
    cat > "$app_file" << 'HEADER_EOF'
#!/usr/bin/env bash
# Social-DL All-in-One App
# Version: __VERSION__
# Auto-generated - Edit source files instead!
# Repository: https://github.com/socialawkward/social-dl

set -o errexit
set -o nounset
set -o pipefail

# Farben
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Temporäres Arbeitsverzeichnis
TEMP_DIR=$(mktemp -d /tmp/social-dl-app-XXXXXX)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo -e "${BLUE}📦 Social-DL App v__VERSION__${NC}"
echo "Extracting files..."

HEADER_EOF

    # Ersetze Version
    sed -i "s/__VERSION__/$version/g" "$app_file"
    
    # Embed alle Dateien als Base64
    for file in "${FILES_TO_PACK[@]}"; do
        print_info "  Embedding $file..." >&2
        
        # Get parent directory and create safe EOF tag
        local file_dir
        file_dir=$(dirname "$file")
        local eof_tag
        eof_tag=$(echo "$file" | tr './-' '___')
        
        cat >> "$app_file" << EOF

# === $file ===
mkdir -p "\$TEMP_DIR/$file_dir"
cat << 'EOF_${eof_tag}' | base64 -d > "\$TEMP_DIR/$file"
$(base64 -w 0 "$file")
EOF_${eof_tag}
EOF
        
        # Mache Scripts ausführbar
        if [[ "$file" == *.sh ]]; then
            echo "chmod +x \"\$TEMP_DIR/$file\"" >> "$app_file"
        fi
    done
    
    # Füge GUI Menu hinzu
    cat >> "$app_file" << 'MENU_EOF'

# === GUI MENU ===

if ! command -v yad >/dev/null 2>&1 && ! command -v zenity >/dev/null 2>&1; then
    echo "Error: Neither YAD nor Zenity installed"
    echo "Install YAD (recommended): sudo pacman -S yad"
    echo "OR Zenity (fallback): sudo pacman -S zenity"
    exit 1
fi

cd "$TEMP_DIR"

# Standard-Sprache: Deutsch
LANG_MODE="de"

# === UI MODULE SELECTION ===
# Auto-detect YAD vs Zenity and embed appropriate UI module

if command -v yad >/dev/null 2>&1; then
    # YAD available - use enhanced UI with separate windows
    UI_TOOL="yad"
    
    # Source the settings handlers (must be before UI module)
    source "$TEMP_DIR/settings-handlers.sh"
    
    # Export TEMP_DIR so handlers can access it
    export TEMP_DIR
    
    # Source the YAD UI module
    source "$TEMP_DIR/ui/mobile-app-ui-yad-tabs.sh"
else
    # YAD not available - use Zenity fallback
    UI_TOOL="zenity"
    
    # Source the Zenity UI module
    source "$TEMP_DIR/ui/mobile-app-ui-zenity.sh"
fi

# === FUTURE FEATURE: BATCH DROP ZONE (Hidden Placeholder) ===
# This is a placeholder for future batch download functionality
# Will allow drag & drop of .txt or .md files containing URLs
# Implementation: Add zenity --file-selection with --multiple flag
# Parse each line of file as URL and pass to social-dl.sh
# Status: Not yet implemented - placeholder for v2.6+
# ============================================================

# Get script version
VERSION="__VERSION__"

while true; do
    CHOICE=$(show_menu "$LANG_MODE" "$VERSION")
    
    # Exit wenn Cancel gedrückt
    [ $? -ne 0 ] && exit 0
    
    case "$CHOICE" in
        "1")  # Installieren
            if bash "./install-gui.sh"; then
                if [ "$LANG_MODE" = "de" ]; then
                    yad --info --image="dialog-information" --text="<span size='large'>✅</span>\n\n<b>Installation erfolgreich!</b>\n\nSocial-DL wurde installiert." --width=320 --title="Erfolg" --button="OK:0" 2>/dev/null || true
                else
                    yad --info --image="dialog-information" --text="<span size='large'>✅</span>\n\n<b>Installation successful!</b>\n\nSocial-DL has been installed." --width=320 --title="Success" --button="OK:0" 2>/dev/null || true
                fi
            else
                if [ "$LANG_MODE" = "de" ]; then
                    yad --error --image="dialog-error" --text="<span size='large'>❌</span>\n\n<b>Installation fehlgeschlagen!</b>\n\nBitte Fehlermeldung prüfen." --width=320 --title="Fehler" --button="OK:0" 2>/dev/null || true
                else
                    yad --error --image="dialog-error" --text="<span size='large'>❌</span>\n\n<b>Installation failed!</b>\n\nPlease check error messages." --width=320 --title="Error" --button="OK:0" 2>/dev/null || true
                fi
            fi
            ;;
        "2")  # Deinstallieren
            if bash "./uninstall-gui.sh"; then
                if [ "$LANG_MODE" = "de" ]; then
                    yad --info --image="dialog-information" --text="<span size='large'>✅</span>\n\n<b>Deinstallation erfolgreich!</b>\n\nSocial-DL wurde entfernt." --width=320 --title="Erfolg" --button="OK:0" 2>/dev/null || true
                else
                    yad --info --image="dialog-information" --text="<span size='large'>✅</span>\n\n<b>Uninstallation successful!</b>\n\nSocial-DL has been removed." --width=320 --title="Success" --button="OK:0" 2>/dev/null || true
                fi
            else
                if [ "$LANG_MODE" = "de" ]; then
                    yad --error --image="dialog-error" --text="<span size='large'>❌</span>\n\n<b>Deinstallation fehlgeschlagen!</b>\n\nBitte Fehlermeldung prüfen." --width=320 --title="Fehler" --button="OK:0" 2>/dev/null || true
                else
                    yad --error --image="dialog-error" --text="<span size='large'>❌</span>\n\n<b>Uninstallation failed!</b>\n\nPlease check error messages." --width=320 --title="Error" --button="OK:0" 2>/dev/null || true
                fi
            fi
            ;;
        "3")  # README DE
            yad --text-info --filename="./README.de.md" \
                --width=900 --height=700 \
                --title="📖 README (Deutsch)" \
                --button="Schließen:0" \
                --fontname="Monospace 10" 2>/dev/null || true
            ;;
        "4")  # README EN
            yad --text-info --filename="./README.md" \
                --width=900 --height=700 \
                --title="📘 README (English)" \
                --button="Close:0" \
                --fontname="Monospace 10" 2>/dev/null || true
            ;;
        "5")  # Changelog
            if [ "$LANG_MODE" = "de" ]; then
                yad --text-info --filename="./CHANGELOG.md" \
                    --width=900 --height=700 \
                    --title="📋 Changelog" \
                    --button="Schließen:0" \
                    --fontname="Monospace 10" 2>/dev/null || true
            else
                yad --text-info --filename="./CHANGELOG.md" \
                    --width=900 --height=700 \
                    --title="📋 Changelog" \
                    --button="Close:0" \
                    --fontname="Monospace 10" 2>/dev/null || true
            fi
            ;;
        "6")  # Info
            if [ "$LANG_MODE" = "de" ]; then
                yad --info --width=400 --height=450 --image="help-about" --title="ℹ️  Über Social-DL" \
                    --text="<span size='x-large'><b>Social-DL</b></span>
<span size='small'>Version 2.8.0</span>

<b>Universal Video &amp; Audio Downloader</b>
für Social Media Plattformen

<b>📱 Unterstützte Plattformen:</b>
• Instagram • Twitter / X • YouTube
• Reddit • TikTok

<b>💻 Entwickelt mit ❤️:</b>
• <b>socialawkward</b> (Lead Developer)
• Grok (Fundament)
• Claude (Code-Engine)
• Perplexity (Review)

<b>🔗 Repository:</b>
<span foreground='#0969DA'>github.com/socialawkward/social-dl</span>

<b>📄 Lizenz:</b> MIT License" \
                    --button="OK:0" 2>/dev/null || true
            else
                yad --info --width=400 --height=450 --image="help-about" --title="ℹ️  About Social-DL" \
                    --text="<span size='x-large'><b>Social-DL</b></span>
<span size='small'>Version 2.8.0</span>

<b>Universal Video &amp; Audio Downloader</b>
for Social Media Platforms

<b>📱 Supported Platforms:</b>
• Instagram • Twitter / X • YouTube
• Reddit • TikTok

<b>💻 Developed with ❤️:</b>
• <b>socialawkward</b> (Lead Developer)
• Grok (Foundation)
• Claude (Code Engine)
• Perplexity (Review)

<b>🔗 Repository:</b>
<span foreground='#0969DA'>github.com/socialawkward/social-dl</span>

<b>📄 License:</b> MIT License" \
                    --button="OK:0" 2>/dev/null || true
            fi
            ;;
        "7")  # Ausführen / Run now
            # Finde Terminal
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
                        konsole --workdir "$TEMP_DIR" -e bash -c "./social-dl.sh; echo ''; read -p 'Enter zum Schließen... / Press Enter to close...'"
                        ;;
                    gnome-terminal|xfce4-terminal)
                        $TERMINAL --working-directory="$TEMP_DIR" -- bash -c "./social-dl.sh; echo ''; read -p 'Enter zum Schließen... / Press Enter to close...'"
                        ;;
                    *)
                        $TERMINAL -e bash -c "cd '$TEMP_DIR' && ./social-dl.sh; echo ''; read -p 'Enter zum Schließen... / Press Enter to close...'"
                        ;;
                esac
            else
                if [ "$LANG_MODE" = "de" ]; then
                    yad --error --width=360 --image="dialog-error" --title="Fehler" \
                        --text="<b>Kein Terminal gefunden!</b>\n\nBitte führe social-dl.sh manuell aus:\n\n<tt>$TEMP_DIR/social-dl.sh</tt>" \
                        --button="OK:0" 2>/dev/null || true
                else
                    yad --error --width=360 --image="dialog-error" --title="Error" \
                        --text="<b>No terminal found!</b>\n\nPlease run social-dl.sh manually:\n\n<tt>$TEMP_DIR/social-dl.sh</tt>" \
                        --button="OK:0" 2>/dev/null || true
                fi
            fi
            ;;
        "8")  # Settings (handled by show_menu in UI module)
            # This is handled by the UI module's show_menu function
            # If we reach here, something went wrong - just continue
            continue
            ;;
        "9")  # Sprachwechsel / Language switch
            if [ "$LANG_MODE" = "de" ]; then
                LANG_MODE="en"
            else
                LANG_MODE="de"
            fi
            # Check if we should stay in settings
            if [ "${STAY_IN_SETTINGS:-0}" = "1" ]; then
                STAY_IN_SETTINGS=0  # Reset flag
                # Settings will reopen automatically
            fi
            ;;
        
        # === SETTINGS MENU ACTIONS (100-199) ===
        # These are now handled by the UI module calling handler functions
        # No case statements needed here anymore - handlers keep settings loop open
        "100"|"101"|"102"|"103"|"104"|"105")
            # Should not reach here - handled by UI module
            continue
            ;;
        
        
        *)  # Unknown or Exit
            exit 0
            ;;
    esac
done
done
MENU_EOF

    # Ersetze Version im Menu
    sed -i "s/__VERSION__/$version/g" "$app_file"
    
    chmod +x "$app_file"
    
    # Erstelle .desktop Datei für die App
    local desktop_file="social-dl-v${version}-app.desktop"
    cat > "$desktop_file" << DESKTOP_EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Social-DL App v$version
Comment=Universal Social Media Downloader (All-in-One)
Exec=bash "$(pwd)/$app_file"
Icon=applications-multimedia
Terminal=false
Categories=AudioVideo;Network;
DESKTOP_EOF
    
    chmod +x "$desktop_file"
    
    if [ -f "$app_file" ]; then
        local size
        size=$(du -h "$app_file" | cut -f1)
        print_success "Created $app_file ($size)" >&2
        print_success "Created $desktop_file (launcher)" >&2
        echo "$app_file"
    else
        print_error "Failed to create app" >&2
        exit 1
    fi
}

# Automatisch erkenne Änderungen
detect_changes() {
    local file="$1"
    
    # Einfache Heuristik basierend auf git log (falls verfügbar)
    if command -v git >/dev/null 2>&1 && [ -d .git ]; then
        local last_commit
        last_commit=$(git log -1 --pretty=format:"%s" -- "$file" 2>/dev/null)
        if [ -n "$last_commit" ]; then
            echo "$last_commit"
            return
        fi
    fi
    
    # Fallback: Generische Nachricht
    echo "Updated $file"
}

# GitHub Release erstellen
create_github_release() {
    local version="$1"
    local tarball="$2"
    local app_file="$3"
    local tag="v$version"
    
    # Prüfe ob Release bereits existiert
    local existing_release
    existing_release=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "$GITHUB_API/repos/$GITHUB_USER/$GITHUB_REPO/releases/tags/$tag")
    
    if echo "$existing_release" | grep -q '"id"'; then
        print_info "Release $tag already exists, updating..."
        local release_id
        release_id=$(echo "$existing_release" | grep -o '"id"[[:space:]]*:[[:space:]]*[0-9]*' | head -1 | grep -o '[0-9]*')
        
        # Update Release
        local release_notes
        release_notes=$(generate_release_notes "$version")
        
        curl -s -X PATCH \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Content-Type: application/json" \
            -d "$(jq -n --arg body "$release_notes" '{body: $body}')" \
            "$GITHUB_API/repos/$GITHUB_USER/$GITHUB_REPO/releases/$release_id" > /dev/null
        
        print_success "Release $tag updated"
        
        # Lösche alte Assets (falls vorhanden)
        print_info "Checking for existing assets..."
        local assets_response
        assets_response=$(curl -s \
            -H "Authorization: token $GITHUB_TOKEN" \
            "$GITHUB_API/repos/$GITHUB_USER/$GITHUB_REPO/releases/$release_id/assets")
        
        # Lösche tar.gz Asset wenn vorhanden
        local tarball_asset_id
        tarball_asset_id=$(echo "$assets_response" | grep -B 3 "\"name\"[[:space:]]*:[[:space:]]*\"$tarball\"" | grep -o '"id"[[:space:]]*:[[:space:]]*[0-9]*' | head -1 | grep -o '[0-9]*')
        if [ -n "$tarball_asset_id" ]; then
            print_info "Deleting old $tarball asset..."
            curl -s -X DELETE \
                -H "Authorization: token $GITHUB_TOKEN" \
                "$GITHUB_API/repos/$GITHUB_USER/$GITHUB_REPO/releases/assets/$tarball_asset_id" > /dev/null
        fi
        
        # Lösche app Asset wenn vorhanden
        local app_asset_id
        app_asset_id=$(echo "$assets_response" | grep -B 3 "\"name\"[[:space:]]*:[[:space:]]*\"$app_file\"" | grep -o '"id"[[:space:]]*:[[:space:]]*[0-9]*' | head -1 | grep -o '[0-9]*')
        if [ -n "$app_asset_id" ]; then
            print_info "Deleting old $app_file asset..."
            curl -s -X DELETE \
                -H "Authorization: token $GITHUB_TOKEN" \
                "$GITHUB_API/repos/$GITHUB_USER/$GITHUB_REPO/releases/assets/$app_asset_id" > /dev/null
        fi
        
        # Upload Assets (jetzt ohne Konflikt!)
        print_info "Uploading fresh assets to release..."
        
        # Upload tarball
        curl -s -X POST \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Content-Type: application/gzip" \
            --data-binary "@$tarball" \
            "https://uploads.github.com/repos/$GITHUB_USER/$GITHUB_REPO/releases/$release_id/assets?name=$tarball" > /dev/null
        
        # Upload app
        curl -s -X POST \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Content-Type: application/x-sh" \
            --data-binary "@$app_file" \
            "https://uploads.github.com/repos/$GITHUB_USER/$GITHUB_REPO/releases/$release_id/assets?name=$app_file" > /dev/null
        
        print_success "Assets uploaded"
    else
        print_info "Creating new release $tag..."
        
        # Erstelle Release Notes
        local release_notes
        release_notes=$(generate_release_notes "$version")
        
        # Erstelle Release
        local response
        response=$(curl -s -X POST \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Content-Type: application/json" \
            -d "$(jq -n \
                --arg tag "$tag" \
                --arg name "Version $version" \
                --arg body "$release_notes" \
                --arg target "main" \
                '{tag_name: $tag, name: $name, body: $body, draft: false, prerelease: false, target_commitish: $target}')" \
            "$GITHUB_API/repos/$GITHUB_USER/$GITHUB_REPO/releases")
        
        if echo "$response" | grep -q '"id"'; then
            print_success "Release $tag created"
            
            # Upload Assets
            local release_id
            release_id=$(echo "$response" | grep -o '"id"[[:space:]]*:[[:space:]]*[0-9]*' | head -1 | grep -o '[0-9]*')
            
            print_info "Uploading $tarball as release asset..."
            curl -s -X POST \
                -H "Authorization: token $GITHUB_TOKEN" \
                -H "Content-Type: application/gzip" \
                --data-binary "@$tarball" \
                "https://uploads.github.com/repos/$GITHUB_USER/$GITHUB_REPO/releases/$release_id/assets?name=$tarball" > /dev/null
            
            print_info "Uploading $app_file as release asset..."
            curl -s -X POST \
                -H "Authorization: token $GITHUB_TOKEN" \
                -H "Content-Type: application/x-sh" \
                --data-binary "@$app_file" \
                "https://uploads.github.com/repos/$GITHUB_USER/$GITHUB_REPO/releases/$release_id/assets?name=$app_file" > /dev/null
            
            print_success "All assets uploaded"
        else
            print_error "Failed to create release"
            echo "DEBUG: API Response:" >&2
            echo "$response" | jq '.' 2>/dev/null || echo "$response" >&2
        fi
    fi
}

# Generiere Release Notes
generate_release_notes() {
    local version="$1"
    
    # Prüfe ob es spezifische Release-Notes gibt
    if [ -f "RELEASE-NOTES-v${version}.md" ]; then
        print_info "Using RELEASE-NOTES-v${version}.md"
        cat "RELEASE-NOTES-v${version}.md"
        return
    fi
    
    # Prüfe ob es GITHUB-RELEASE-DESCRIPTION gibt
    if [ -f "GITHUB-RELEASE-DESCRIPTION.md" ]; then
        print_info "Using GITHUB-RELEASE-DESCRIPTION.md"
        cat "GITHUB-RELEASE-DESCRIPTION.md"
        return
    fi
    
    # Versuche aus CHANGELOG.md zu extrahieren
    if [ -f "CHANGELOG.md" ]; then
        print_info "Extracting from CHANGELOG.md for v${version}"
        # Extrahiere den Abschnitt für diese Version
        local notes
        notes=$(awk "/^## \[${version}\]/,/^## \[/ {if (/^## \[${version}\]/) print; else if (/^## \[/) exit; else print}" CHANGELOG.md)
        if [ -n "$notes" ]; then
            echo "$notes"
            echo ""
            echo "---"
            echo "**Full Changelog**: https://github.com/$GITHUB_USER/$GITHUB_REPO/blob/main/CHANGELOG.md"
            return
        fi
    fi
    
    # Versuche aus git log zu lesen (falls vorhanden)
    if command -v git >/dev/null 2>&1 && [ -d .git ]; then
        local changes
        changes=$(git log --oneline --no-merges -10 2>/dev/null | head -5 | sed 's/^[a-f0-9]* /- /')
        if [ -n "$changes" ]; then
            echo "## Changes in v$version

$changes

---
**Full Changelog**: https://github.com/$GITHUB_USER/$GITHUB_REPO/commits/v$version"
            return
        fi
    fi
    
    # Fallback: Generische Notes
    echo "## Social-DL v$version

New release with improvements and bug fixes.

### Installation
Download \`social-dl-v$version.tar.gz\` or \`social-dl-v$version-app.sh\`

---
**Repository**: https://github.com/$GITHUB_USER/$GITHUB_REPO"
}

# Build lokal ohne Upload
build_local_only() {
    print_header
    
    # Version auslesen
    print_info "Reading version from social-dl.sh..."
    VERSION=$(get_version)
    print_success "Version: $VERSION"
    
    # Cleanup alte Builds
    echo ""
    cleanup_old_builds
    
    # App erstellen
    echo ""
    print_info "Creating self-contained app..."
    APP_FILE=$(create_app "$VERSION")
    
    # tar.gz erstellen
    echo ""
    print_info "Creating tarball..."
    TARBALL=$(create_tarball "$VERSION")
    
    # Zusammenfassung
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         Local Build Complete           ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""
    print_success "App: $APP_FILE"
    print_success "Tarball: $TARBALL"
    echo ""
    print_info "Ready for testing! Run:"
    echo -e "${GREEN}  ./$APP_FILE${NC}"
    echo ""
}

# Main
main() {
    # Parse command line arguments
    local mode=""
    
    case "${1:-}" in
        --local|--test)
            mode="local"
            ;;
        --upload|--release)
            mode="upload"
            ;;
        "")
            # No flag - show menu
            mode=$(show_menu)
            ;;
        *)
            print_error "Unknown option: $1"
            echo ""
            echo "Usage:"
            echo "  $0              # Interactive menu"
            echo "  $0 --local      # Build locally only (no upload)"
            echo "  $0 --test       # Same as --local"
            echo "  $0 --upload     # Full build + upload + release"
            echo "  $0 --release    # Same as --upload"
            exit 1
            ;;
    esac
    
    # Execute based on mode
    if [ "$mode" = "local" ]; then
        build_local_only
        exit 0
    fi
    
    # Continue with full upload flow
    print_header
    
    # Version auslesen
    print_info "Reading version from social-dl.sh..."
    VERSION=$(get_version)
    print_success "Version: $VERSION"
    
    # GitHub Token prüfen
    echo ""
    check_github_token
    
    # Branch ist immer main
    BRANCH="main"
    print_success "Branch: $BRANCH"
    
    # Cleanup alte Builds
    echo ""
    cleanup_old_builds
    
    # Prüfe ob Release bereits existiert
    echo ""
    print_info "Checking if release v$VERSION already exists..."
    local existing_release
    existing_release=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "$GITHUB_API/repos/$GITHUB_USER/$GITHUB_REPO/releases/tags/v$VERSION")
    
    if echo "$existing_release" | grep -q '"id"'; then
        print_info "Release v$VERSION already exists"
        
        # Frage User ob er fortfahren will
        echo ""
        echo -e "${YELLOW}⚠️  Release v$VERSION already exists on GitHub!${NC}"
        echo -e "${YELLOW}   This will UPDATE the existing release.${NC}"
        echo ""
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Aborted by user"
            exit 0
        fi
    else
        print_success "Version v$VERSION is NEW - will create release"
    fi
    
    # Alle Dateien hochladen
    echo ""
    print_info "Checking files on GitHub..."
    echo ""
    
    UPLOADED=0
    UPDATED=0
    UNCHANGED=0
    
    # Erst die einzelnen Dateien
    for file in "${FILES_TO_PACK[@]}"; do
        status=$(check_file_changed "$file" "$VERSION" "$BRANCH")
        
        if [ "$status" = "NEW" ]; then
            commit_msg="Add $file v$VERSION"
            upload_file "$file" "$VERSION" "$BRANCH" "$commit_msg" ""
            ((UPLOADED++)) || true
        elif [[ "$status" =~ ^CHANGED: ]]; then
            sha="${status#CHANGED:}"
            # Debug
            if [ -z "$sha" ]; then
                print_error "Empty SHA for $file, treating as NEW"
                commit_msg="Add $file v$VERSION"
                upload_file "$file" "$VERSION" "$BRANCH" "$commit_msg" ""
                ((UPLOADED++)) || true
            else
                change_reason=$(detect_changes "$file")
                commit_msg="Update $file in v$VERSION: $change_reason"
                upload_file "$file" "$VERSION" "$BRANCH" "$commit_msg" "$sha"
                ((UPDATED++)) || true
            fi
        else
            print_info "$file unchanged, skipping"
            ((UNCHANGED++)) || true
        fi
    done
    
    # App erstellen (immer neu) - ZUERST!
    echo ""
    print_info "Creating self-contained app..."
    APP_FILE=$(create_app "$VERSION")
    
    # tar.gz erstellen (immer neu) - mit App drin!
    echo ""
    print_info "Creating fresh tarball (including app)..."
    TARBALL=$(create_tarball "$VERSION")
    
    # tar.gz auf GitHub hochladen
    print_info "Uploading tarball to repository..."
    status=$(check_file_changed "$TARBALL" "$VERSION" "$BRANCH")
    
    if [ "$status" = "NEW" ]; then
        commit_msg="Release v$VERSION"
        upload_file "$TARBALL" "$VERSION" "$BRANCH" "$commit_msg" ""
    elif [[ "$status" =~ ^CHANGED: ]]; then
        sha="${status#CHANGED:}"
        commit_msg="Update release v$VERSION"
        upload_file "$TARBALL" "$VERSION" "$BRANCH" "$commit_msg" "$sha"
    else
        print_info "$TARBALL unchanged in repository, skipping upload"
    fi
    
    # App auf GitHub hochladen
    echo ""
    print_info "Uploading app to repository..."
    status=$(check_file_changed "$APP_FILE" "$VERSION" "$BRANCH")
    
    if [ "$status" = "NEW" ]; then
        commit_msg="Add app v$VERSION"
        upload_file "$APP_FILE" "$VERSION" "$BRANCH" "$commit_msg" ""
    elif [[ "$status" =~ ^CHANGED: ]]; then
        sha="${status#CHANGED:}"
        commit_msg="Update app v$VERSION"
        upload_file "$APP_FILE" "$VERSION" "$BRANCH" "$commit_msg" "$sha"
    else
        print_info "$APP_FILE unchanged in repository, skipping upload"
    fi
    
    # GitHub Release erstellen (immer prüfen/erstellen)
    echo ""
    print_info "Checking GitHub Release..."
    create_github_release "$VERSION" "$TARBALL" "$APP_FILE"
    
    # Zusammenfassung
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           Upload Complete              ║${NC}"
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    print_success "New files: $UPLOADED"
    print_success "Updated files: $UPDATED"
    print_info "Unchanged files: $UNCHANGED"
    echo ""
    print_success "Repository: https://github.com/$GITHUB_USER/$GITHUB_REPO"
    print_success "Version: $VERSION"
    echo ""
}

# Führe aus
main "$@"
