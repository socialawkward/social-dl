# CLAUDE.md - Social-DL Project Context

## Project Overview

**Social-DL** is a universal video and audio downloader for social media platforms, written in Bash. It provides both CLI and GUI interfaces for downloading content from Instagram, Twitter/X, YouTube, Reddit, and TikTok.

**Current Version:** 2.7.0
**Repository:** github.com/socialawkward/social-dl
**License:** MIT

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

## Architecture

```
social-dl/
├── social-dl.sh              # Main CLI script (~960 lines)
├── install.sh                # Terminal installer
├── install-gui.sh            # GUI installer (Zenity)
├── uninstall-gui.sh          # GUI uninstaller
├── ui/                       # UI modules for Mobile App
│   ├── mobile-app-ui-yad-tabs.sh    # Enhanced YAD version with settings
│   ├── mobile-app-ui-yad.sh         # Simple YAD version
│   ├── mobile-app-ui-zenity.sh      # Zenity fallback
│   └── test-mobile-ui.sh            # Standalone GUI test script
├── config.example            # Example configuration file
├── Makefile                  # Build system
├── social-dl-v*.tar.gz       # Release packages
└── social-dl-v*-app.sh       # Self-contained Mobile Apps (Base64 embedded)
```

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

## Code Patterns & Conventions

### Strict Bash Mode
```bash
set -o errexit   # Exit on error
set -o nounset   # Exit on undefined variable
set -o pipefail  # Pipe fails if any command fails
```

**Important:** Due to `errexit`, arithmetic expressions that evaluate to 0 cause exit. Use `|| true`:
```bash
((COUNTER++)) || true   # Safe increment even when COUNTER=0
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

## Development Notes

See `DEVELOPMENT-NOTES.md` for detailed lessons learned, including:
- GitHub API large file uploads (>100KB)
- Bash arithmetic with `set -e`
- Zenity icon sort order
- Base64 self-contained scripts
- YAD GUI limitations

## Testing

```bash
# Test CLI
./social-dl.sh "https://youtube.com/watch?v=dQw4w9WgXcQ"

# Test GUI (requires yad or zenity)
./ui/test-mobile-ui.sh

# Test specific UI backend
YAD_BACKEND=zenity ./ui/test-mobile-ui.sh   # Force Zenity
YAD_BACKEND=yad ./ui/test-mobile-ui.sh      # Force YAD
```

## Building Releases

The project uses a self-contained app approach where all files are embedded as Base64 in a single executable shell script.

Release artifacts:
- `social-dl-v{VERSION}.tar.gz` - Traditional package
- `social-dl-v{VERSION}-app.sh` - Self-contained Mobile App

## Common Issues

1. **URLs with `&` truncated** - Must be quoted: `"$URL"`
2. **"Argument list too long"** - Use temp files for large data with curl
3. **Empty row highlighting in YAD** - Known limitation, handled gracefully
4. **Cancel returns exit code 0** - Check empty string first, then exit code

## Credits

Developed with:
- **Grok** - Base features
- **Claude** - Security hardening, production-readiness
- **Perplexity** - Edge-cases, optimizations

Powered by [yt-dlp](https://github.com/yt-dlp/yt-dlp) and [Zenity](https://wiki.gnome.org/Projects/Zenity)/[YAD](https://github.com/v1cont/yad).
