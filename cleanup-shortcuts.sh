#!/bin/bash
# Manual Cleanup Script für Social-DL Desktop-Shortcuts
# Nutze dieses Script wenn Shortcuts nach Deinstallation noch sichtbar sind

set -o errexit
set -o nounset
set -o pipefail

echo "🧹 Social-DL Shortcuts Cleanup"
echo "=============================="
echo ""

# Check ob Shortcuts noch existieren
SHORTCUTS_FOUND=0

if [ -f "$HOME/.local/share/applications/social-dl.desktop" ]; then
    echo "❌ Found: $HOME/.local/share/applications/social-dl.desktop"
    SHORTCUTS_FOUND=1
fi

if [ -f "/usr/share/applications/social-dl.desktop" ]; then
    echo "❌ Found: /usr/share/applications/social-dl.desktop (system-wide)"
    SHORTCUTS_FOUND=1
fi

if [ $SHORTCUTS_FOUND -eq 0 ]; then
    echo "✅ No shortcuts found - cleanup not needed!"
    exit 0
fi

echo ""
echo "Cleaning up..."

# Lokale Shortcuts löschen
if [ -f "$HOME/.local/share/applications/social-dl.desktop" ]; then
    rm -f "$HOME/.local/share/applications/social-dl.desktop"
    echo "✅ Removed local shortcut"
fi

# System-wide Shortcuts (requires sudo)
if [ -f "/usr/share/applications/social-dl.desktop" ]; then
    echo "🔐 System-wide shortcut found - requires sudo..."
    sudo rm -f "/usr/share/applications/social-dl.desktop"
    echo "✅ Removed system-wide shortcut"
fi

# Update Desktop-Database
echo ""
echo "📋 Updating desktop database..."

if command -v update-desktop-database >/dev/null 2>&1; then
    # Local
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null && echo "✅ Updated local database"
    
    # System (if we had system-wide shortcuts)
    if [ -d "/usr/share/applications" ]; then
        sudo update-desktop-database "/usr/share/applications" 2>/dev/null && echo "✅ Updated system database"
    fi
else
    echo "⚠️  update-desktop-database not found"
    echo "   You may need to log out/in for changes to take effect"
fi

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "If shortcuts are still visible:"
echo "1. Log out and log back in"
echo "2. Or restart your desktop environment"
echo "3. Or run: killall -3 gnome-shell (GNOME only)"
