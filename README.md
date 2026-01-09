# 📥 Social-DL

> **🌍 Language / Sprache:** [🇩🇪 Deutsch](README.de.md) | 🇬🇧 **English** (current)

**Universal Video & Audio Downloader for Social Media Platforms**

Download videos and audio from Instagram, Twitter/X, YouTube, Reddit, and TikTok with a simple tool. Production-ready, secure, and user-friendly.

---

## 🚀 Quick Install

### 📱 Mobile App (All-in-One, NEW!)

**The easiest method - everything in one file:**

1. **Download:** `social-dl-v2.4.6-app.sh` from [Releases](https://github.com/socialawkward/social-dl/releases)
2. **Make executable:** `chmod +x social-dl-v2.4.6-app.sh`
3. **Start:**
   - **With icon:** Double-click `social-dl-v2.4.6-app.desktop`
   - **Direct:** `./social-dl-v2.4.6-app.sh`

**Mobile App Features:**
- 📱 Smartphone-inspired design
- 🌍 DE/EN language switcher
- 📥 Install/uninstall with one click
- 📖 READMEs viewable directly in GUI
- 🚀 Run directly (test mode)

### 🖱️ Graphical Installation (classic)

1. **Download** the complete package (`social-dl-v2.4.6.tar.gz`)
2. **Extract:** `tar -xzf social-dl-v2.4.6.tar.gz`
3. **Double-click** on `social-dl-installer.desktop`
4. **Done!** Use the program from your application menu

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

- 📱 **Mobile App** - All-in-One GUI with smartphone design (NEW in 2.4.6!)
- ⚡ **Quick Mode** - 1 keystroke for best quality (NEW in 2.4.6!)
- 🔄 **Back Function** - Return to main menu anytime (NEW in 2.4.6!)
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
- 🌍 **Multilingual** (German/English)
- 📦 **Reddit CDN Support** (direct download for preview.redd.it, v.redd.it, i.redd.it)
- 🐦 **Twitter/X Optimized** (special handling for videos with/without audio)

### Supported Platforms

| Platform | Video | Audio | Features |
|----------|-------|-------|----------|
| Instagram | ✅ | ✅ | Stories, Reels, Posts |
| Twitter/X | ✅ | ✅ | Tweets, Spaces, Videos with/without audio |
| YouTube   | ✅ | ✅ | Videos, Shorts (no playlists) |
| Reddit    | ✅ | ✅ | Posts, CDN links (v.redd.it, preview.redd.it) |
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
- `curl` or `wget` (for Reddit CDN links)

#### Install Dependencies

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

# Specify URL directly (IMPORTANT: URLs with & must be quoted!):
social-dl "https://youtube.com/watch?v=ABC&utm_source=share"

# Show help:
social-dl --help

# Show version:
social-dl --version

# Check for updates:
social-dl --check-update
```

### ⚠️ IMPORTANT: URLs with Parameters

URLs containing `&` **must be quoted**:

```bash
# ✅ CORRECT:
social-dl "https://instagram.com/reel/ABC/?utm_source=ig&igsh=XYZ"

# ❌ WRONG (shell truncates URL at &):
social-dl https://instagram.com/reel/ABC/?utm_source=ig&igsh=XYZ
```

**Alternative:** Use the clipboard feature (copy URL with Ctrl+C, then just type `social-dl`)

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
social-dl "https://youtube.com/watch?v=dQw4w9WgXcQ"
# → Choose video → Quality 1 → Download with progress
```

**Extract Instagram audio (with cover):**
```bash
social-dl "https://instagram.com/p/ABC123/"
# → Choose audio → MP3 download with embedded thumbnail
```

**Twitter video (even without audio):**
```bash
social-dl "https://x.com/user/status/123456789"
# → Works with videos with and without audio
```

**Reddit post:**
```bash
social-dl "https://reddit.com/r/funny/comments/abc123/"
# → Downloads video from Reddit post
```

**Reddit CDN link (direct download):**
```bash
social-dl "https://preview.redd.it/xyz.gif?format=mp4"
# → Direct download with correct file extension
```

**TikTok without watermark:**
```bash
social-dl "https://tiktok.com/@user/video/123"
# → Video downloaded without watermark
```

**Parallel downloads:**
```bash
social-dl "URL1" &
social-dl "URL2" &
social-dl "URL3" &
# All 3 run in parallel, counter remains correct!
```

---

## 📁 File Structure

```
~/Downloads/
├── Videos/
│   ├── 2026-01-08_14-30-15-YouTube-001.mp4
│   ├── 2026-01-08_14-31-22-TikTok-002.mp4
│   ├── 2026-01-08_14-32-10-Twitter-003.ts
│   └── 2026-01-08_14-33-05-Reddit-004.mp4
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
│         │         │          │   └─ File type (mp4, ts, mp3, etc.)
│         │         │          └───── Counter
│         │         └──────────────── Platform
│         └────────────────────────── Time
└──────────────────────────────────── Date
```

---

## ⚙️ Configuration

Edit `~/.local/bin/social-dl` (lines 243–247):

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

**Solution 2:** Specify URL directly (quoted!)
```bash
social-dl "https://youtube.com/watch?v=..."
```

### "URL contains potentially dangerous characters"

**Problem:** You're using URLs with `&` without quotes.

**Solution:**
```bash
# ✅ CORRECT:
social-dl "https://instagram.com/reel/ABC/?utm_source=ig&igsh=XYZ"

# OR: Use clipboard
# Copy URL (Ctrl+C), then:
social-dl
```

### Twitter: "Error opening output files"

This problem was fixed in v2.4.3. Make sure you have the latest version installed:
```bash
social-dl --version  # Should be 2.4.3 or higher
```

### Reddit CDN link: File is corrupted

This problem was fixed in v2.4.3. Reddit CDN links (`preview.redd.it`, `v.redd.it`, `i.redd.it`) are now downloaded directly with correct file extension.

**Tip:** For best results, use the Reddit post link instead of the direct CDN link:
```bash
# Better:
social-dl "https://reddit.com/r/funny/comments/abc123/"

# Also works (but less metadata):
social-dl "https://preview.redd.it/xyz.gif?format=mp4"
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

### Desktop icon not showing

```bash
# Update desktop database:
update-desktop-database ~/.local/share/applications

# If still not visible:
killall -3 gnome-shell  # GNOME
# OR: Logout/Login
```

### Desktop icon doesn't execute

**Right-click** on `.desktop` file → **Properties** → **Permissions** → ✅ "Allow executing file as program"

Or terminal:
```bash
chmod +x social-dl-installer.desktop
chmod +x social-dl-uninstaller.desktop
```

---

## 🔧 Development Notes

Developing with Bash and GitHub API yourself? Check out our [Development Notes](DEVELOPMENT-NOTES.md)!

**What you'll find:**
- 💡 **Common pitfalls** and their solutions
- 📦 **GitHub API** handling for large files (>100KB)
- 🐚 **Bash best practices** (set -e, stdout/stderr, etc.)
- 🎨 **GUI development** with Zenity
- 📝 **Base64 self-contained scripts**

**All problems documented with:**
- ❌ What doesn't work (and why)
- ✅ What works (with code examples)
- 💡 Why it works

These notes document real problems from development and help you avoid the same mistakes!

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
├── README.md                       # This file (English)
├── README.de.md                    # German documentation
├── CHANGELOG.md                    # Version history
├── DEVELOPMENT-NOTES.md            # Developer documentation
└── LICENSE                         # MIT License
```

---

## 📝 Version History

**Current Version:** 2.6.0 (2026-01-09)

For detailed release notes and version history, see **[CHANGELOG.md](CHANGELOG.md)**.

### Recent Highlights

- **v2.6.0:** Retry mechanism, config file support, enhanced robustness
- **v2.5.0:** English-first approach, separate changelog, enhanced mobile app
- **v2.4.6:** Mobile app with smartphone design, development notes published
- **v2.4.4-2.4.5:** Quick mode (1-click download), back function

---

## 🤝 Contributing

Contributions welcome!

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

---

## 📜 License

MIT License – see [LICENSE](LICENSE) file.

**Summary:** Free to use, modify, and distribute, including commercial use.

---

## 🙏 Credits

Developed with ❤️:
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

**Version:** 2.4.6  
**Last Update:** January 08, 2026  
**Status:** Production-Ready 🎉
