# CLAUDE.md - Social-DL Project Context

This document provides comprehensive context for Claude instances working on Social-DL.

**Last Updated:** 2026-01-14
**Current Version:** v2.7.0
**Status:** Production-ready

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
```

---

## Architecture

### Core Files

```
social-dl/
├── social-dl.sh              # Main download script (~960 lines, yt-dlp wrapper)
├── install.sh                # CLI installer
├── install-gui.sh            # GUI installer (Zenity)
├── uninstall-gui.sh          # GUI uninstaller (Zenity)
├── config.example            # Configuration template
├── Makefile                  # Build system
├── ui/
│   ├── mobile-app-ui-yad-tabs.sh     # YAD UI module (primary)
│   ├── mobile-app-ui-yad.sh          # Simple YAD version
│   ├── mobile-app-ui-zenity.sh       # Zenity UI module (fallback)
│   └── test-mobile-ui.sh             # Standalone UI tester
├── CHANGELOG.md
├── README.md                 # English documentation
├── README.de.md              # German documentation
├── DEVELOPMENT-NOTES.md      # Lessons learned
└── LICENSE
```

### Generated/Release Files

```
social-dl-v{VERSION}-app.sh   # Self-contained executable (all files embedded as Base64)
social-dl-v{VERSION}.tar.gz   # Source package
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

---

## Security Features

The codebase implements several security hardening measures:

### URL Sanitization (`sanitize_url()`)
- Rejects non-printable characters
- Blocks dangerous shell characters: `; | \` $ < > ( ) { }`
- Allows `&` for valid URL query parameters

### Safe File Operations
- All variables properly quoted in `rm`, `mv`, `cp` operations
- Temp files use PID-based naming (`$$`) for uniqueness
- Cleanup via `trap cleanup EXIT`

### No Dangerous Patterns
- No `eval` usage
- No backtick command substitution in user input paths
- No hardcoded credentials

---

## Development Workflow

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

### Version Inconsistencies (README.md)
- Some references to v2.4.6 remain in README.md (download examples)
- Should be updated to current version

---

## Files to Update for New Version

When releasing a new version:
1. `social-dl.sh` - Update `SCRIPT_VERSION="x.x.x"`
2. `CHANGELOG.md` - Add new version entry
3. `README.md` - Update version references, new features
4. `README.de.md` - Same as above (German)

---

## Tips for New Claude Instances

1. **Always check CHANGELOG.md first** - Has the most recent changes
2. **Run `bash -n` on all scripts** - Catches syntax errors
3. **YAD is optional** - Code must work with Zenity fallback
4. **Read DEVELOPMENT-NOTES.md** - Contains important YAD limitations
5. **Ask before major changes** - User prefers to be consulted first
6. **Variables must be quoted** - Especially in file operations

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
| v2.7.0 | 2026-01-09 | Separate windows UI, YAD support, smart navigation, settings window |
| v2.6.0 | 2026-01-09 | Retry mechanism, configuration file support |
| v2.5.0 | 2026-01-09 | English-first approach, separate changelog |
| v2.4.6 | 2026-01-08 | Mobile app with smartphone design |
| v2.4.3 | 2026-01-08 | Reddit CDN support, Twitter fixes |

---

## Development Notes

See `DEVELOPMENT-NOTES.md` for detailed lessons learned, including:
- GitHub API large file uploads (>100KB)
- Bash arithmetic with `set -e`
- Zenity icon sort order
- Base64 self-contained scripts
- YAD GUI limitations and best practices

---

*This context document contains everything needed for a new Claude instance to continue Social-DL development.*
