# 📥 Social-DL

> **[English version](README.en.md) available**

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

### Unterstützte Plattformen

| Plattform | Video | Audio | Besonderheiten |
|-----------|-------|-------|----------------|
| Instagram | ✅ | ✅ | Stories, Reels, Posts |
| Twitter/X | ✅ | ✅ | Tweets, Spaces |
| YouTube   | ✅ | ✅ | Videos, Shorts (keine Playlists) |
| Reddit    | ✅ | ✅ | v.redd.it, Gfycat |
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

#### Abhängigkeiten installieren

**Arch/Manjaro/CachyOS:**
```bash
sudo pacman -S yt-dlp zenity xclip wl-clipboard libnotify shotcut
```

**Debian/Ubuntu/Mint:**
```bash
sudo apt update
sudo apt install yt-dlp zenity xclip wl-clipboard libnotify-bin shotcut
```

**Fedora:**
```bash
sudo dnf install yt-dlp zenity xclip wl-clipboard libnotify shotcut
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

# Direkte URL angeben:
social-dl https://youtube.com/watch?v=...

# Hilfe anzeigen:
social-dl --help

# Version anzeigen:
social-dl --version

# Nach Updates suchen:
social-dl --check-update
```

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
social-dl https://youtube.com/watch?v=dQw4w9WgXcQ
# → Video wählen → Qualität 1 → Download mit Progress
```

**Instagram-Audio extrahieren (mit Cover):**
```bash
social-dl https://instagram.com/p/...
# → Audio wählen → MP3-Download mit eingebettetem Thumbnail
```

**TikTok ohne Wasserzeichen:**
```bash
social-dl https://tiktok.com/@user/video/123
# → Video wird ohne Wasserzeichen geladen
```

**Parallele Downloads:**
```bash
social-dl URL1 &
social-dl URL2 &
social-dl URL3 &
# Alle 3 laufen parallel, Counter bleibt korrekt!
```

---

## 📁 Dateistruktur

```
~/Downloads/
├── Videos/
│   ├── 2026-01-08_14-30-15-YouTube-001.mp4
│   └── 2026-01-08_14-31-22-TikTok-002.mp4
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
│         │         │          │   └─ Dateityp
│         │         │          └───── Counter
│         │         └──────────────── Plattform
│         └────────────────────────── Uhrzeit
└──────────────────────────────────── Datum
```

---

## ⚙️ Konfiguration

Bearbeite `~/.local/bin/social-dl` (Zeilen 12–16):

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

**Lösung 2:** URL direkt angeben
```bash
social-dl https://youtube.com/watch?v=...
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
├── README.en.md                    # English documentation
└── LICENSE                         # MIT License
```

---

## 🤝 Mitwirken

Contributions sind willkommen! Siehe [README.en.md](README.en.md) für Details.

---

## 📜 Lizenz

MIT License – siehe [LICENSE](LICENSE) Datei.

**Kurzfassung:** Freie Nutzung, Modifikation und Weitergabe, auch kommerziell.

---

## 🙏 Credits

Entwickelt mit ❤️ basierend auf meinem Feedback und meinen Wünschen:
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

**Version:** 2.4  
**Letzte Aktualisierung:** Januar 2026  
**Status:** Production-Ready 🎉
