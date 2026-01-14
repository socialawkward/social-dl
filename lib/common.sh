#!/usr/bin/env bash
# ============================================================================
# Social-DL Common Library
# ============================================================================
# Shared functions and constants for all Social-DL scripts
# Source this file: source "$(dirname "$0")/lib/common.sh"
#
# This file is designed to be sourced, so it does NOT use set -e/u/pipefail
# (those should be set in the parent script)

# Prevent multiple inclusion
[[ -n "${_SOCIAL_DL_COMMON_LOADED:-}" ]] && return 0
_SOCIAL_DL_COMMON_LOADED=1

# ============================================================================
# COLOR DEFINITIONS
# ============================================================================
# Use these for consistent output across all scripts

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# ============================================================================
# ICON DEFINITIONS
# ============================================================================

export ICON_CHECK="✓"
export ICON_CROSS="✗"
export ICON_INFO="ℹ"
export ICON_WARN="⚠"
export ICON_ROCKET="🚀"
export ICON_PACKAGE="📦"

# ============================================================================
# OUTPUT FUNCTIONS
# ============================================================================

print_success() {
    echo -e "${GREEN}${ICON_CHECK}${NC} $1"
}

print_error() {
    echo -e "${RED}${ICON_CROSS}${NC} $1" >&2
}

print_info() {
    echo -e "${BLUE}${ICON_INFO}${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}${ICON_WARN}${NC} $1" >&2
}

# ============================================================================
# LOGGING
# ============================================================================

# Log to file with timestamp
# Usage: log_to_file "INFO" "message" "/path/to/logfile"
log_to_file() {
    local level="${1:-INFO}"
    local message="$2"
    local logfile="${3:-/tmp/social-dl.log}"

    printf "[%s] [%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$message" >> "$logfile"
}

# Debug logging (only if DEBUG=1)
debug_log() {
    [[ "${DEBUG:-0}" == "1" ]] && echo "DEBUG: $*" >&2
}

# ============================================================================
# TERMINAL DETECTION
# ============================================================================

# Detect available terminal emulator
# Returns: terminal command name or empty string
detect_terminal() {
    local terminals=(
        "x-terminal-emulator"
        "konsole"
        "gnome-terminal"
        "xfce4-terminal"
        "mate-terminal"
        "tilix"
        "terminator"
        "alacritty"
        "kitty"
        "xterm"
    )

    for term in "${terminals[@]}"; do
        if command -v "$term" >/dev/null 2>&1; then
            echo "$term"
            return 0
        fi
    done

    return 1
}

# Run command in detected terminal
# Usage: run_in_terminal "command" "window title"
run_in_terminal() {
    local cmd="$1"
    local title="${2:-Terminal}"
    local term

    term=$(detect_terminal) || {
        print_error "No terminal emulator found!"
        return 1
    }

    case "$term" in
        konsole)
            konsole --title "$title" -e bash -c "$cmd" &
            ;;
        gnome-terminal|mate-terminal)
            $term --title="$title" -- bash -c "$cmd" &
            ;;
        xfce4-terminal|tilix|terminator)
            $term --title="$title" -e "bash -c '$cmd'" &
            ;;
        alacritty)
            alacritty --title "$title" -e bash -c "$cmd" &
            ;;
        kitty)
            kitty --title "$title" bash -c "$cmd" &
            ;;
        *)
            $term -e bash -c "$cmd" &
            ;;
    esac
}

# ============================================================================
# DEPENDENCY CHECKS
# ============================================================================

# Check if command exists
# Usage: check_command "yt-dlp" || exit 1
check_command() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1
}

# Check multiple commands
# Usage: check_commands "yt-dlp" "curl" "jq"
# Returns: 0 if all exist, 1 otherwise (prints missing)
check_commands() {
    local missing=()

    for cmd in "$@"; do
        if ! check_command "$cmd"; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        print_error "Missing commands: ${missing[*]}"
        return 1
    fi

    return 0
}

# ============================================================================
# SECURITY HELPERS
# ============================================================================

# Create secure temporary file
# Usage: temp_file=$(create_secure_temp "/tmp/prefix-XXXXXX.ext")
create_secure_temp() {
    local template="${1:-/tmp/social-dl-XXXXXX}"
    local tmpfile

    tmpfile=$(mktemp "$template")
    chmod 600 "$tmpfile"
    echo "$tmpfile"
}

# Create secure temporary directory
# Usage: temp_dir=$(create_secure_temp_dir)
create_secure_temp_dir() {
    local template="${1:-/tmp/social-dl-XXXXXX}"
    local tmpdir

    tmpdir=$(mktemp -d "$template")
    chmod 700 "$tmpdir"
    echo "$tmpdir"
}

# Check if path is a symlink (security check)
# Usage: is_symlink "/path/to/file" && echo "Warning: Symlink!"
is_symlink() {
    [ -L "$1" ]
}

# Validate that file is not world-writable
# Usage: check_file_permissions "/path/to/file"
check_file_permissions() {
    local file="$1"
    local perms

    [ ! -f "$file" ] && return 0

    perms=$(stat -c %a "$file" 2>/dev/null || echo "000")

    # Check if world-writable (last digit is 2, 3, 6, or 7)
    if [[ "$perms" =~ [2367]$ ]]; then
        print_warn "File '$file' is world-writable (permissions: $perms)"
        return 1
    fi

    return 0
}

# ============================================================================
# PATH HELPERS
# ============================================================================

# Get script directory (works even when sourced)
get_script_dir() {
    local source="${BASH_SOURCE[1]:-$0}"
    local dir

    while [ -h "$source" ]; do
        dir="$(cd -P "$(dirname "$source")" && pwd)"
        source="$(readlink "$source")"
        [[ $source != /* ]] && source="$dir/$source"
    done

    cd -P "$(dirname "$source")" && pwd
}

# ============================================================================
# VALIDATION
# ============================================================================

# Validate URL format (basic check)
# Usage: validate_url "https://example.com" || exit 1
validate_url() {
    local url="$1"

    # Must start with http:// or https://
    if [[ ! "$url" =~ ^https?:// ]]; then
        return 1
    fi

    # Check for dangerous characters
    if [[ "$url" =~ [^[:print:]] ]]; then
        return 1
    fi

    # Check for shell metacharacters (except & which is valid in URLs)
    if [[ "$url" =~ [\;\|\`\$\<\>\(\)\{\}] ]]; then
        return 1
    fi

    return 0
}

# Validate language code
# Usage: validate_lang "en" "en de fr" || exit 1
validate_lang() {
    local lang="$1"
    local valid_langs="$2"

    for valid in $valid_langs; do
        if [ "$lang" = "$valid" ]; then
            return 0
        fi
    done

    return 1
}

# ============================================================================
# VERSION INFO
# ============================================================================

COMMON_LIB_VERSION="1.0.0"

# Print library info (for debugging)
common_lib_info() {
    echo "Social-DL Common Library v${COMMON_LIB_VERSION}"
    echo "Loaded from: ${BASH_SOURCE[0]}"
}
