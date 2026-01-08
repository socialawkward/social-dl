# Development Notes & Lessons Learned

**Project:** Social-DL  
**Version:** 2.4.6  
**Date:** January 8, 2026  

This document contains all problems encountered during development and their solutions. These notes are published to help other developers avoid the same pitfalls.

---

## Table of Contents

1. [GitHub API: Large File Uploads](#github-api-large-file-uploads)
2. [Bash: Arithmetic Expansion with set -e](#bash-arithmetic-expansion-with-set--e)
3. [Zenity: Maintaining Icon Sort Order](#zenity-maintaining-icon-sort-order)
4. [Base64: Creating Self-Contained Scripts](#base64-creating-self-contained-scripts)
5. [GitHub API: SHA Extraction from JSON](#github-api-sha-extraction-from-json)
6. [Bash: stdout vs stderr in Functions](#bash-stdout-vs-stderr-in-functions)

---

## GitHub API: Large File Uploads

### Problem Statement
When uploading large files (>100KB) to GitHub via API, both `jq` and `curl` fail with "Argument list too long" error.

### Symptoms
```bash
./upload-to-github.sh: line 267: /usr/bin/jq: Die Argumentliste ist zu lang
./upload-to-github.sh: line 292: /usr/bin/curl: Die Argumentliste ist zu lang
```

### Context
- Uploading a 144KB Base64-encoded self-contained app to GitHub
- Using GitHub Contents API: `PUT /repos/{owner}/{repo}/contents/{path}`
- JSON payload contains the Base64 data

### Failed Attempts

#### Attempt 1: jq with --arg ❌
```bash
json_data=$(jq -n \
    --arg message "$commit_message" \
    --arg content "$content" \
    --arg branch "$branch" \
    '{message: $message, content: $content, branch: $branch}')
```
**Why it failed:** Command-line arguments have a size limit (~130KB on most systems). The Base64 content exceeds this.

#### Attempt 2: Manual JSON with curl -d ❌
```bash
json_data=$(cat <<EOF
{
  "message": "$commit_message",
  "content": "$content",
  "branch": "$branch"
}
EOF
)

curl -d "$json_data" ...
```
**Why it failed:** Even though jq is avoided, `curl -d` also passes data as command-line argument.

### Solution ✅

**Use temporary file with --data-binary:**

```bash
# Create JSON in temporary file
json_file="/tmp/github-upload-$$.json"

cat > "$json_file" <<EOF
{
  "message": "$commit_message",
  "content": "$content",
  "branch": "$branch"
}
EOF

# Upload via file (no argument limit!)
response=$(curl -s -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    --data-binary "@$json_file" \
    "$GITHUB_API/repos/$GITHUB_USER/$GITHUB_REPO/contents/$file")

# Cleanup
rm -f "$json_file"
```

### Why This Works
- **File I/O has no size limits** (unlike command-line arguments)
- `--data-binary "@filename"` tells curl to read from file
- The `@` prefix is crucial - it signals file input
- Avoids all command-line argument size limitations

### Key Takeaways
1. **Always use temp files for data >100KB**
2. **Use `--data-binary "@file"` not `-d "$data"`**
3. **Don't forget to cleanup temp files**
4. **Use `$$` for unique temp file names (PID-based)**

### References
- GitHub API: https://docs.github.com/en/rest/repos/contents
- curl man page: `man curl` (see --data-binary)
- Linux argument limit: `getconf ARG_MAX`

---

## Bash: Arithmetic Expansion with set -e

### Problem Statement
When using `set -o errexit` (or `set -e`), arithmetic expansions that evaluate to 0 cause the script to exit.

### Symptoms
```bash
set -o errexit
COUNTER=0
((COUNTER++))  # Script exits here if COUNTER was 0!
echo "This never executes"
```

### Context
- Script uses `set -o errexit` for strict error handling
- Counters are incremented with `((COUNTER++))`
- Script aborts unexpectedly after first file check

### Why This Happens
In bash, arithmetic expansion `((...))` returns:
- **Exit code 0** if result is non-zero
- **Exit code 1** if result is zero

```bash
((0))      # Returns exit code 1 (failure)
((1))      # Returns exit code 0 (success)
((COUNTER++))  # Returns 1 if COUNTER was 0!
```

With `set -e`, any command returning non-zero exits immediately.

### Solution ✅

**Add `|| true` to arithmetic expansions:**

```bash
set -o errexit

UNCHANGED=0
# ... later ...
((UNCHANGED++)) || true  # Never exits, even if result is 0
```

### Alternative Solutions

#### Option 1: Use let (not recommended)
```bash
let COUNTER++ || true
```

#### Option 2: Use arithmetic without expansion
```bash
COUNTER=$((COUNTER + 1))  # Always returns 0 (success)
```

#### Option 3: Disable errexit temporarily
```bash
set +e
((COUNTER++))
set -e
```

### Why `|| true` Is Best
- ✅ Concise (one line)
- ✅ Clear intent (explicitly marking as safe)
- ✅ Doesn't disable errexit for other commands
- ✅ Self-documenting

### Key Takeaways
1. **Always use `|| true` with `((...))` under `set -e`**
2. **This applies to ALL counters: `UPLOADED`, `UPDATED`, `UNCHANGED`**
3. **Alternative: Use `COUNTER=$((COUNTER + 1))` instead**
4. **Test your script with `bash -e` to catch these issues**

### References
- Bash manual: Arithmetic Expansion
- ShellCheck warning SC2219

---

## Zenity: Maintaining Icon Sort Order

### Problem Statement
When using zenity with a two-column list (icon + description), the sort order becomes unpredictable and icons/emojis don't stay aligned with their descriptions.

### Symptoms
```bash
zenity --list \
    --column="Option" --column="Description" \
    "📥 Install" "Install on system" \
    "🗑️  Uninstall" "Remove from system"

# After selection, icons may be missing or reordered
```

### Context
- Creating a GUI menu with emojis/icons for visual clarity
- Using two-column layout (Option | Description)
- Zenity sometimes reorders entries or loses icon association

### Why This Happens
- Zenity uses GTK's TreeView which can auto-sort
- Unicode characters (emojis) may not sort predictably
- When using `--print-column`, the wrong column might be returned
- Row selection might not match text matching in case statements

### Solution ✅

**Use hidden ID column for stable selection:**

```bash
show_menu() {
    CHOICE=$(zenity --list \
        --title="My App" \
        --width=420 --height=520 \
        --column="ID" --column="Option" --column="Description" \
        "1" "📥 Install" "Install on this system" \
        "2" "🗑️  Uninstall" "Remove from this system" \
        "3" "📖 README" "Show documentation" \
        --hide-column=1 --print-column=1)
    
    echo "$CHOICE"
}

# Use ID in case statement (stable!)
case "$CHOICE" in
    "1")  # Install - matches by ID, not text!
        do_install
        ;;
    "2")  # Uninstall
        do_uninstall
        ;;
esac
```

### Why This Works
- **ID column provides stable sort key**
- **--hide-column=1** hides the IDs from user (they see only icons)
- **--print-column=1** returns the ID (not the icon text)
- **Case statement matches on ID** (immune to icon/text changes)
- **Icons and descriptions stay visually aligned**

### Key Takeaways
1. **Always use a hidden ID column for zenity lists with icons**
2. **Use numeric IDs (1, 2, 3...) for clarity**
3. **Match case statements on ID, not text**
4. **This pattern works for all icon-based menus**

### Alternative: Use radiolist
```bash
# Radiolist doesn't need IDs but loses the description column
zenity --list --radiolist \
    --column="" --column="Option" \
    TRUE "📥 Install" \
    FALSE "🗑️  Uninstall"
```

### References
- Zenity manual: `man zenity`
- GTK TreeView documentation

---

## Base64: Creating Self-Contained Scripts

### Problem Statement
Creating a self-contained bash script that embeds multiple files as Base64 and extracts them at runtime.

### Context
- Need to distribute a complete application as single file
- Application consists of multiple scripts, READMEs, config files
- Should work on any Linux system with bash + base64
- Should extract to temp directory and cleanup on exit

### Solution ✅

**Pattern for self-contained scripts:**

```bash
#!/usr/bin/env bash

# Create temp directory with cleanup
TEMP_DIR=$(mktemp -d /tmp/myapp-XXXXXX)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Embed files as Base64
cat << 'EOF_file1' | base64 -d > "$TEMP_DIR/script.sh"
IyEvYmluL2Jhc2gKZWNobyAiSGVsbG8gV29ybGQi
EOF_file1
chmod +x "$TEMP_DIR/script.sh"

cat << 'EOF_file2' | base64 -d > "$TEMP_DIR/README.md"
IyBSRUFETUUKVGhpcyBpcyB0aGUgcmVhZG1lLgo=
EOF_file2

# Use the extracted files
cd "$TEMP_DIR"
./script.sh
```

### Creating the Self-Contained Script

```bash
# Generate the embedded Base64 sections
create_app() {
    local app_file="myapp-v1.0.sh"
    
    # Header
    cat > "$app_file" << 'HEADER_EOF'
#!/usr/bin/env bash
TEMP_DIR=$(mktemp -d /tmp/myapp-XXXXXX)
trap 'rm -rf "$TEMP_DIR"' EXIT
HEADER_EOF
    
    # Embed each file
    for file in script.sh README.md config.json; do
        cat >> "$app_file" << EOF

# === $file ===
cat << 'EOF_$(echo $file | tr '.' '_' | tr '-' '_')' | base64 -d > "\$TEMP_DIR/$file"
$(base64 -w 0 "$file")
EOF_$(echo $file | tr '.' '_' | tr '-' '_')
EOF
        
        # Make scripts executable
        if [[ "$file" == *.sh ]]; then
            echo "chmod +x \"\$TEMP_DIR/$file\"" >> "$app_file"
        fi
    done
    
    # Add your app logic
    cat >> "$app_file" << 'FOOTER_EOF'

# Main application logic
cd "$TEMP_DIR"
# ... your code here ...
FOOTER_EOF
    
    chmod +x "$app_file"
}
```

### Important Considerations

#### 1. Base64 Options
```bash
base64 -w 0 file.txt    # Linux: single line output
base64 file.txt         # macOS: multi-line (also works on Linux)

# For maximum compatibility:
base64 -w 0 "$file" 2>/dev/null || base64 "$file"
```

#### 2. EOF Marker Escaping
```bash
# WRONG - variables get expanded during creation:
cat << EOF
content="$SOME_VAR"
EOF

# RIGHT - quotes prevent expansion:
cat << 'EOF'
content="$SOME_VAR"
EOF
```

#### 3. Unique EOF Markers
```bash
# Convert filename to valid EOF marker
# file.name-v2.sh → EOF_file_name_v2_sh
safe_eof="EOF_$(echo "$file" | tr '.' '_' | tr '-' '_')"
```

#### 4. File Size Limits
- Works well up to ~50MB per file
- Entire script can be 100MB+ (tested with 144KB files)
- No command-line argument limits (data is in heredoc)

### Key Takeaways
1. **Use `trap` for guaranteed cleanup**
2. **Quote EOF markers** (`'EOF'`) to prevent expansion
3. **Use `-w 0` for compact Base64** (single line)
4. **Make extracted scripts executable** with `chmod +x`
5. **cd into temp dir** before running extracted scripts

### Example: Complete Self-Contained App
See `upload-to-github.sh` function `create_app()` for full working example (150+ lines).

---

## GitHub API: SHA Extraction from JSON

### Problem Statement
Extracting the `sha` field from GitHub API JSON responses fails when whitespace varies around the colon.

### Symptoms
```bash
# Works with no spaces:
{"sha":"abc123"}

# Fails with spaces:
{"sha" : "abc123"}
{"sha": "abc123"}
```

### Context
- Using GitHub Contents API to check if file exists
- Need SHA for updating existing files
- GitHub API JSON formatting is inconsistent

### Failed Approach ❌
```bash
# Too strict - only matches no-space format:
sha=$(echo "$response" | grep -o '"sha":"[^"]*"' | cut -d'"' -f4)
```

### Solution ✅

**Use flexible regex pattern:**

```bash
sha=$(echo "$response" | grep -o '"sha"[[:space:]]*:[[:space:]]*"[^"]*"' | \
      grep -o '"[^"]*"$' | tr -d '"')
```

**Breaking it down:**
1. `"sha"[[:space:]]*:[[:space:]]*"[^"]*"` - matches with any whitespace
2. `grep -o '"[^"]*"$'` - extracts just the value (last quoted string)
3. `tr -d '"'` - removes quotes

### Alternative: Use jq (if available)
```bash
sha=$(echo "$response" | jq -r '.sha')
```

### Key Takeaways
1. **Never assume JSON formatting** (spaces vary)
2. **Use `[[:space:]]*` for flexible matching**
3. **jq is more robust** but not always available
4. **Always test with different JSON formats**

---

## Bash: stdout vs stderr in Functions

### Problem Statement
Function that should return a single value pollutes stdout with status messages, breaking the return value.

### Symptoms
```bash
create_tarball() {
    echo "Creating tarball..."  # Oops - goes to stdout!
    tar -czf file.tar.gz ...
    echo "file.tar.gz"  # This is the return value
}

TARBALL=$(create_tarball)
# TARBALL now contains: "Creating tarball...\nfile.tar.gz"
# Expected: "file.tar.gz"
```

### Context
- Function needs to print status messages for user feedback
- Function needs to return a clean value for script logic
- Called with command substitution: `VAR=$(function)`

### Solution ✅

**Redirect status messages to stderr:**

```bash
create_tarball() {
    echo "Creating tarball..." >&2  # To stderr!
    tar -czf file.tar.gz ...
    echo "file.tar.gz"  # Clean return to stdout
}

TARBALL=$(create_tarball)
# TARBALL = "file.tar.gz" ✅
# Status message appears on terminal but not in variable
```

### Pattern for All Status Functions

```bash
my_function() {
    # All status/debug messages to stderr:
    echo "DEBUG: Processing..." >&2
    echo "INFO: Step 1 complete" >&2
    
    # Only return value to stdout:
    echo "$result"
}
```

### Using Helper Functions

```bash
print_info() {
    echo -e "${BLUE}ℹ${NC} $1" >&2  # Always to stderr!
}

print_success() {
    echo -e "${GREEN}✓${NC} $1" >&2
}

create_tarball() {
    print_info "Creating tarball..."  # Stderr
    tar -czf file.tar.gz ...
    print_success "Created file.tar.gz"  # Stderr
    echo "file.tar.gz"  # Stdout - clean return!
}
```

### Key Takeaways
1. **Status messages → stderr (`>&2`)**
2. **Return values → stdout (no redirect)**
3. **Apply consistently** to all helper functions
4. **Makes command substitution work reliably**
5. **User still sees all messages** (stderr shown on terminal)

### Testing
```bash
# Test that return value is clean:
result=$(my_function)
echo "Got: [$result]"  # Should be single clean value

# Test that status messages still appear:
my_function  # Run without capturing - see status messages
```

---

## Additional Notes

### Development Environment
- **OS:** Arch Linux / CachyOS
- **Bash:** 5.x
- **Tools:** zenity, jq, curl, base64, git

### Testing Recommendations
1. **Always test with `set -e`** to catch silent failures
2. **Test with large files** (>100KB) for limit issues
3. **Test with different JSON formats** (varying whitespace)
4. **Test GUI with different themes/resolutions**

### Useful Debug Commands
```bash
# Check argument limit:
getconf ARG_MAX

# Test Base64 size:
base64 -w 0 file | wc -c

# Validate JSON:
echo "$json" | jq '.'

# Test bash without errexit:
bash -c 'set +e; source script.sh'

# Verbose curl:
curl -v ...
```

---

## Contributing

Found another pitfall or better solution? Please contribute:
1. Fork the repository
2. Add your lesson learned to this document
3. Submit a pull request

**Format:**
- Clear problem statement
- Symptoms (error messages, behavior)
- Failed attempts (what didn't work and why)
- Working solution with explanation
- Key takeaways

---

## License

This document is part of the Social-DL project and is released under the MIT License.

**Last Updated:** January 8, 2026  
**Contributors:** Development team & community
