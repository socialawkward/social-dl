# 📥 Social-DL

> **[English version](README_en.md) available**

**Universal Video & Audio Downloader für Social Media Plattformen**

Lade Videos und Audio von Instagram, Twitter/X, YouTube, Reddit und TikTok mit einem einfachen Tool herunter. Production-ready, sicher und benutzerfreundlich.

---

## 🚀 Quick Install

### 🖱️ Grafische Installation (empfohlen – kein Terminal!)

1. **Download** das komplette Paket
2. **Doppelklick** auf `social-dl-installer.desktop`
3. **Fertig!** Nutze das Programm aus dem Anwendungsmenü

**Hinweis:** Benötigt `zenity` (meist vorinstalliert)
```bash
# Falls zenity fehlt:
sudo apt install zenity      # Debian/Ubuntu
sudo pacman -S zenity        # Arch/Manjaro/CachyOS
```

### 📟 Terminal-Installation (alternativ)

```bash
# Schnellste Methode:
./install.sh

# Oder mit Makefile:
make install-local
```

---

## ✨ Features

- 🎬 **Video-Downloads** in wählbarer Qualität (Best/1080p/720p/480p)
- 🎵 **Audio-Only Downloads** als MP3 **mit eingebettetem Thumbnail** (Cover-Art)
- 📋 **Clipboard-Integration** (automatische URL-Erkennung)
- 🔒 **Thread-Safe** (parallele Downloads möglich)
- 🚫 **Duplikat-Erkennung** (verhindert doppelte Downloads)
- 🎨 **Shotcut-Integration** (optionale Video-Bearbeitung)
- 🔔 **Desktop-Benachrichtigungen**
- 📊 **Live Progress-Bar** mit Download-Geschwindigkeit
- 📁 **Automatische Log-Rotation** (mit 3 Backups)
- 🛡️ **Security-Hardened** (URL-Sanitization, Timeouts)
- 🐟 **Multi-Shell Support** (Bash, Zsh, Fish)
- 🔄 **Version-Check** (`--check-update`)
- 🧹 **Tracking-Parameter-Entfernung** (utm_source, fbclid, igsh, etc.)
- 🌍 **Mehrsprachig** (Deutsch/Englisch)
- 📦 **Reddit CDN Support** (direkter Download für preview.redd.it, v.redd.it, i.redd.it)
- 🐦 **Twitter/X Optimiert** (spezielle Behandlung für Videos mit/ohne Audio)

### Unterstützte Plattformen

| Plattform | Video | Audio | Besonderheiten |
|-----------|-------|-------|----------------|
| Instagram | ✅ | ✅ | Stories, Reels, Posts |
| Twitter/X | ✅ | ✅ | Tweets, Spaces, Videos mit/ohne Audio |
| YouTube   | ✅ | ✅ | Videos, Shorts (keine Playlists) |
| Reddit    | ✅ | ✅ | Posts, CDN-Links (v.redd.it, preview.redd.it) |
| TikTok    | ✅ | ✅ | Beste verfügbare Quelle (oft ohne Wasserzeichen) |

---

## 📦 Installation

### Voraussetzungen

**Pflicht:**
- `yt-dlp` (Video-Downloader)
- `zenity` (für GUI-Installation)

**Optional (empfohlen):**
- `xclip` oder `wl-paste` (Clipboard-Support)
- `notify-send` (Desktop-Benachrichtigungen)
- `shotcut` (Video-Bearbeitung)
- `curl` oder `wget` (für Reddit CDN-Links)

#### Abhängigkeiten installieren

**Arch/Manjaro/CachyOS:**
```bash
sudo pacman -S yt-dlp zenity xclip wl-clipboard libnotify shotcut curl
```

**Debian/Ubuntu/Mint:**
```bash
sudo apt update
sudo apt install yt-dlp zenity xclip wl-clipboard libnotify-bin shotcut curl
```

**Fedora:**
```bash
sudo dnf install yt-dlp zenity xclip wl-clipboard libnotify shotcut curl
```

---

### 🖱️ Grafische Installation (GUI)

Die einfachste Methode – **kein Terminal nötig!**

