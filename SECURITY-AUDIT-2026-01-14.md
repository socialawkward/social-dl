# Security & Code Audit Report - Social-DL

**Datum:** 2026-01-14
**Version:** 2.8.0
**Auditor:** Claude (Senior Developer & Security Analyst)

---

## Executive Summary

Das Social-DL Projekt zeigt **solide Grundlagen** mit korrektem Einsatz von `set -o errexit/nounset/pipefail` in den Hauptskripten. Es wurden jedoch **3 kritische**, **15 mittlere** und **10+ niedrige** Sicherheits- und Qualitätsprobleme identifiziert.

### Risiko-Übersicht

| Schweregrad | Anzahl | Status |
|-------------|--------|--------|
| KRITISCH | 3 | Sofort beheben |
| HOCH | 5 | Priorität hoch |
| MITTEL | 15 | Nächste Version |
| NIEDRIG | 10+ | Später |

---

## KRITISCHE Probleme (Sofort beheben)

### 1. Config-Datei wird unsicher gesourced

**Datei:** `social-dl.sh:256`

```bash
source "$CONFIG_FILE"
```

**Problem:** Beliebige Code-Ausführung möglich wenn Config-Datei manipuliert wird.

**Fix:**
```bash
# Config parsen statt sourcen
while IFS='=' read -r key value; do
    case "$key" in
        DOWNLOAD_DIR) DOWNLOAD_DIR="${value//\"/}" ;;
        AUDIO_DIR) AUDIO_DIR="${value//\"/}" ;;
        MAX_RETRIES) [[ "$value" =~ ^[0-9]+$ ]] && MAX_RETRIES="$value" ;;
        # nur erlaubte Keys akzeptieren
    esac
done < "$CONFIG_FILE"
```

---

### 2. GitHub Token in Prozessliste sichtbar

**Datei:** `upload-to-github.sh:218-219`

```bash
response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" ...)
```

**Problem:** Token ist via `ps aux` für alle User sichtbar.

**Fix:**
```bash
# Token über stdin übergeben
response=$(curl -s -H @- "$GITHUB_API/..." <<< "Authorization: token $GITHUB_TOKEN")

# Oder mit .netrc
curl -s --netrc-file <(printf "machine api.github.com\nlogin token\npassword %s\n" "$GITHUB_TOKEN") ...
```

---

### 3. Vorhersagbare Temp-Dateien (Symlink-Attacke)

**Dateien:**
- `upload-to-github.sh:337`: `/tmp/github-upload-$$.json`
- `install.sh:30`: `/tmp/social-dl-install-$$`
- `social-dl.sh:778-779`: Vorhersagbares Pattern

**Problem:** PID ist vorhersagbar → Symlink-Attacken möglich.

**Fix:**
```bash
# Statt:
json_file="/tmp/github-upload-$$.json"
# Verwende:
json_file=$(mktemp --mode=600 /tmp/github-upload-XXXXXX.json)

# Statt:
TEMP_DIR="/tmp/social-dl-install-$$"
# Verwende:
TEMP_DIR=$(mktemp -d /tmp/social-dl-install-XXXXXX)
chmod 700 "$TEMP_DIR"
```

---

## HOHE Probleme

### 4. pkexec mit unsanitisierten Variablen

**Datei:** `install-gui.sh:207-232`

```bash
pkexec bash -c "
    cp '$SCRIPT_SOURCE' '/usr/local/bin/$SCRIPT_NAME'
    echo 'export SOCIAL_DL_LANG=\"$LANG_CHOICE\"' > ...
"
```

**Problem:** Shell-Injection durch manipulierte `$SCRIPT_SOURCE` oder `$LANG_CHOICE`.

**Fix:** Variablen vor pkexec validieren oder hardcodierte Werte verwenden.

---

### 5. Debug-Output immer aktiv

**Datei:** `upload-to-github.sh:259, 267`

```bash
echo "DEBUG check_file_changed: file='$file'" >&2
echo "DEBUG API Response (first 200 chars): ${response:0:200}" >&2
```

**Problem:** Sensible Daten können geloggt werden.

**Fix:**
```bash
[[ "${DEBUG:-0}" == "1" ]] && echo "DEBUG: ..." >&2
```

---

### 6. Unvollständiges JSON-Escaping

**Datei:** `upload-to-github.sh:343-352`

```bash
local escaped_message="${commit_message//\"/\\\"}"
```

**Problem:** Nur `"` wird escaped. `\`, `\n`, `\r`, `\t` fehlen.

**Fix:** `jq` für JSON-Erstellung verwenden (wird anderswo bereits genutzt).

---

### 7. Token-Datei Race Condition

**Datei:** `upload-to-github.sh:210-211`

```bash
echo "$GITHUB_TOKEN" > "$token_file"
chmod 600 "$token_file"
```

**Problem:** Kurzzeitig mit Default-Permissions (umask).

**Fix:**
```bash
install -m 600 /dev/null "$token_file"
echo "$GITHUB_TOKEN" > "$token_file"
```

---

### 8. Keine Symlink-Prüfung bei Token-Datei

**Datei:** `upload-to-github.sh:189-193`

**Fix:**
```bash
if [ -f "$token_file" ] && [ ! -L "$token_file" ]; then
    GITHUB_TOKEN=$(cat "$token_file")
