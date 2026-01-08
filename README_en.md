# 📥 Social-DL

> **[Deutsche Version](README.md) verfügbar**

**Universal Video & Audio Downloader for Social Media Platforms**

Download videos and audio from Instagram, Twitter/X, YouTube, Reddit, and TikTok with a simple tool. Production-ready, secure, and user-friendly.

---

## 🚀 Quick Install

### 🖱️ Graphical Installation (recommended – no terminal!)

1. **Download** the complete package
2. **Double-click** on `social-dl-installer.desktop`
3. **Done!** Use the program from your application menu

**Note:** Requires `zenity` (usually pre-installed)
```bash
# If zenity is missing:
sudo apt install zenity      # Debian/Ubuntu
sudo pacman -S zenity        # Arch/Manjaro
```

### 📟 Terminal Installation (alternative)

```bash
# Quickest method:
./install.sh

# Or with Makefile:
make install-local
```

---

## ✨ Features

- 🎬 **Video Downloads** in selectable quality (Best/1080p/720p/480p)
- 🎵 **Audio-Only Downloads** as MP3 **with embedded thumbnail** (cover art)
- 📋 **Clipboard Integration** (automatic URL detection)
- 🔒 **Thread-Safe** (parallel downloads possible)
- 🚫 **Duplicate Detection** (prevents duplicate downloads)
- 🎨 **Shotcut Integration** (optional video editing)
- 🔔 **Desktop Notifications**
- 📊 **Live Progress Bar** with download speed
- 📁 **Automatic Log Rotation** (with 3 backups)
- 🛡️ **Security-Hardened** (URL sanitization, timeouts)
- 🐟 **Multi-Shell Support** (Bash, Zsh, Fish)
- 🔄 **Version Check** (`--check-update`)

### Supported Platforms

| Platform | Video | Audio | Features |
|----------|-------|-------|----------|
| Instagram | ✅ | ✅ | Stories, Reels, Posts |
| Twitter/X | ✅ | ✅ | Tweets, Spaces |
| YouTube   | ✅ | ✅ | Videos, Shorts (no playlists) |
| Reddit    | ✅ | ✅ | v.redd.it, Gfycat |
| TikTok    | ✅ | ✅ | Best available source (often without watermark) |

---

## 📦 Installation

### Prerequisites

**Required:**
- `yt-dlp` (video downloader)
- `zenity` (for GUI installation)

**Optional (recommended):**
- `xclip` or `wl-paste` (clipboard support)
- `notify-send` (desktop notifications)
- `shotcut` (video editing)

#### Install Dependencies

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

### 🖱️ Graphical Installation (GUI)

The easiest method – **no terminal required!**

1. **Download the package** and extract it
2. **Double-click** on `social-dl-installer.desktop`
3. **Follow the instructions** in the graphical window
4. **Choose installation type:**
   - **Local** (only for your user) – recommended
   - **System-wide** (for all users) – requires permission

**Done!** The program appears in your application menu as "Social Media Downloader"

---

### 📟 Terminal Installation (alternative)

#### Via Installer Script:
```bash
chmod +x install.sh
./install.sh
```

#### Via Makefile:
```bash
# Local installation:
make install-local

# System-wide installation:
sudo make install
```

---

## 🗑️ Uninstallation

### 🖱️ Graphical Uninstallation (GUI)

**Double-click** on `social-dl-uninstaller.desktop`

The uninstaller:
- ✅ Automatically detects local/system-wide installation
- ✅ Asks for permissions when needed
- ✅ Optional: Delete logs and configuration
- ✅ Your downloads remain intact!

---

### 📟 Terminal Uninstallation (alternative)

```bash
# Via installer:
./install.sh --uninstall

# Via Makefile:
make uninstall-local        # Local
sudo make uninstall         # System-wide

# Manual:
rm ~/.local/bin/social-dl
rm ~/.local/share/applications/social-dl.desktop
rm ~/.social-dl.log*  # Optional: logs
```

---

## 🎯 Usage

### Basic Usage

```bash
# Use URL from clipboard:
social-dl

# Specify URL directly:
social-dl https://youtube.com/watch?v=...

# Show help:
social-dl --help

# Show version:
social-dl --version

# Check for updates:
social-dl --check-update
```

### Workflow

1. **Copy URL** (e.g., YouTube link with Ctrl+C)
2. **Open terminal** and type `social-dl`
3. **Answer questions:**
   - Audio or Video?
   - For video: Choose quality (1–4)
   - Optional: Edit with Shotcut?
