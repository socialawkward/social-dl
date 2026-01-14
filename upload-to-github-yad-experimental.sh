#!/bin/bash
# EXPERIMENTELLE VERSION - YAD statt Zenity
# Diese Datei ist NUR zum Testen des GUI-Designs - nicht für Production!

set -o errexit
set -o nounset
set -o pipefail
# 
# WICHTIG: Diese Version:
# - ✅ Rendert nur das GUI-Menü
# - ✅ Zeigt die Auswahl an
# - ❌ Erstellt KEINE tar-Dateien
# - ❌ Lädt NICHTS auf GitHub hoch
# - ❌ Führt KEINE echten Aktionen aus
#
# YAD Features:
# - Textausrichtung in Spalten (linksbündig, rechtsbündig, zentriert)
# - Individuelle Spaltenbreiten
# - Mehr Formatierungsoptionen
#
# Installation: sudo pacman -S yad  (Arch/CachyOS)
#               sudo apt install yad  (Debian/Ubuntu)

# Prüfe ob yad installiert ist
if ! command -v yad >/dev/null 2>&1; then
    echo "❌ yad ist nicht installiert!" >&2
    echo "Installation:" >&2
    echo "  Arch/CachyOS: sudo pacman -S yad" >&2
    echo "  Debian/Ubuntu: sudo apt install yad" >&2
    exit 1
fi

# Version aus social-dl.sh auslesen (falls vorhanden)
get_version() {
    if [ -f "social-dl.sh" ]; then
        grep -E "^SCRIPT_VERSION=" social-dl.sh | cut -d'"' -f2 || echo "2.6.0"
    else
        echo "2.6.0"
    fi
}

VERSION=$(get_version)

# Standard-Sprache: Deutsch
LANG_MODE="de"

show_menu() {
    local lang="$1"
    
    if [ "$lang" = "de" ]; then
        # Deutsches Menü mit YAD
        # YAD Syntax: --list --column="Header:ALIGNMENT:WIDTH" ...
        # ALIGNMENT: L=links, R=rechts, C=zentriert
        # WIDTH: Pixel-Breite (0 = automatisch)
        CHOICE=$(yad --list \
            --title="Social-DL v${VERSION} (YAD Experimental - GUI Test)" \
            --width=360 --height=640 \
            --center --fixed \
            --buttons-layout=center \
            --button="❌ Cancel:1" --button="✅ Ok:0" \
            --window-icon="applications-multimedia" \
            --text="<big><b>📱 Social-DL</b></big>\n<small>Instagram • Twitter/X • YouTube • Reddit • TikTok</small>\n\n<i>🧪 Experimentelle YAD-Version - Nur GUI-Test</i>" \
            --column="ID:HD" \
            --column="Icon:IMG:60" \
            --column="Option:TXT:180" \
            --column="Beschreibung:TXT" \
            --no-headers \
            "1" "📥" "Installieren     " "System-Installation" \
            "2" "🗑️" "Deinstallieren     " "Vom System entfernen" \
            "3" "📖" "README (DE)     " "Deutsche Dokumentation" \
            "4" "📘" "README (EN)     " "English documentation" \
            "5" "📋" "Changelog     " "Versionshistorie" \
            "6" "ℹ️" "Info     " "Über Social-DL" \
            "7" "🌐" "English     " "Switch language" \
            "" "" "" "" \
            "" "" "" "" \
            "8" "🚀" "AUSFÜHREN     " "Direkt starten" \
            "" "" "" "" \
            "" "" "" "" \
            "9" "❌" "Beenden     " "Programm schließen" \
            --print-column=1 \
            --separator="" \
            2>/dev/null)
    else
        # Englisches Menü mit YAD
        CHOICE=$(yad --list \
            --title="Social-DL v${VERSION} (YAD Experimental - GUI Test)" \
            --width=360 --height=640 \
            --center --fixed \
            --buttons-layout=center \
            --button="❌ Cancel:1" --button="✅ Ok:0" \
            --window-icon="applications-multimedia" \
            --text="<big><b>📱 Social-DL</b></big>\n<small>Instagram • Twitter/X • YouTube • Reddit • TikTok</small>\n\n<i>🧪 Experimental YAD version - GUI test only</i>" \
            --column="ID:HD" \
            --column="Icon:IMG:60" \
            --column="Option:TXT:180" \
            --column="Desc:TXT" \
            --no-headers \
            "1" "📥" "Installieren     " "Install to system" \
            "2" "🗑️" "Deinstallieren     " "Remove from system" \
            "3" "📖" "README (DE)     " "Deutsche Dokumentation" \
            "4" "📘" "README (EN)     " "English documentation" \
            "5" "📋" "Changelog     " "Version history" \
            "6" "ℹ️" "Info     " "About Social-DL" \
            "7" "🌐" "Deutsch     " "Switch language" \
            "" "" "" "" \
            "" "" "" "" \
            "8" "🚀" "RUN NOW     " "Start directly" \
            "" "" "" "" \
            "" "" "" "" \
            "9" "❌" "Exit     " "Close program" \
            --print-column=1 \
            --separator="" \
            2>/dev/null)
    fi
    
    echo "$CHOICE"
}

# Simuliere Menü-Aktionen (nur für Anzeige, keine echten Aktionen!)
handle_choice() {
    local choice="$1"
    
    case "$choice" in
        "1")
            echo "ℹ️  [SIMULIERT] Installieren würde ausgeführt werden"
            ;;
        "2")
            echo "ℹ️  [SIMULIERT] Deinstallieren würde ausgeführt werden"
            ;;
        "3")
            echo "ℹ️  [SIMULIERT] README (DE) würde angezeigt werden"
            ;;
        "4")
            echo "ℹ️  [SIMULIERT] README (EN) würde angezeigt werden"
            ;;
        "5")
            echo "ℹ️  [SIMULIERT] Changelog würde angezeigt werden"
            ;;
        "6")
            echo "ℹ️  [SIMULIERT] Info würde angezeigt werden"
            ;;
        "7")
            echo "ℹ️  [SIMULIERT] Sprache würde gewechselt werden"
            LANG_MODE="en"
            ;;
        "8")
            echo "ℹ️  [SIMULIERT] Social-DL würde direkt gestartet werden"
            ;;
        "9")
            echo "ℹ️  [SIMULIERT] Programm würde beendet werden"
            exit 0
            ;;
        *)
            echo "ℹ️  [SIMULIERT] Unbekannte Auswahl: $choice"
            ;;
    esac
}

# Main Loop - Nur GUI-Test, keine echten Aktionen!
while true; do
    CHOICE=$(show_menu "$LANG_MODE")
    
    if [ -z "$CHOICE" ]; then
        echo "❌ Abgebrochen"
        exit 0
    fi
    
    echo ""
    echo "✅ Auswahl: $CHOICE"
    handle_choice "$CHOICE"
    echo ""
    echo "---"
    echo "Drücke Enter für nächste Auswahl (oder Ctrl+C zum Beenden)..."
    read -r
    echo ""
done
