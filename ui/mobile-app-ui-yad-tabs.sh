#!/usr/bin/env bash
# Mobile App UI - YAD Separate Windows Version
# Main menu with settings button that opens separate window
# Requires: yad

# Config file location
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/social-dl/config"

show_main_menu() {
    local lang="$1"
    local version="$2"
    
    if [ "$lang" = "de" ]; then
        # Deutsches Hauptmenü
        yad --list \
            --title="Social-DL v${version}" \
            --width=360 --height=640 \
            --center \
            --fixed \
            --buttons-layout=center \
            --button="❌ Abbrechen:1" --button="✅ Ok:0" \
            --window-icon="applications-multimedia" \
            --text="<big><b>📱 Social-DL</b></big>\n<small>Instagram • Twitter/X • YouTube • Reddit • TikTok</small>" \
            --column="ID:HD" \
            --column="Icon:IMG:60" \
            --column="Option:TXT:180" \
            --column="Beschreibung:TXT" \
            --no-headers \
            --no-click \
            --print-column=1 \
            --separator="" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "7" "🚀" "<big><b>AUSFÜHREN</b></big>     " "Direkt starten" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "1" "📥" "Installieren     " "System-Installation" \
            "2" "🗑️" "Deinstallieren     " "Vom System entfernen" \
            "3" "📖" "README (DE)     " "Deutsche Dokumentation" \
            "4" "📘" "README (EN)     " "English documentation" \
            "5" "📋" "Changelog     " "Versionshistorie" \
            "6" "ℹ️" "Info     " "Über Social-DL" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "8" "⚙️" "Einstellungen →     " "Konfiguration öffnen" \
            "9" "🌐" "English     " "Switch language" \
            2>/dev/null
    else
        # English Main Menu
        yad --list \
            --title="Social-DL v${version}" \
            --width=360 --height=640 \
            --center \
            --fixed \
            --buttons-layout=center \
            --button="❌ Cancel:1" --button="✅ Ok:0" \
            --window-icon="applications-multimedia" \
            --text="<big><b>📱 Social-DL</b></big>\n<small>Instagram • Twitter/X • YouTube • Reddit • TikTok</small>" \
            --column="ID:HD" \
            --column="Icon:IMG:60" \
            --column="Option:TXT:180" \
            --column="Description:TXT" \
            --no-headers \
            --no-click \
            --print-column=1 \
            --separator="" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "7" "🚀" "<big><b>RUN NOW</b></big>     " "Start directly" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "1" "📥" "Install     " "System installation" \
            "2" "🗑️" "Uninstall     " "Remove from system" \
            "3" "📖" "README (DE)     " "German documentation" \
            "4" "📘" "README (EN)     " "English documentation" \
            "5" "📋" "Changelog     " "Version history" \
            "6" "ℹ️" "Info     " "About Social-DL" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "8" "⚙️" "Settings →     " "Open configuration" \
            "9" "🌐" "Deutsch     " "Switch to German" \
            2>/dev/null
    fi
}

show_settings_menu() {
    local lang="$1"
    local version="$2"
    
    if [ "$lang" = "de" ]; then
        # Deutsches Einstellungsmenü
        yad --list \
            --title="Social-DL v${version} - Einstellungen" \
            --width=360 --height=640 \
            --center \
            --fixed \
            --buttons-layout=center \
            --button="❌ Abbrechen:1" --button="✅ Ok:0" \
            --window-icon="applications-multimedia" \
            --text="<big><b>⚙️ Einstellungen</b></big>\n<small>Konfiguration und Anpassungen</small>" \
            --column="ID:HD" \
            --column="Icon:IMG:60" \
            --column="Option:TXT:180" \
            --column="Beschreibung:TXT" \
            --no-headers \
            --no-click \
            --print-column=1 \
            --separator="" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "101" "📝" "Config bearbeiten     " "Einstellungen anpassen" \
            "102" "📁" "Download-Ordner     " "Zielverzeichnis wählen" \
            "103" "🔄" "Retry-Anzahl     " "Wiederholungsversuche" \
            "104" "🌐" "GitHub Repo     " "Repository öffnen" \
            "105" "🔧" "yt-dlp Update     " "Downloader aktualisieren" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "100" "←" "<b>Zurück</b>     " "Zum Hauptmenü" \
            "9" "🌐" "English     " "Switch language" \
            2>/dev/null
    else
        # English Settings Menu
        yad --list \
            --title="Social-DL v${version} - Settings" \
            --width=360 --height=640 \
            --center \
            --fixed \
            --buttons-layout=center \
            --button="❌ Cancel:1" --button="✅ Ok:0" \
            --window-icon="applications-multimedia" \
            --text="<big><b>⚙️ Settings</b></big>\n<small>Configuration and customization</small>" \
            --column="ID:HD" \
            --column="Icon:IMG:60" \
            --column="Option:TXT:180" \
            --column="Description:TXT" \
            --no-headers \
            --no-click \
            --print-column=1 \
            --separator="" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "101" "📝" "Edit Config     " "Customize settings" \
            "102" "📁" "Download Folder     " "Choose target directory" \
            "103" "🔄" "Retry Count     " "Set retry attempts" \
            "104" "🌐" "GitHub Repo     " "Open repository" \
            "105" "🔧" "Update yt-dlp     " "Update downloader" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "@disabled@" "" "" "" \
            "100" "←" "<b>Back</b>     " "Return to main menu" \
            "9" "🌐" "Deutsch     " "Switch to German" \
            2>/dev/null
    fi
}

show_menu() {
    local lang="$1"
    local version="$2"
    
    while true; do
        # Show main menu
        local choice=$(show_main_menu "$lang" "$version")
        local exit_code=$?
        
        # Exit if cancelled (ESC gives exit_code != 0)
        if [ $exit_code -ne 0 ]; then
            return 1
        fi
        
        # If empty choice, it means Cancel button was clicked (button returns empty with exit 0)
        if [ -z "$choice" ]; then
            return 1
        fi
        
        # If @disabled@ was somehow selected, ignore and continue
        if [ "$choice" = "@disabled@" ]; then
            continue
        fi
        
        # If settings selected (8), show settings menu
        if [ "$choice" = "8" ]; then
            while true; do
                choice=$(show_settings_menu "$lang" "$version")
                local exit_code=$?
                
                # Exit settings if cancelled (ESC)
                if [ $exit_code -ne 0 ]; then
                    break
                fi
                
                # Empty choice = Cancel button clicked
                if [ -z "$choice" ]; then
                    break
                fi
                
                # Ignore @disabled@ rows
                if [ "$choice" = "@disabled@" ]; then
                    continue
                fi
                
                # If back button (100), return to main menu
                if [ "$choice" = "100" ]; then
                    break
                fi
                
                # If language switch (9) in settings, toggle and reload settings
                if [ "$choice" = "9" ]; then
                    if [ "$lang" = "de" ]; then
                        lang="en"
                    else
                        lang="de"
                    fi
                    # Continue loop to show settings again in new language
                    continue
                fi
                
                # Settings actions (101-105) are returned to main script for handling
                # After handling, main script should call show_menu again
                # This keeps the settings loop active
                if [[ "$choice" =~ ^10[1-5]$ ]]; then
                    # Return the choice for main script to handle
                    echo "$choice"
                    return 0
                fi
                
                # Unknown choice in settings - ignore and continue
                continue
            done
            # Continue to show main menu again
        else
            # Return main menu choice
            echo "$choice"
            return 0
        fi
    done
}

# Export functions for use in other scripts
export -f show_menu
export -f show_main_menu
export -f show_settings_menu