4. **Wait** – Live progress bar shows download progress
5. **Done!** File in `~/Downloads/Videos/` or `~/Downloads/Audio/`

### Examples

**Download YouTube video:**
```bash
social-dl https://youtube.com/watch?v=dQw4w9WgXcQ
# → Choose video → Quality 1 → Download with progress
```

**Extract Instagram audio (with cover):**
```bash
social-dl https://instagram.com/p/...
# → Choose audio → MP3 download with embedded thumbnail
```

**TikTok without watermark:**
```bash
social-dl https://tiktok.com/@user/video/123
# → Video downloaded without watermark
```

**Parallel downloads:**
```bash
social-dl URL1 &
social-dl URL2 &
social-dl URL3 &
# All 3 run in parallel, counter remains correct!
```

---

## 📁 File Structure

```
~/Downloads/
├── Videos/
│   ├── 2026-01-08_14-30-15-YouTube-001.mp4
│   └── 2026-01-08_14-31-22-TikTok-002.mp4
└── Audio/
    └── 2026-01-08_14-35-10-YouTube-001.mp3

~/.social-dl.log         # Download history
~/.social-dl.log.1.old   # Backup 1
~/.social-dl.log.2.old   # Backup 2
~/.social-dl.log.3.old   # Backup 3
```

**Filename Format:**
```
YYYY-MM-DD_HH-MM-SS-PLATFORM-XXX.ext
│         │         │          │   │
│         │         │          │   └─ File type
│         │         │          └───── Counter
│         │         └──────────────── Platform
│         └────────────────────────── Time
└──────────────────────────────────── Date
```

---

## ⚙️ Configuration

Edit `~/.local/bin/social-dl` (lines 12–16):

```bash
DOWNLOAD_DIR="$HOME/Downloads/Videos"  # Video folder
AUDIO_DIR="$HOME/Downloads/Audio"      # Audio folder
LOG_MAX_LINES=10000                    # Log rotation
DOWNLOAD_TIMEOUT=300                   # Timeout (seconds)
```

---

## 🐛 Troubleshooting

### "zenity not found" (GUI installation)

```bash
sudo apt install zenity      # Debian/Ubuntu
sudo pacman -S zenity        # Arch
sudo dnf install zenity      # Fedora
```

### "yt-dlp not found"

```bash
# Arch:
sudo pacman -S yt-dlp

# Debian/Ubuntu:
sudo apt install yt-dlp

# Universal:
pip install --user yt-dlp
```

### "No link in clipboard"

**Solution 1:** Install clipboard tool
```bash
# Wayland:
sudo apt install wl-clipboard

# X11:
sudo apt install xclip
```

**Solution 2:** Specify URL directly
```bash
social-dl https://youtube.com/watch?v=...
```

### "~/.local/bin not in PATH"

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

### Desktop icon doesn't execute

**Right-click** on `.desktop` file → **Properties** → **Permissions** → ✅ "Allow executing file as program"

Or terminal:
```bash
chmod +x social-dl-installer.desktop
chmod +x social-dl-uninstaller.desktop
```

---

## 📦 Package Structure

```
social-dl/
├── social-dl.sh                    # Main program
├── install.sh                      # Terminal installer
├── install-gui.sh                  # GUI installer
├── uninstall-gui.sh                # GUI uninstaller
├── social-dl-installer.desktop     # Desktop icon installer
├── social-dl-uninstaller.desktop   # Desktop icon uninstaller
├── Makefile                        # Build system
├── README.md                       # This file (German)
├── README.en.md                    # English documentation
└── LICENSE                         # MIT License
```

---

## 🤝 Contributing

Contributions welcome! See [README.en.md](README.en.md) for details.

---

## 📜 License

MIT License – see [LICENSE](LICENSE) file.

**Summary:** Free to use, modify, and distribute, including commercial use.

---

## 🙏 Credits

Developed with ❤️ based on my feedback and wishes:
- **Grok** (Base & Features)
- **Claude** (Security & Production-Ready)
- **Perplexity** (Edge-Cases & Optimizations)

**Powered by:**
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) – Video downloader
- [Zenity](https://wiki.gnome.org/Projects/Zenity) – GUI dialogs

---

## ⚠️ Disclaimer

This tool is intended for **personal, legal use**.

- Respect copyrights and terms of service
- Only download your own content or with permission
- Author assumes no liability for misuse

---

**Version:** 2.4  
**Last Update:** January 2026  
**Status:** Production-Ready 🎉
