#!/bin/bash
# Quick check: Sind alle Files synchronisiert?

set -o errexit
set -o nounset
set -o pipefail

echo "=== FILE SYNC CHECK ==="
echo ""

# Check 1: Ist settings-handlers.sh im Projekt?
if [ -f "settings-handlers.sh" ]; then
    echo "✅ settings-handlers.sh exists"
else
    echo "❌ settings-handlers.sh MISSING!"
    echo "   → Copy from outputs: cp /path/to/outputs/settings-handlers.sh ."
fi

# Check 2: Hat UI-Modul die Handler-Aufrufe?
if grep -q "handle_config_edit" ui/mobile-app-ui-yad-tabs.sh 2>/dev/null; then
    echo "✅ UI module has handler calls"
else
    echo "❌ UI module OUTDATED!"
    echo "   → Copy from outputs: cp /path/to/outputs/ui/mobile-app-ui-yad-tabs.sh ui/"
fi

# Check 3: Version in social-dl.sh
VERSION=$(grep "SCRIPT_VERSION=" social-dl.sh 2>/dev/null | cut -d'"' -f2)
if [ "$VERSION" = "2.8.0" ]; then
    echo "✅ social-dl.sh version: $VERSION"
else
    echo "⚠️  social-dl.sh version: $VERSION (should be 2.8.0)"
fi

# Check 4: upload-to-github.sh hat settings-handlers in FILES_TO_PACK?
if grep -q "settings-handlers.sh" upload-to-github.sh 2>/dev/null; then
    echo "✅ upload-to-github.sh includes settings-handlers"
else
    echo "❌ upload-to-github.sh OUTDATED!"
fi

echo ""
echo "=== SUMMARY ==="
echo "If any ❌ or ⚠️ above, copy files from /mnt/user-data/outputs/"