1. **Download das Paket** und entpacke es
2. **Doppelklick** auf `social-dl-installer.desktop`
3. **Folge den Anweisungen** im grafischen Fenster
4. **Wähle Installationstyp:**
   - **Lokal** (nur für deinen User) – empfohlen
   - **Systemweit** (für alle User) – benötigt Berechtigung

**Fertig!** Das Programm erscheint im Anwendungsmenü unter "Social Media Downloader"

---

### 📟 Terminal-Installation (alternativ)

#### Via Installer-Script:
```bash
chmod +x install.sh
./install.sh
```

#### Via Makefile:
```bash
# Lokale Installation:
make install-local

# Systemweite Installation:
sudo make install
```

---

## 🗑️ Deinstallation

### 🖱️ Grafische Deinstallation (GUI)

**Doppelklick** auf `social-dl-uninstaller.desktop`

Der Uninstaller:
- ✅ Erkennt automatisch lokale/systemweite Installation
- ✅ Fragt bei Bedarf nach Berechtigungen
- ✅ Optional: Logs und Konfiguration löschen
- ✅ Deine Downloads bleiben erhalten!

---

### 📟 Terminal-Deinstallation (alternativ)

```bash
# Via Installer:
./install.sh --uninstall

# Via Makefile:
make uninstall-local        # Lokal
sudo make uninstall         # Systemweit

# Manuell:
rm ~/.local/bin/social-dl
rm ~/.local/share/applications/social-dl.desktop
rm ~/.social-dl.log*  # Optional: Logs
```

---

## 🎯 Verwendung

### Grundlegende Nutzung

```bash
# URL aus Zwischenablage verwenden:
social-dl

# Direkte URL angeben (WICHTIG: URLs mit & in Quotes!):
social-dl "https://youtube.com/watch?v=ABC&utm_source=share"

# Hilfe anzeigen:
social-dl --help

# Version anzeigen:
social-dl --version

# Nach Updates suchen:
social-dl --check-update
```

### ⚠️ WICHTIG: URLs mit Parametern

URLs die `&` enthalten **müssen in Anführungszeichen** gesetzt werden:

```bash
# ✅ RICHTIG:
social-dl "https://instagram.com/reel/ABC/?utm_source=ig&igsh=XYZ"

# ❌ FALSCH (Shell schneidet URL bei & ab):
social-dl https://instagram.com/reel/ABC/?utm_source=ig&igsh=XYZ
```

**Alternative:** Nutze die Clipboard-Funktion (kopiere URL mit Strg+C, dann einfach `social-dl` eingeben)

### Workflow

1. **URL kopieren** (z. B. YouTube-Link mit Ctrl+C)
2. **Terminal öffnen** und `social-dl` eingeben
3. **Fragen beantworten:**
   - Audio oder Video?
   - Bei Video: Qualität wählen (1–4)
   - Optional: Shotcut zum Bearbeiten?
4. **Warten** – Live Progress-Bar zeigt Fortschritt
5. **Fertig!** Datei in `~/Downloads/Videos/` oder `~/Downloads/Audio/`

### Beispiele

**YouTube-Video herunterladen:**
```bash
social-dl "https://youtube.com/watch?v=dQw4w9WgXcQ"
# → Video wählen → Qualität 1 → Download mit Progress
```

**Instagram-Audio extrahieren (mit Cover):**
```bash
social-dl "https://instagram.com/p/ABC123/"
# → Audio wählen → MP3-Download mit eingebettetem Thumbnail
```

**Twitter-Video (auch ohne Audio):**
```bash
social-dl "https://x.com/user/status/123456789"
# → Funktioniert mit Videos mit und ohne Audio
```

**Reddit-Post:**
```bash
social-dl "https://reddit.com/r/funny/comments/abc123/"
# → Lädt Video aus Reddit-Post
```

**Reddit CDN-Link (direkter Download):**
```bash
social-dl "https://preview.redd.it/xyz.gif?format=mp4"
# → Direkter Download, richtige Dateiendung
```

**TikTok ohne Wasserzeichen:**
```bash
social-dl "https://tiktok.com/@user/video/123"
# → Video wird ohne Wasserzeichen geladen
```

