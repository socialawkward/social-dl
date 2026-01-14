# CLAUDE.md - Social-DL Project Guide

This file provides context for Claude instances working on the Social-DL project.

## Project Overview

**Social-DL** is a universal video/audio downloader for social media platforms with a mobile-inspired GUI.

- **Version:** 2.8.0
- **Language:** Bash with YAD/Zenity GUI
- **Repository:** https://github.com/socialawkward/social-dl
- **Platforms:** Instagram, Twitter/X, YouTube, Reddit, TikTok

## Project Structure

```
social-dl/
├── social-dl.sh              # Main download script (yt-dlp wrapper)
├── upload-to-github.sh       # Build & release automation
├── settings-handlers.sh      # Event-driven settings handlers
├── install.sh                # CLI installer
├── install-gui.sh            # GUI installer (Zenity)
├── uninstall-gui.sh          # GUI uninstaller (Zenity)
├── config.example            # Configuration template
├── ui/
│   ├── mobile-app-ui-yad-tabs.sh   # YAD UI module (primary)
│   ├── mobile-app-ui-zenity.sh     # Zenity UI module (fallback)
│   └── test-mobile-ui.sh           # Standalone UI tester
├── CHANGELOG.md
├── README.md                 # English documentation
├── README.de.md              # German documentation
├── DEVELOPMENT-NOTES.md      # Technical notes & YAD quirks
└── LICENSE
```

### Generated Files (not in git)
```
social-dl-v{VERSION}-app.sh   # Self-contained executable (Base64-embedded)
social-dl-v{VERSION}.tar.gz   # Source package
```

## Key Architecture Decisions

### 1. Dual UI System
- **YAD** is primary (modern, feature-rich)
- **Zenity** is fallback (maximum compatibility)
- Installers stay on Zenity for compatibility

```bash
if command -v yad >/dev/null 2>&1; then
    source "$TEMP_DIR/ui/mobile-app-ui-yad-tabs.sh"
else
    source "$TEMP_DIR/ui/mobile-app-ui-zenity.sh"
fi
```

### 2. Event-Driven Settings (v2.8.0+)
Settings actions are handled by exported functions in `settings-handlers.sh`:

```bash
# Handler is called, then loop continues
if [ "$choice" = "101" ]; then
    handle_config_edit "$lang" "${TEMP_DIR:-/tmp}"
    continue  # Stay in settings loop!
fi
```

**Key insight:** Settings loop never breaks - handlers execute and return.

### 3. Self-Contained App Build
All files are embedded as Base64 in `social-dl-v{VERSION}-app.sh`:

```bash
for file in "${FILES_TO_PACK[@]}"; do
    cat >> "$app_file" << EOF
cat << 'EOF_tag' | base64 -d > "\$TEMP_DIR/$file"
$(base64 -w 0 "$file")
EOF_tag
EOF
done
```

## Critical Technical Details

### YAD Cancel Button Behavior (IMPORTANT!)
YAD returns `exit_code=0` with empty stdout when Cancel is clicked - NOT `exit_code=1`!

```bash
# WRONG (causes infinite loops):
if [ -z "$choice" ]; then
    continue
fi

# CORRECT:
if [ -z "$choice" ]; then
    return 1  # Exit properly!
fi
```

### Button ID Mappings (Mobile App)
```
Main Menu:
  "1" → Install
  "2" → Uninstall
  "3" → README (DE)
  "4" → README (EN)
  "5" → Changelog
  "6" → Info/About
  "7" → Run Download (quick start)
  "8" → Settings menu
  "9" → Language switch

Settings Menu:
  "100" → Back to main menu
  "101" → Config Editor
  "102" → Download Folder
  "103" → Retry Count
  "104" → GitHub Repo
  "105" → System Check
```

### Smart Navigation Design
Main menu and settings menu have buttons aligned at same row positions:
- Main menu row 20: "Settings →"
- Settings row 20: "← Back"

When clicking Settings, mouse lands directly on Back button. This is intentional UX!

## Development Workflow

### Quick Local Testing
```bash
./upload-to-github.sh --local
./social-dl-v2.8.0-app.sh
```

### Full Release
```bash
./upload-to-github.sh --upload
# OR interactive:
./upload-to-github.sh
```

### UI Testing Only
```bash
cd ui/
./test-mobile-ui.sh
```

## Common Tasks

### Adding a New Setting
1. Add handler function in `settings-handlers.sh`
2. Export the function: `export -f handle_new_setting`
3. Add menu entry in `ui/mobile-app-ui-yad-tabs.sh` (both DE and EN)
4. Add handler call in the settings loop
5. Test with `--local` flag

### Changing Version Number
1. Update `SCRIPT_VERSION` in `social-dl.sh:13`
2. Update `CHANGELOG.md`
3. Create `RELEASE-NOTES-v{VERSION}.md` (optional, for detailed notes)

### Adding New Platform Support
1. Add URL pattern check in `social-dl.sh` around line 588
2. Handle any platform-specific yt-dlp arguments
3. Update help text and README files

## Known Quirks & Workarounds

### Desktop Shortcuts Persistence
After uninstall, shortcuts may persist due to DE caching:
- Uninstaller calls `update-desktop-database`
- User may need logout/reboot
- This is a Linux desktop limitation

### Dialog Sizing
All YAD dialogs must be sized generously (min 550x300) to prevent GTK warnings.

### Markup Characters
Use `&amp;` instead of `&` in YAD text to avoid markup errors.

## File Responsibilities

| File | Purpose |
|------|---------|
| `social-dl.sh` | Core download logic, CLI interface |
| `upload-to-github.sh` | Build automation, GitHub releases |
| `settings-handlers.sh` | GUI settings action handlers |
| `ui/mobile-app-ui-yad-tabs.sh` | YAD-based GUI |
| `ui/mobile-app-ui-zenity.sh` | Zenity fallback GUI |
| `install-gui.sh` | Graphical installer |
| `uninstall-gui.sh` | Graphical uninstaller |

## Translation System

The project is bilingual (German/English). Translation uses a `msg()` function:

```bash
msg() {
    local key="$1"
    case "$key" in
        "error_no_clipboard")
            [ "$SCRIPT_LANG" = "de" ] && echo "Fehler: Kein Link!" || echo "Error: No link!"
            ;;
    esac
}
```

Language detection priority:
1. `SOCIAL_DL_LANG` environment variable
2. System locale (`$LANG`)

## Tips for Working on This Project

1. **Always test with `--local` flag** before uploading
2. **Read DEVELOPMENT-NOTES.md** for YAD limitations
3. **Check button IDs carefully** - they're correct in v2.8.0
4. **Keep Zenity fallback working** - code must work without YAD
5. **Use `|| true`** after YAD commands to handle empty returns
6. **Test both languages** (DE and EN) when changing UI

## Dependencies

**Required:**
- `yt-dlp` - Video downloader
- `timeout` - Command timeout (usually pre-installed)

**Recommended:**
- `yad` - Enhanced GUI dialogs
- `zenity` - Fallback GUI dialogs
- `ffmpeg` - Audio conversion

**Optional:**
- `xclip` / `wl-paste` - Clipboard access
- `shotcut` - Video editing integration
- `notify-send` - Desktop notifications

## Configuration

Config file: `~/.config/social-dl/config`

```bash
DOWNLOAD_DIR="$HOME/Downloads/Videos"
AUDIO_DIR="$HOME/Downloads/Audio"
MAX_RETRIES=3
DOWNLOAD_TIMEOUT=300
```

---

*Last updated: 2026-01-14 (v2.8.0)*
