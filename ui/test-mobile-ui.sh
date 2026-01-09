#!/usr/bin/env bash
# Mobile App UI Test Script
# Tests the GUI without any upload/packaging logic

set -o errexit
set -o nounset
set -o pipefail

VERSION="2.7.0-test"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧪 Social-DL Mobile UI Test (Multi-Tab)"
echo "═══════════════════════════════════"
echo ""

# Detect available dialog tool
if command -v yad >/dev/null 2>&1; then
    UI_TOOL="yad"
    UI_MODULE="$SCRIPT_DIR/mobile-app-ui-yad-tabs.sh"
    echo "✅ YAD detected - using multi-tab enhanced UI"
elif command -v zenity >/dev/null 2>&1; then
    UI_TOOL="zenity"
    UI_MODULE="$SCRIPT_DIR/mobile-app-ui-zenity.sh"
    echo "⚠️  YAD not found - using Zenity fallback (no tabs)"
else
    echo "❌ Error: Neither YAD nor Zenity found!"
    echo ""
    echo "Please install one of:"
    echo "  • yad (recommended): sudo pacman -S yad"
    echo "  • zenity (fallback): sudo pacman -S zenity"
    exit 1
fi

echo "   UI Module: $UI_MODULE"
echo ""

# Source the UI module
# shellcheck source=/dev/null
source "$UI_MODULE"

# Default language
LANG_MODE="de"

echo "🎨 Starting GUI..."
echo "   Press Ctrl+C to exit"
echo ""

# Main loop
while true; do
    CHOICE=$(show_menu "$LANG_MODE" "$VERSION")
    EXIT_CODE=$?
    
    # Exit if Cancel pressed or window closed
    if [ $EXIT_CODE -ne 0 ]; then
        echo ""
        echo "👋 Exiting..."
        break
    fi
    
    # Skip empty choices (shouldn't happen now but safety check)
    if [ -z "$CHOICE" ]; then
        continue
    fi
    
    case "$CHOICE" in
        # Main Menu (1-99)
        "1")
            echo "📥 Install selected"
            ;;
        "2")
            echo "🗑️  Uninstall selected"
            ;;
        "3")
            echo "📖 README (DE) selected"
            ;;
        "4")
            echo "📘 README (EN) selected"
            ;;
        "5")
            echo "📋 Changelog selected"
            ;;
        "6")
            echo "ℹ️  Info selected"
            ;;
        "7")
            echo "🚀 Run now selected"
            ;;
        "8")
            echo "⚙️ Settings opened (will show settings window)"
            ;;
        "9")
            # Toggle language
            if [ "$LANG_MODE" = "de" ]; then
                LANG_MODE="en"
                echo "🌐 Switched to English"
            else
                LANG_MODE="de"
                echo "🌐 Gewechselt zu Deutsch"
            fi
            ;;
        
        # Settings Menu (101-199)
        "100")
            echo "← Back to main menu"
            ;;
        "101")
            echo "📝 Edit Config selected"
            ;;
        "102")
            echo "📁 Choose Download Folder selected"
            ;;
        "103")
            echo "🔄 Set Retry Count selected"
            ;;
        "104")
            echo "🌐 Open GitHub Repo selected"
            ;;
        "105")
            echo "🔧 Update yt-dlp selected"
            ;;
        
        *)
            echo "❌ Unknown selection: $CHOICE"
            break
            ;;
    esac
    
    echo ""
done

echo ""
echo "✅ Test completed!"
