#!/bin/bash

# Social-DL GUI Uninstaller (Multilingual)
# Grafische Deinstallation mit Zenity (kein Terminal nötig)
# Version: 1.1

set -o pipefail

SCRIPT_NAME="social-dl"

# Language Selection
select_language() {
    yad --form \
        --title="Social-DL Uninstaller - Language / Sprache" \
        --text="Please select your language / Bitte wähle deine Sprache:" \
        --field="Language/Sprache:CB" \
        "English!Deutsch" \
        --width=400 --height=200 \
        --button="Cancel:1" --button="OK:0" \
        2>/dev/null | awk -F'|' '{
            if ($1 == "English") print "en"
            else if ($1 == "Deutsch") print "de"
        }'
}

LANG_CHOICE=$(select_language)
if [ -z "$LANG_CHOICE" ]; then
    exit 0
fi

# Translations
t() {
    local key="$1"
    case "$key" in
        "title") [ "$LANG_CHOICE" = "de" ] && echo "Social-DL Uninstaller" || echo "Social-DL Uninstaller" ;;
        "not_installed") [ "$LANG_CHOICE" = "de" ] && echo "Social-DL ist nicht installiert.\n\nKeine Deinstallation nötig." || echo "Social-DL is not installed.\n\nNo uninstallation necessary." ;;
        "found_installations") [ "$LANG_CHOICE" = "de" ] && echo "Folgende Installationen wurden gefunden:" || echo "Following installations were found:" ;;
        "local_install") [ "$LANG_CHOICE" = "de" ] && echo "• Lokale Installation (User: $USER)" || echo "• Local installation (User: $USER)" ;;
        "system_install") [ "$LANG_CHOICE" = "de" ] && echo "• Systemweite Installation (alle User)" || echo "• System-wide installation (all users)" ;;
        "confirm_uninstall") [ "$LANG_CHOICE" = "de" ] && echo "Möchtest du Social-DL deinstallieren?" || echo "Do you want to uninstall Social-DL?" ;;
        "yes_uninstall") [ "$LANG_CHOICE" = "de" ] && echo "Ja, deinstallieren" || echo "Yes, uninstall" ;;
        "cancel") [ "$LANG_CHOICE" = "de" ] && echo "Abbrechen" || echo "Cancel" ;;
        "delete_logs_question") [ "$LANG_CHOICE" = "de" ] && echo "Sollen auch Konfiguration und Logs gelöscht werden?\n\n<b>Betroffen:</b>\n• ~/.social-dl.log*\n• Download-Historie\n\n<b>Hinweis:</b> Downloads selbst bleiben erhalten." || echo "Should configuration and logs also be deleted?\n\n<b>Affected:</b>\n• ~/.social-dl.log*\n• Download history\n\n<b>Note:</b> Downloads themselves will remain." ;;
        "yes_delete_logs") [ "$LANG_CHOICE" = "de" ] && echo "Ja, auch Logs löschen" || echo "Yes, also delete logs" ;;
        "no_keep_logs") [ "$LANG_CHOICE" = "de" ] && echo "Nein, Logs behalten" || echo "No, keep logs" ;;
        "uninstalling") [ "$LANG_CHOICE" = "de" ] && echo "Deinstallation läuft..." || echo "Uninstalling..." ;;
        "removing") [ "$LANG_CHOICE" = "de" ] && echo "Entferne Installationen..." || echo "Removing installations..." ;;
        "removing_local") [ "$LANG_CHOICE" = "de" ] && echo "Entferne lokale Installation..." || echo "Removing local installation..." ;;
        "removing_system") [ "$LANG_CHOICE" = "de" ] && echo "Entferne systemweite Installation (benötigt Berechtigung)..." || echo "Removing system-wide installation (requires permission)..." ;;
        "deleting_logs") [ "$LANG_CHOICE" = "de" ] && echo "Lösche Logs und Konfiguration..." || echo "Deleting logs and configuration..." ;;
        "done") [ "$LANG_CHOICE" = "de" ] && echo "Deinstallation abgeschlossen!" || echo "Uninstallation complete!" ;;
        "success") [ "$LANG_CHOICE" = "de" ] && echo "Social-DL wurde erfolgreich deinstalliert!" || echo "Social-DL was successfully uninstalled!" ;;
        "removed") [ "$LANG_CHOICE" = "de" ] && echo "<b>Entfernt:</b>" || echo "<b>Removed:</b>" ;;
        "programs") [ "$LANG_CHOICE" = "de" ] && echo "• Programme" || echo "• Programs" ;;
        "desktop_entries") [ "$LANG_CHOICE" = "de" ] && echo "• Desktop-Einträge" || echo "• Desktop entries" ;;
        "logs_config") [ "$LANG_CHOICE" = "de" ] && echo "• Logs & Konfiguration" || echo "• Logs & configuration" ;;
        "kept") [ "$LANG_CHOICE" = "de" ] && echo "<b>Behalten:</b>" || echo "<b>Kept:</b>" ;;
        "downloads_kept") [ "$LANG_CHOICE" = "de" ] && echo "<b>Deine Downloads bleiben erhalten:</b>" || echo "<b>Your downloads remain intact:</b>" ;;
        "downloads_videos") [ "$LANG_CHOICE" = "de" ] && echo "• ~/Downloads/Videos/" || echo "• ~/Downloads/Videos/" ;;
        "downloads_audio") [ "$LANG_CHOICE" = "de" ] && echo "• ~/Downloads/Audio/" || echo "• ~/Downloads/Audio/" ;;
        "need_pkexec") [ "$LANG_CHOICE" = "de" ] && echo "Systemweite Deinstallation benötigt 'pkexec'.\n\nBitte installiere: sudo apt install polkit\n\nOder nutze Terminal:\nsudo rm /usr/local/bin/$SCRIPT_NAME\nsudo rm /usr/share/applications/$SCRIPT_NAME.desktop" || echo "System-wide uninstallation requires 'pkexec'.\n\nPlease install: sudo apt install polkit\n\nOr use terminal:\nsudo rm /usr/local/bin/$SCRIPT_NAME\nsudo rm /usr/share/applications/$SCRIPT_NAME.desktop" ;;
        "failed") [ "$LANG_CHOICE" = "de" ] && echo "Deinstallation fehlgeschlagen!\n\nBitte prüfe die Fehlermeldungen oder nutze Terminal:\nsudo rm /usr/local/bin/$SCRIPT_NAME" || echo "Uninstallation failed!\n\nPlease check error messages or use terminal:\nsudo rm /usr/local/bin/$SCRIPT_NAME" ;;
        *) echo "$key" ;;
    esac
}