**Parallele Downloads:**
```bash
social-dl "URL1" &
social-dl "URL2" &
social-dl "URL3" &
# Alle 3 laufen parallel, Counter bleibt korrekt!
```

---

## 📁 Dateistruktur

```
~/Downloads/
├── Videos/
│   ├── 2026-01-08_14-30-15-YouTube-001.mp4
│   ├── 2026-01-08_14-31-22-TikTok-002.mp4
│   ├── 2026-01-08_14-32-10-Twitter-003.ts
│   └── 2026-01-08_14-33-05-Reddit-004.mp4
└── Audio/
    └── 2026-01-08_14-35-10-YouTube-001.mp3

~/.social-dl.log         # Download-Historie
~/.social-dl.log.1.old   # Backup 1
~/.social-dl.log.2.old   # Backup 2
~/.social-dl.log.3.old   # Backup 3
```

**Dateinamen-Format:**
```
YYYY-MM-DD_HH-MM-SS-PLATFORM-XXX.ext
│         │         │          │   │
│         │         │          │   └─ Dateityp (mp4, ts, mp3, etc.)
│         │         │          └───── Counter
│         │         └──────────────── Plattform
│         └────────────────────────── Uhrzeit
└──────────────────────────────────── Datum
```

---

## ⚙️ Konfiguration

Bearbeite `~/.local/bin/social-dl` (Zeilen 243–247):

```bash
DOWNLOAD_DIR="$HOME/Downloads/Videos"  # Video-Ordner
AUDIO_DIR="$HOME/Downloads/Audio"      # Audio-Ordner
LOG_MAX_LINES=10000                    # Log-Rotation
DOWNLOAD_TIMEOUT=300                   # Timeout (Sekunden)
```

---

## 🐛 Troubleshooting

### "zenity nicht gefunden" (GUI-Installation)

```bash
sudo apt install zenity      # Debian/Ubuntu
sudo pacman -S zenity        # Arch
sudo dnf install zenity      # Fedora
```

### "yt-dlp nicht gefunden"

```bash
# Arch:
sudo pacman -S yt-dlp

# Debian/Ubuntu:
sudo apt install yt-dlp

# Universal:
pip install --user yt-dlp
```

### "Kein Link in Zwischenablage"

**Lösung 1:** Installiere Clipboard-Tool
```bash
# Wayland:
sudo apt install wl-clipboard

# X11:
sudo apt install xclip
```

**Lösung 2:** URL direkt angeben (in Quotes!)
```bash
social-dl "https://youtube.com/watch?v=..."
```

### "URL enthält potentiell gefährliche Zeichen"

**Problem:** Du verwendest URLs mit `&` ohne Anführungszeichen.

**Lösung:**
```bash
# ✅ RICHTIG:
social-dl "https://instagram.com/reel/ABC/?utm_source=ig&igsh=XYZ"

# ODER: Clipboard nutzen
# URL kopieren (Strg+C), dann:
social-dl
```

### Twitter: "Error opening output files"

Dieses Problem wurde in v2.4.3 behoben. Stelle sicher, dass du die neueste Version installiert hast:
```bash
social-dl --version  # Sollte 2.4.3 oder höher sein
```

### Reddit CDN-Link: Datei ist kaputt

Dieses Problem wurde in v2.4.3 behoben. Reddit CDN-Links (`preview.redd.it`, `v.redd.it`, `i.redd.it`) werden jetzt direkt heruntergeladen mit korrekter Dateiendung.

**Tipp:** Für beste Ergebnisse verwende den Reddit-Post-Link statt des direkten CDN-Links:
```bash
# Besser:
social-dl "https://reddit.com/r/funny/comments/abc123/"

# Funktioniert auch (aber weniger Metadaten):
social-dl "https://preview.redd.it/xyz.gif?format=mp4"
```

### "~/.local/bin nicht im PATH"

```bash
# Fish:
fish_add_path ~/.local/bin

# Bash:
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Zsh:
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Desktop-Icon wird nicht angezeigt

```bash
# Desktop-Database aktualisieren:
update-desktop-database ~/.local/share/applications