fi
```

---

## MITTLERE Probleme

| # | Datei | Zeile | Problem |
|---|-------|-------|---------|
| 9 | social-dl.sh | 467-488 | URL-Blacklist statt Whitelist |
| 10 | social-dl.sh | 803-805 | Word-Splitting bei YTDLP_EXTRA_ARGS |
| 11 | upload-to-github.sh | 230-237 | Keine API-Response-Validierung |
| 12 | upload-to-github.sh | 843-854 | Asset-Upload ohne Error-Handling |
| 13 | install.sh | 437-448 | TOCTOU Race Condition |
| 14 | install.sh | 192-193 | Keine Symlink-Prüfung beim Kopieren |
| 15 | settings-handlers.sh | 54 | sed ohne Fehlerbehandlung |
| 16 | settings-handlers.sh | 338 | Terminal-Quoting unsicher |
| 17 | * | diverse | `set -o errexit/nounset` fehlt in 7 Skripten |
| 18 | * | diverse | DRY-Verstöße (Farben, Terminal-Erkennung) |
| 19 | social-dl.sh | 282 | stat -c ist GNU-spezifisch |
| 20 | install-gui.sh | 285-301 | LANG_CHOICE ohne Validierung |

---

## Code-Qualität

### Positiv

- `set -o errexit/nounset/pipefail` in Hauptskripten
- Konsistente Variable-Quotierung
- `flock` für atomare Operationen
- Cleanup-Trap implementiert
- Modulare UI-Architektur (YAD/Zenity)
- Gute Dokumentation in Hauptskripten

### Verbesserungsbedarf

#### Fehlende Safety-Flags

Diese Skripte haben KEIN `set -o errexit/nounset`:
- `install-gui.sh`
- `uninstall-gui.sh`
- `cleanup-shortcuts.sh`
- `check-files-sync.sh`
- `settings-handlers.sh`
- `upload-to-github-yad-experimental.sh`
- `ui/mobile-app-ui-yad.sh`

#### DRY-Verstöße

Duplizierter Code:
1. **Farbdefinitionen** in 3 Dateien identisch
2. **Terminal-Erkennung** in 2 Dateien
3. **Übersetzungsfunktionen** in install-gui.sh und uninstall-gui.sh

**Empfehlung:** `lib/common.sh` erstellen.

#### Inkonsistenzen

- Shebang: `#!/bin/bash` vs `#!/usr/bin/env bash`
- Keine einheitliche Dokumentation (Funktions-Header)

---

## Empfohlene Maßnahmen

### Phase 1: Kritisch (Sofort)

1. [ ] Config-Datei parsen statt sourcen (`social-dl.sh:256`)
2. [ ] Token-Handling über stdin (`upload-to-github.sh`)
3. [ ] `mktemp` für alle Temp-Dateien

### Phase 2: Hoch (Diese Woche)

4. [ ] pkexec-Variablen sanitisieren
5. [ ] Debug-Output hinter Flag
6. [ ] JSON-Escaping mit jq
7. [ ] Token-Datei atomar erstellen
8. [ ] Symlink-Checks hinzufügen

### Phase 3: Mittel (Nächste Version)

9. [ ] `set -o errexit/nounset/pipefail` in allen Skripten
10. [ ] `lib/common.sh` für gemeinsamen Code
11. [ ] Error-Handling bei sed/API-Calls
12. [ ] Input-Validierung verbessern

### Phase 4: Niedrig (Später)

13. [ ] Dokumentation verbessern
14. [ ] Code-Stil vereinheitlichen
15. [ ] Portabilität (stat → portable Alternative)

---

## Konkrete Fixes

### Fix für `social-dl.sh:256` - Sicheres Config-Parsing

```bash
# Ersetze: source "$CONFIG_FILE"
# Durch:
load_config() {
    local config_file="$1"
    [ ! -f "$config_file" ] && return 0
    [ -L "$config_file" ] && { echo "Config darf kein Symlink sein" >&2; return 1; }

    while IFS='=' read -r key value || [ -n "$key" ]; do
        # Leerzeilen und Kommentare überspringen
        [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue

        # Quotes entfernen
        value="${value%\"}"
        value="${value#\"}"

        case "$key" in
            DOWNLOAD_DIR) DOWNLOAD_DIR="$value" ;;
            AUDIO_DIR) AUDIO_DIR="$value" ;;
            MAX_RETRIES) [[ "$value" =~ ^[0-9]+$ ]] && MAX_RETRIES="$value" ;;
            DOWNLOAD_TIMEOUT) [[ "$value" =~ ^[0-9]+$ ]] && DOWNLOAD_TIMEOUT="$value" ;;
            LOG_MAX_LINES) [[ "$value" =~ ^[0-9]+$ ]] && LOG_MAX_LINES="$value" ;;
            *) echo "Unbekannte Config-Option: $key" >&2 ;;
        esac
    done < "$config_file"
}

load_config "$CONFIG_FILE"
```

### Fix für `upload-to-github.sh` - Sicheres Token-Handling

```bash
# Ersetze direkte curl-Aufrufe durch:
github_api_call() {
    local method="$1"
    local endpoint="$2"
    local data="${3:-}"

    local auth_header
    auth_header=$(printf "Authorization: token %s" "$GITHUB_TOKEN")

    if [ -n "$data" ]; then
        curl -s -X "$method" \
            -H @- \
            -H "Content-Type: application/json" \
            -d "$data" \
            "${GITHUB_API}${endpoint}" <<< "$auth_header"
    else
        curl -s -X "$method" \
            -H @- \
            "${GITHUB_API}${endpoint}" <<< "$auth_header"
    fi
}
```

---

## Fazit

Das Projekt ist **funktional solide**, hat aber einige **sicherheitsrelevante Lücken**, die behoben werden sollten. Die kritischsten Probleme (Config-Sourcing, Token-Exposure, Temp-Dateien) sollten **vor dem nächsten Release** behoben werden.

Die Code-Qualität ist insgesamt **gut**, könnte aber durch Zentralisierung gemeinsamer Funktionen und konsistentere Fehlerbehandlung verbessert werden.

---

*Dieser Report wurde automatisch erstellt. Für Fragen: Repository Issues.*
