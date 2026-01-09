#!/usr/bin/env bash
# Mobile App UI - YAD Version
# Provides improved GUI with better formatting
# Requires: yad

show_menu() {
    local lang="$1"
    local version="$2"
    
    if [ "$lang" = "de" ]; then
        # Deutsches Menü - YAD mit besserer Formatierung
        CHOICE=$(yad --list \
            --title="Social-DL v${version}" \
            --width=440 --height=580 \
            --window-icon="applications-multimedia" \
            --text="<big><b>📱 Social-DL</b></big>\n<small>Instagram • Twitter/X • YouTube • Reddit • TikTok</small>" \
            --column="ID:HIDDEN" \
            --column="Icon:C:40" \
            --column="Option:L:120" \
            --column="Beschreibung:L:0" \
            --print-column=1 \
            --hide-header \
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
            2>/dev/null)
    else
        # Englisches Menü - YAD mit besserer Formatierung
        CHOICE=$(yad --list \
            --title="Social-DL v${version}" \
            --width=440 --height=580 \
            --window-icon="applications-multimedia" \
            --text="<big><b>📱 Social-DL</b></big>\n<small>Instagram • Twitter/X • YouTube • Reddit • TikTok</small>" \
            --column="ID:HIDDEN" \
            --column="Icon:C:40" \
            --column="Option:L:120" \
            --column="Description:L:0" \
            --print-column=1 \
            --hide-header \
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
            2>/dev/null)
    fi
    
    # YAD gibt Output mit Pipe zurück, extrahiere erste Spalte
    echo "$CHOICE" | cut -d'|' -f1
}

# Export function for use in other scripts
export -f show_menu