# Falls immer noch nicht sichtbar:
killall -3 gnome-shell  # GNOME
# ODER: Logout/Login
```

### Desktop-Icon wird nicht ausgeführt

**Rechtsklick** auf `.desktop` Datei → **Eigenschaften** → **Berechtigung** → ✅ "Datei als Programm ausführen"

Oder Terminal:
```bash
chmod +x social-dl-installer.desktop
chmod +x social-dl-uninstaller.desktop
```

---

## 📦 Paket-Struktur

```
social-dl/
├── social-dl.sh                    # Haupt-Programm
├── install.sh                      # Terminal-Installer
├── install-gui.sh                  # GUI-Installer
├── uninstall-gui.sh                # GUI-Uninstaller
├── social-dl-installer.desktop     # Desktop-Icon Installer
├── social-dl-uninstaller.desktop   # Desktop-Icon Uninstaller
├── Makefile                        # Build-System
├── README.md                       # Diese Datei (Deutsch)
├── README_en.md                    # English documentation
└── LICENSE                         # MIT License
```

---

## 📝 Changelog

### Version 2.4.3 (2026-01-08)

**🐛 Kritische Bugfixes:**
- ✅ **Syntax-Fehler behoben:** Fehlende `fi` in check_version() Funktion
- ✅ **URL-Validierung korrigiert:** `&` aus dangerous_chars entfernt
- ✅ **Tool-Prüfung verschoben:** --help und --version funktionieren ohne yt-dlp
- ✅ **Desktop-Entry Fix:** update-desktop-database wird automatisch aufgerufen
- ✅ **Twitter/X Postprocessing-Fehler:** Entfernt `--add-metadata`
- ✅ **Twitter/X Dateiendungs-Problem:** Explizites Output-Template
- ✅ **Reddit CDN-Support:** Direkter Download mit korrekter Dateiendung

**✨ Neue Features:**
- ✅ **Reddit CDN-Links:** preview.redd.it, v.redd.it, i.redd.it
- ✅ **Twitter-spezifische Behandlung:** Videos mit/ohne Audio
- ✅ **Intelligente Dateiendungs-Erkennung:** Automatische Format-Erkennung
- ✅ **Debug-Ausgabe:** Besseres Troubleshooting

**🔧 Verbesserungen:**
- ✅ Erweiterte URL-Bereinigung (igsh, igshid)
- ✅ Bessere Fehlermeldungen
- ✅ Verbesserte Installer
- ✅ Umfassende Dokumentation

### Version 2.4 (2026-01-07)

**✨ Features:**
- ✅ Audio-Downloads mit eingebettetem Thumbnail
- ✅ Version-Check Feature
- ✅ Mehrsprachigkeit (Deutsch/Englisch)
- ✅ Tracking-Parameter-Entfernung

---

## 🤝 Mitwirken

Contributions sind willkommen!

1. Fork das Repository
2. Erstelle einen Feature-Branch
3. Commit deine Änderungen
4. Push zum Branch
5. Öffne einen Pull Request

---

## 📜 Lizenz

MIT License – siehe [LICENSE](LICENSE) Datei.

**Kurzfassung:** Freie Nutzung, Modifikation und Weitergabe, auch kommerziell.

---

## 🙏 Credits

Entwickelt mit ❤️:
- **Grok** (Basis & Features)
- **Claude** (Security & Production-Ready)  
- **Perplexity** (Edge-Cases & Optimierungen)

**Powered by:**
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) – Video-Downloader
- [Zenity](https://wiki.gnome.org/Projects/Zenity) – GUI-Dialoge

---

## ⚠️ Haftungsausschluss

Dieses Tool ist für den **persönlichen, legalen Gebrauch** gedacht.

- Respektiere Urheberrechte und Nutzungsbedingungen
- Lade nur eigene Inhalte oder mit Erlaubnis herunter
- Der Autor übernimmt keine Haftung für Missbrauch

---

**Version:** 2.4.3  
**Letzte Aktualisierung:** 08. Januar 2026  
**Status:** Production-Ready 🎉
