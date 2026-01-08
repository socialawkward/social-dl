# 🔍 Unterschiede v2.3 → v2.4

## Quick Diff: Was hat sich geändert?

### social-dl.sh

#### 1. Header (Zeile 5)
```diff
- # Version: 2.3 (Multilingual)
+ # Version: 2.4 (Quick Wins + Version Check)
```

#### 2. Neue Variablen (Zeilen 7-9)
```diff
+ # Version Info
+ SCRIPT_VERSION="2.4"
+ GITHUB_REPO="username/social-dl"  # TODO: Replace with actual repo
```

#### 3. Neue Translation Keys (Zeilen 186-205)
```diff
+ # Version Check messages
+ "version_current")
+ "version_checking")
+ "version_latest")
+ "version_uptodate")
+ "version_available")
+ "version_download")
+ "version_error")
+ "version_no_network")
```

#### 4. Defensive cleanup() (Zeile 281)
```diff
- rm -f "$LOG_LOCK" 2>/dev/null || true
+ rm -f "${LOG_LOCK:-}" 2>/dev/null || true
```

#### 5. Neue Funktion: check_version() (Zeilen 289-331)
```diff
+ # Version Check Funktion
+ check_version() {
+     echo ""
+     echo "📦 Social-DL $(msg "version_current") $SCRIPT_VERSION"
+     # ... (komplette neue Funktion)
+ }
```

#### 6. Help erweitert (Zeile 340-342)
```diff
  $(msg "help_usage")
    $0 <URL>              # Direkte URL
+   $0 --version          # Version anzeigen
+   $0 --check-update     # Nach Updates suchen
```

#### 7. Parameter-Handling (Zeilen 409-418)
```diff
+ if [[ "${1:-}" == "--version" || "${1:-}" == "-v" ]]; then
+     check_version
+     exit 0
+ fi
+ 
+ if [[ "${1:-}" == "--check-update" || "${1:-}" == "-u" ]]; then
+     check_version --check-update
+     exit 0
+ fi
```

#### 8. Error-Message Fix (Zeile 437)
```diff
- echo "$(msg "error") '$LINK' $(msg "error_not_url")" >&2
+ echo "$(msg "error_not_url") '$LINK'" >&2
```

#### 9. Audio-Thumbnail (Zeile 520)
```diff
- YTDLP_EXTRA_ARGS="-x --audio-format mp3 --audio-quality 0"
+ YTDLP_EXTRA_ARGS="-x --audio-format mp3 --audio-quality 0 --embed-thumbnail"
```

---

## 📊 Statistik

| Kategorie | v2.3 | v2.4 | Δ |
|-----------|------|------|---|
| Zeilen | 646 | ~720 | +74 |
| Funktionen | 9 | 10 | +1 |
| Translation Keys | 45 | 53 | +8 |
| Features | 12 | 16 | +4 |

---

## ✅ Was ist neu?

1. **Audio-Thumbnail** (1 Zeile)
2. **Translation Fix** (1 Zeile)
3. **Defensive cleanup** (1 Zeile)
4. **Version-Check System** (~70 Zeilen)

---

## 🔄 Kompatibilität

- ✅ 100% abwärtskompatibel
- ✅ Keine Breaking Changes
- ✅ Alte Aufrufe funktionieren weiter
- ✅ Neue Features optional

---

## 🧪 Testing

```bash
# Alt (v2.3) - funktioniert weiter:
social-dl https://youtube.com/...

# Neu (v2.4) - zusätzlich:
social-dl --version
social-dl --check-update
```

---

**Fazit:** Minimale Änderungen, maximaler Nutzen! 🎯
