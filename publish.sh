#!/bin/bash
# ============================================
# Cipherops Blog - Publish Script
# Usage: ./publish.sh "commit message"
# ============================================
set -e

REPO="$HOME/cipherops-blog"

echo "📝 Publishing to Cipherops blog..."

cd "$REPO"

# Pull latest first
git pull origin main 2>/dev/null

# Add everything
git add .

# Commit with provided message or default
MSG="${1:-publish: $(date '+%Y-%m-%d %H:%M')}"
git commit -m "$MSG"

# Push to GitHub → GitBook auto-syncs
git push origin main

echo ""
echo "✅ Published! GitBook will sync in ~60 seconds"
echo "🔗 https://cipherops.gitbook.io/bug-bounty-notes/"

