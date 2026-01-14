# CLAUDE.md - Social-DL Project Context

This document provides comprehensive context for Claude instances working on Social-DL.

**Last Updated:** 2026-01-10
**Current Version:** v2.8.0
**Status:** Production-ready, fully tested

---

## Project Overview

**Social-DL** is a universal video & audio downloader for social media platforms (Instagram, Twitter/X, YouTube, Reddit, TikTok) with a mobile-inspired GUI interface.

**Repository:** https://github.com/socialawkward/social-dl
**Developer:** socialawkward
**Language:** Bash with YAD/Zenity GUI
**License:** MIT

---

## Team & Credits

**Development:**
- **socialawkward** (Lead Developer & Architect)
- **Grok (xAI)** (Foundation & Initial Features)
- **Claude (Anthropic)** (v2.8.0 Architecture, Settings Handlers, YAD Integration)
- **Claude (Anthropic)** (v2.7.0 Separate Windows UI, Smart Navigation)
- **Claude (Anthropic)** (Security & Production-Ready)
- **Perplexity** (Edge-Cases & Code Review)

**Powered by:**
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) – Video downloader engine
- [YAD](https://github.com/v1cont/yad) – Modern GUI dialogs (primary)
- [Zenity](https://wiki.gnome.org/Projects/Zenity) – GUI dialogs (fallback)

---

## Quick Commands

```bash
# Run the main script
./social-dl.sh                    # Use URL from clipboard
./social-dl.sh "<URL>"            # Direct URL (must be quoted if contains &)
./social-dl.sh --help             # Show help
./social-dl.sh --version          # Show version
./social-dl.sh --check-update     # Check for updates

# Installation
./install.sh                      # Terminal installer
./install-gui.sh                  # GUI installer (requires zenity)

# Testing the GUI
./ui/test-mobile-ui.sh            # Test mobile app UI standalone

# Build and release
./upload-to-github.sh             # Interactive menu
./upload-to-github.sh --local     # Build only (fast testing)
./upload-to-github.sh --upload    # Full release
```

---

## Architecture

### Core Files

```
social-dl/
├── social-dl.sh              # Main download script (yt-dlp wrapper)
├── upload-to-github.sh       # Build & release automation
├── settings-handlers.sh      # Event-driven settings actions
├── install.sh                # CLI installer
├── install-gui.sh            # GUI installer (Zenity)
├── uninstall-gui.sh          # GUI uninstaller (Zenity)
├── config.example            # Configuration template
├── ui/
│   ├── mobile-app-ui-yad-tabs.sh     # YAD UI module (primary)
│   ├── mobile-app-ui-yad.sh          # Simple YAD version
│   ├── mobile-app-ui-zenity.sh       # Zenity UI module (fallback)
│   └── test-mobile-ui.sh             # Standalone UI tester
├── CHANGELOG.md
├── README.md (English)
├── README.de.md (German)
├── DEVELOPMENT-NOTES.md
└── LICENSE
```

### Generated Files

```
social-dl-v{VERSION}-app.sh   # Self-contained executable (all files embedded as Base64)
social-dl-v{VERSION}.tar.gz   # Source package (includes app)
```

---

## Key Technical Details

### Dependencies

**Required:**
- `yt-dlp` - Video/audio downloader backend
- `timeout` - Command timeout (usually pre-installed)

**Optional:**
- `zenity` - GUI dialogs (required for GUI installation)
- `yad` - Enhanced GUI (better formatting than zenity)
- `xclip` / `wl-paste` - Clipboard support
- `notify-send` - Desktop notifications
- `shotcut` - Video editing integration
- `curl` / `wget` - For Reddit CDN direct downloads
- `ffmpeg` - For audio extraction

### Configuration

User config file: `~/.config/social-dl/config`

```bash
DOWNLOAD_DIR="$HOME/Downloads/Videos"   # Video output
AUDIO_DIR="$HOME/Downloads/Audio"       # Audio output
LOG_FILE="$HOME/.social-dl.log"         # Download history
LOG_MAX_LINES=10000                     # Log rotation threshold
DOWNLOAD_TIMEOUT=300                    # Timeout in seconds
MAX_RETRIES=3                           # Retry attempts on network errors
SCRIPT_LANG="de"                        # Language: "de" or "en"
```

### Supported Platforms

| Platform | Features |
|----------|----------|
| Instagram | Stories, Reels, Posts |
| Twitter/X | Tweets, Videos (with/without audio) |
| YouTube | Videos, Shorts (no playlists) |
| Reddit | Posts, CDN links (v.redd.it, preview.redd.it) |
| TikTok | Videos (often without watermark) |

---

## v2.8.0 Major Changes (Current)

### 1. Event-Driven Settings Architecture

**File:** `settings-handlers.sh`

Settings menu now stays open after executing actions. Clean separation of UI logic vs business logic.

**Pattern:**
```bash
# Handler definition
handle_config_edit() {
    local lang_mode="$1"
    local temp_dir="$2"
    # ... implementation
}
export -f handle_config_edit

# UI module calls it
if [ "$choice" = "101" ]; then
    handle_config_edit "$lang" "${TEMP_DIR:-/tmp}"
    continue  # Stay in settings loop!
fi
```

**Handlers:**
- `handle_config_edit()` - Opens config in text editor
- `handle_download_folder()` - YAD folder picker
- `handle_retry_count()` - YAD entry dialog
- `handle_github_repo()` - Opens browser
- `handle_ytdlp_update()` - **System-Check** (shows versions, NO auto-update!)

### 2. System-Check (NOT System-Update!)

**IMPORTANT:** Does NOT auto-update! Only shows installed versions.

**Detects package manager:**
- pacman (Arch/Manjaro/CachyOS) → Shows `sudo pacman -Syu`
- apt (Debian/Ubuntu) → Shows `sudo apt update && sudo apt upgrade`
- dnf (Fedora) → Shows `sudo dnf upgrade`

### 3. DOWNLOAD Button in Both Menus

Visual highlight with dark background, present in BOTH main menu and settings menu.

---

## Button ID Mappings

### Main Menu (IDs 1-9):

| ID | Icon | German | English | Action |
|----|------|--------|---------|--------|
| 7 | 🚀 | DOWNLOAD | RUN NOW | Start social-dl.sh in terminal |
| 1 | 📥 | Installieren | Install | Run install-gui.sh |
| 2 | 🗑️ | Deinstallieren | Uninstall | Run uninstall-gui.sh |
| 3 | 📖 | README (DE) | README (DE) | Show README.de.md |
| 4 | 📘 | README (EN) | README (EN) | Show README.md |
| 5 | 📋 | Changelog | Changelog | Show CHANGELOG.md |
| 6 | ℹ️ | Info | Info | Show about dialog |
| 8 | ⚙️ | Einstellungen | Settings | Open settings window |
| 9 | 🌐 | Sprache | Language | Toggle DE/EN |

### Settings Menu (IDs 100-105, 7, 9):

| ID | Icon | German | English | Action |
|----|------|--------|---------|--------|
| 7 | 🚀 | DOWNLOAD | RUN NOW | Return to main, start download |
| 101 | 📝 | Config bearbeiten | Edit Config | Open config in editor |
| 102 | 📁 | Download-Ordner | Download Folder | YAD folder picker |
| 103 | 🔄 | Retry-Anzahl | Retry Count | YAD entry dialog |
| 104 | 🌐 | GitHub Repo | GitHub Repo | Open in browser |
| 105 | 🔍 | System-Check | System Check | Show versions |
| 100 | ← | Zurück | Back | Return to main menu |
| 9 | 🌐 | English/Deutsch | Deutsch/English | Toggle language |

---

## Critical Technical Patterns

### Strict Bash Mode
```bash
set -o errexit   # Exit on error
set -o nounset   # Exit on undefined variable
set -o pipefail  # Pipe fails if any command fails
```

**Important:** Due to `errexit`, arithmetic expressions that evaluate to 0 cause exit:
```bash
((COUNTER++)) || true   # Safe increment even when COUNTER=0
```

### YAD Cancel Button Behavior (CRITICAL!)

```bash
# YAD returns exit_code=0 with empty stdout when Cancel/X is clicked!
# This is NOT intuitive - most expect exit_code=1

# WRONG (causes infinite loops):
if [ -z "$choice" ]; then
    continue  # Never exits!
fi

# RIGHT:
if [ -z "$choice" ]; then
    return 1  # Exit properly!
fi
```

### Multilingual Support
All user-facing messages use the `msg()` function:
```bash
msg "key_name"   # Returns German or English based on SCRIPT_LANG
```

### Thread Safety
- Lock files: `$LOG_FILE.lock`
- Uses `flock -x` for exclusive locks
- Stale lock cleanup after 5 minutes

### Status Messages
- Status/debug messages → `>&2` (stderr)
- Return values only → stdout
- This ensures clean command substitution: `result=$(function)`

### File Naming
```
YYYY-MM-DD_HH-MM-SS-PLATFORM-XXX.ext
Example: 2026-01-08_14-30-15-YouTube-001.mp4
```

### Smart Navigation Design
```
Main menu line 20: ⚙️ Einstellungen →
Settings line 20: ← Zurück
```
When user clicks "Settings", mouse automatically lands on "Back" button - no mouse movement needed!

---

## Development Workflow

### Quick Testing (Local Build)
```bash
./upload-to-github.sh --local
./social-dl-v2.8.0-app.sh
```

### Full Release
```bash
./upload-to-github.sh --upload
# OR interactively:
./upload-to-github.sh
# → Choose option 2
```

### Testing UI Changes
```bash
cd ui/
./test-mobile-ui.sh  # Standalone UI tester
```

### Syntax Check
```bash
bash -n filename.sh
```

### Find All Functions
```bash
grep -n "^[a-z_]*() {" filename.sh
```

---

## Known Issues & Quirks

### Desktop Shortcuts Caching
After uninstallation, desktop shortcuts may persist due to DE caching:
- Uninstaller calls `update-desktop-database`
- User may need to logout/reboot
- This is a known Linux desktop limitation, not a bug

### Zenity vs YAD
**Installers remain on Zenity for maximum compatibility:**
- `install-gui.sh` → Zenity
- `uninstall-gui.sh` → Zenity
- Main app → YAD (with Zenity fallback)

### Common Issues
1. **URLs with `&` truncated** - Must be quoted: `"$URL"`
2. **"Argument list too long"** - Use temp files for large data with curl
3. **Empty row highlighting in YAD** - Known limitation, handled gracefully
4. **Cancel returns exit code 0** - Check empty string first, then exit code

---

## Files to Update for New Version

When releasing a new version:
1. `social-dl.sh` - Update `SCRIPT_VERSION="x.x.x"`
2. `CHANGELOG.md` - Add new version entry
3. `README.md` - Update version references, new features
4. `README.de.md` - Same as above (German)
5. `upload-to-github.sh` - Info dialog version (auto-replaced with `__VERSION__`)

---

## Tips for New Claude Instances

1. **Always check CHANGELOG.md first** - Has the most recent changes
2. **Read settings-handlers.sh** - Understanding this pattern is key
3. **Test with --local flag** - Don't upload to GitHub while debugging
4. **Check button IDs carefully** - They've been fixed in v2.8.0
5. **YAD is optional** - Code must work with Zenity fallback
6. **Read DEVELOPMENT-NOTES.md** - Contains important YAD limitations
7. **No auto-updates!** - System-Check only SHOWS versions
8. **Ask before major changes** - User prefers to be consulted first

---

## User Preferences (socialawkward)

- **Language:** German speaker, but ALL code/docs in English
- **OS:** CachyOS (Arch Linux) with Fish shell
- **Style:** Direct, efficient communication
- **Testing:** User tests thoroughly and provides detailed feedback
- **UX:** Cares about polish and user experience
- **Philosophy:** "Ich kann nur Ideen haben und kreativ sein" - User provides vision, AI provides implementation

---

## Version History

| Version | Date | Highlights |
|---------|------|------------|
| v2.8.0 | 2026-01-10 | Event-driven settings, DOWNLOAD button in both menus, System-Check, X-button fix |
| v2.7.0 | 2026-01-09 | Separate windows UI, YAD support, smart navigation |
| v2.6.0 | 2026-01-09 | Retry mechanism, configuration file support |
| v2.5.0 | - | Mobile app packaging, embedded tarball |
| v2.4.0 | - | GUI installer/uninstaller |
| v2.3.0 | - | Bilingual support (DE/EN) |

---

## Development Notes

See `DEVELOPMENT-NOTES.md` for detailed lessons learned, including:
- GitHub API large file uploads (>100KB)
- Bash arithmetic with `set -e`
- Zenity icon sort order
- Base64 self-contained scripts
- YAD GUI limitations

---

*This context document contains everything needed for a new Claude instance to continue Social-DL development.*
