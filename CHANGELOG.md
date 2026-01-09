# Changelog

All notable changes to Social-DL will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.7.0] - 2026-01-09

### Added
- **YAD Support:** Enhanced GUI with better text alignment and column formatting
  - Centered icons, left-aligned text
  - Precise column widths (360x640 smartphone ratio)
  - Improved visual hierarchy
- **Separate Windows UI:** Main menu with dedicated settings window
  - Smart button alignment (no mouse movement needed between windows)
  - Settings window with config editor, GitHub link, download folder selection
  - Language switcher in both main menu and settings
- **Modular UI Architecture:** Separate UI modules for better maintainability
  - `ui/mobile-app-ui-yad-tabs.sh` - Enhanced YAD version with separate windows
  - `ui/mobile-app-ui-zenity.sh` - Standard Zenity fallback
  - `ui/test-mobile-ui.sh` - Standalone GUI test script
- **Auto-Detection:** Automatically uses YAD if available, falls back to Zenity
- **GUI Test Script:** Test mobile app UI without upload/packaging

### Changed
- **Mobile App GUI:** Now uses modular UI system with auto-detection
- **Optional Dependency:** YAD is optional (recommended for better UI)
- **Backward Compatible:** Works perfectly without YAD installed
- **Settings Access:** Dedicated settings window for configuration options

### Fixed
- **Exit Logic:** Proper handling of cancel button and window close
- **Empty Row Handling:** Graceful handling of disabled row clicks

### Technical
- Mobile app now sources UI modules at runtime (not embedded inline)
- No breaking changes - existing installations continue to work
- UI modules can be tested independently
- Comprehensive YAD limitations documented in DEVELOPMENT-NOTES.md

---

## [2.6.0] - 2026-01-09

### Added
- **Retry Mechanism:** Automatic retry on network errors (default: 3 attempts, configurable)
- **Configuration File Support:** User settings via `~/.config/social-dl/config`
  - Customizable download directories
  - Configurable timeouts and retry attempts
  - Language preference override
- **File Size Validation:** Rejects downloads smaller than 1KB (corrupt file detection)
- **Example Config:** `config.example` file with all available options

### Fixed
- **Lock File Timeout:** Automatically removes stale lock files older than 5 minutes
- **Counter Race Condition:** Prevents file overwrites in parallel downloads by checking file existence
- **Improved Robustness:** Better handling of edge cases and concurrent operations

### Changed
- **Default Retries:** Network errors now retry 3 times before failing (previously failed immediately)
- **Lock Management:** More defensive lock handling with automatic cleanup

---

## [2.5.0] - 2026-01-09

### Changed
- **English-First Approach:** README.md is now in English for international audience
- **Language Structure:** German documentation moved to README.de.md
- **Better Discoverability:** Improved findability for international developers
- **Separate Changelog:** Version history now in dedicated CHANGELOG.md file

### Added
- **Language Switcher:** Easy navigation between English and German documentation
- **Clickable Changelog in App:** Access version history directly from mobile app

### Updated
- **File Structure:** All script references updated for new file naming
- **Upload Automation:** Scripts adjusted for README.md/README.de.md structure
- **Mobile App:** Enhanced GUI with social media platforms in header
- **Mobile App:** "Run now" option more prominent (bottom of menu, highlighted)

---

## [2.4.6] - 2026-01-08

### Added
- **Mobile App (All-in-One):** Self-contained executable with all files embedded
  - Smartphone-inspired design (420x520 responsive layout)
  - Two-column layout with descriptions
  - DE/EN language switcher built-in
  - Desktop launcher (.desktop file) with multimedia icon
  - Install/uninstall directly from GUI
  - READMEs viewable in-app
  - Test mode: Run without installation
- **Development Notes:** Comprehensive documentation of problems and solutions
  - GitHub API: Large file uploads (jq/curl limits)
  - Bash: Arithmetic expansion with set -e
  - Zenity: Icon sort order maintenance
  - Base64: Self-contained script creation
  - GitHub API: SHA extraction from JSON
  - Bash: stdout vs stderr in functions
  - GitHub Releases: Updating existing assets

### Changed
- **Distribution:** Automated packaging with tar.gz + mobile app
- **GitHub Releases:** Automatic creation and asset management

---

## [2.4.4-2.4.5] - 2026-01-08

### Added
- **Quick Mode:** 1-click download with best quality (default)
  - Press `1` or Enter for instant download
  - Fastest workflow for 95% of use cases
- **Back Function:** Return to main menu anytime
  - 2x back options: After audio/video choice and quality selection
  - Flexible navigation without restart

### Changed
- **User Experience:** Drastically reduced inputs (from 3 questions to 1 keystroke)
- **Advanced Mode:** Full control still available (Option 2)
- **Intelligent Flow:** Quick for everyday, Advanced for special cases

---

## [2.4.3] - 2026-01-08

### Fixed
- **Critical Bugfixes:**
  - Syntax error: Missing `fi` in check_version() function
  - URL validation: Removed `&` from dangerous_chars (broke valid URLs)
  - Tool check: --help and --version now work without yt-dlp
  - Desktop entry: update-desktop-database called automatically
  - Twitter/X postprocessing error: Removed `--add-metadata`
  - Twitter/X file extension: Explicit output template `%(ext)s`

### Added
- **Reddit CDN Support:** Direct downloads for preview.redd.it, v.redd.it, i.redd.it
- **Twitter-Specific Handling:** Special treatment for videos with/without audio
- **Intelligent File Extension Detection:** Automatic format detection

### Improved
- Extended URL cleaning (igsh, igshid tracking parameters)
- Better error messages
- Enhanced installers
- Comprehensive documentation

---

## [2.4.0] - 2026-01-07

### Added
- **Audio Downloads:** MP3 with embedded thumbnail (cover art)
- **Version Check:** `--check-update` flag for version checking
- **Multilingual Support:** German/English language detection
- **Tracking Parameter Removal:** Cleans URLs (utm_source, fbclid, igsh, etc.)

### Improved
- Better error handling
- Enhanced documentation
- Improved installers

---

## [2.3.x] - 2026-01-06

### Added
- Clipboard integration (xclip/wl-paste)
- Desktop notifications
- Live progress bar with download speed
- Automatic log rotation (3 backups)
- Shotcut integration (optional video editing)

### Security
- URL sanitization
- Timeouts for all operations
- Thread-safe operations

---

## [2.0.x] - 2026-01-05

### Added
- Multi-platform support:
  - Instagram (Stories, Reels, Posts)
  - Twitter/X (Tweets, Spaces, Videos)
  - YouTube (Videos, Shorts)
  - Reddit (Posts, CDN links)
  - TikTok (Videos, often without watermark)
- Duplicate detection
- Quality selection (Best/1080p/720p/480p)
- Configurable download directory
- GUI installers (Zenity)

---

## [1.x] - 2026-01-04

### Added
- Initial release
- Basic video download functionality
- yt-dlp integration
- Shell compatibility (Bash, Zsh, Fish)

---

## Links

- **Repository:** https://github.com/socialawkward/social-dl
- **Issues:** https://github.com/socialawkward/social-dl/issues
- **Releases:** https://github.com/socialawkward/social-dl/releases