# Prüfe ob Zenity verfügbar ist
if ! command -v zenity >/dev/null 2>&1; then
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Social-DL Uninstaller" "Error: 'zenity' not installed!\n\nInstall: sudo apt install zenity"
    fi
    echo "Error: zenity not found. Install: sudo apt install zenity" >&2
    exit 1
fi

# Erkenne installierte Versionen
LOCAL_INSTALLED=0
SYSTEM_INSTALLED=0

if [ -f "$HOME/.local/bin/$SCRIPT_NAME" ]; then
    LOCAL_INSTALLED=1
fi

if [ -f "/usr/local/bin/$SCRIPT_NAME" ]; then
    SYSTEM_INSTALLED=1
fi

# Keine Installation gefunden
if [ $LOCAL_INSTALLED -eq 0 ] && [ $SYSTEM_INSTALLED -eq 0 ]; then
    yad --info \
        --title="$(t "title")" \
        --text="$(t "not_installed")" \
        --width=400
    exit 0
fi

# Bestätigungs-Dialog
INSTALL_INFO=""
if [ $LOCAL_INSTALLED -eq 1 ]; then
    INSTALL_INFO="${INSTALL_INFO}$(t "local_install")\n"
fi
if [ $SYSTEM_INSTALLED -eq 1 ]; then
    INSTALL_INFO="${INSTALL_INFO}$(t "system_install")\n"
fi

yad --question \
    --title="$(t "title")" \
    --text="$(t "found_installations")\n\n${INSTALL_INFO}\n$(t "confirm_uninstall")" \
    --width=450 \
    --ok-label="$(t "yes_uninstall")" \
    --cancel-label="$(t "cancel")" || exit 0

# Frage nach Logs
DELETE_LOGS=0
if yad --question \
    --title="$(t "title")" \
    --text="$(t "delete_logs_question")" \
    --width=450 \
    --ok-label="$(t "yes_delete_logs")" \
    --cancel-label="$(t "no_keep_logs")"; then
    DELETE_LOGS=1
fi

# Deinstallation durchführen
(
echo "10"
echo "# $(t "removing")"
sleep 0.5

# Lokale Installation entfernen
if [ $LOCAL_INSTALLED -eq 1 ]; then
    echo "30"
    echo "# $(t "removing_local")"
    rm -f "$HOME/.local/bin/$SCRIPT_NAME"
    rm -f "$HOME/.local/bin/.social-dl-lang"
    rm -f "$HOME/.local/share/applications/$SCRIPT_NAME.desktop"
fi

# Systemweite Installation entfernen
if [ $SYSTEM_INSTALLED -eq 1 ]; then
    echo "50"
    echo "# $(t "removing_system")"

    if command -v pkexec >/dev/null 2>&1; then
        pkexec bash -c "
            rm -f '/usr/local/bin/$SCRIPT_NAME'
            rm -f '/usr/local/bin/.social-dl-lang'
            rm -f '/usr/share/applications/$SCRIPT_NAME.desktop'
        " || exit 1
    else
        yad --error \
            --title="$(t "title")" \
            --text="$(t "need_pkexec")" \
            --width=450
        exit 1
    fi
fi

# Logs löschen falls gewünscht
if [ $DELETE_LOGS -eq 1 ]; then
    echo "80"
    echo "# $(t "deleting_logs")"
    rm -f "$HOME/.social-dl.log"*
fi

echo "100"
echo "# $(t "done")"

) | yad --progress \
    --title="$(t "title")" \
    --text="$(t "uninstalling")" \
    --percentage=0 \
    --auto-close \
    --no-cancel \
    --width=400

ZENITY_EXIT=$?

if [ $ZENITY_EXIT -eq 0 ] || [ $ZENITY_EXIT -eq 143 ]; then
    MSG="$(t "success")\n\n"

    if [ $DELETE_LOGS -eq 1 ]; then
        MSG="${MSG}$(t "removed")\n$(t "programs")\n$(t "desktop_entries")\n$(t "logs_config")\n\n"
    else
        MSG="${MSG}$(t "removed")\n$(t "programs")\n$(t "desktop_entries")\n\n$(t "kept")\n$(t "logs_config")\n\n"
    fi

    MSG="${MSG}$(t "downloads_kept")\n$(t "downloads_videos")\n$(t "downloads_audio")"

    yad --info \
        --title="$(t "title")" \
        --text="$MSG" \
        --width=450
else
    yad --error \
        --title="$(t "title")" \
        --text="$(t "failed")" \
        --width=450
    exit 1
fi
