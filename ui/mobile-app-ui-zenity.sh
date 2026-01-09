#!/usr/bin/env bash
# Mobile App UI - Zenity Version (Fallback)
# Standard GUI when YAD is not available
# Requires: zenity

show_menu() {
    local lang="$1"
    local version="$2"
    
    if [ "$lang" = "de" ]; then
        # Deutsches Menü - Zenity Standard
        CHOICE=$(zenity --list \
            --title="Social-DL v${version}" \
            --width=440 --height=580 \
            --window-icon="applications-multimedia" \
            --text="<big><b>📱 Social-DL</b></big>\n<small>Instagram • Twitter/X • YouTube • Reddit • TikTok</small>" \
            --column="ID" --column="" --column="Option" --column="Beschreibung" \
            "1" "📥" "Installieren" "System-Installation" \
            "2" "🗑️" "Deinstallieren" "Vom System entfernen" \
            "3" "📖" "README (DE)" "Deutsche Dokumentation" \
            "4" "📘" "README (EN)" "English documentation" \
            "5" "📋" "Changelog" "Versionshistorie" \
            "6" "ℹ️" "Info" "Über Social-DL" \
            "7" "🌐" "English" "Switch language" \
            "" "" "" "" \
            "" "" "" "" \
            "8" "🚀" "AUSFÜHREN" "Direkt starten" \
            "" "" "" "" \
            "" "" "" "" \
            "9" "❌" "Beenden" "Programm schließen" \
            --hide-column=1 --print-column=1 2>/dev/null)
    else
        # Englisches Menü - Zenity Standard
        CHOICE=$(zenity --list \
            --title="Social-DL v${version}" \
            --width=440 --height=580 \
            --window-icon="applications-multimedia" \
            --text="<big><b>📱 Social-DL</b></big>\n<small>Instagram • Twitter/X • YouTube • Reddit • TikTok</small>" \
            --column="ID" --column="" --column="Option" --column="Description" \
            "1" "📥" "Install" "System installation" \
            "2" "🗑️" "Uninstall" "Remove from system" \
            "3" "📖" "README (DE)" "German documentation" \
            "4" "📘" "README (EN)" "English documentation" \
            "5" "📋" "Changelog" "Version history" \
            "6" "ℹ️" "Info" "About Social-DL" \
            "7" "🌐" "Deutsch" "Switch to German" \
            "" "" "" "" \
            "" "" "" "" \
            "8" "🚀" "RUN NOW" "Start directly" \
            "" "" "" "" \
            "" "" "" "" \
            "9" "❌" "Exit" "Close program" \
            --hide-column=1 --print-column=1 2>/dev/null)
    fi
    
    echo "$CHOICE"
}

# Export function for use in other scripts
export -f show_menu
