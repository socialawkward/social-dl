#!/bin/bash
# Quick test: Build app only

set -o errexit
set -o nounset
set -o pipefail

VERSION="2.7.0"

source upload-to-github.sh

# Call create_app function directly
create_app "$VERSION"

echo "✅ App created: social-dl-v${VERSION}-app.sh"
echo "Testing syntax..."
bash -n "social-dl-v${VERSION}-app.sh" && echo "✅ Syntax OK"

echo ""
echo "Check line 150:"
sed -n '148,152p' "social-dl-v${VERSION}-app.sh"
