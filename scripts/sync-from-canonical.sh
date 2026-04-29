#!/usr/bin/env bash
# Sync skills/lingtai/SKILL.md from the canonical lingtai-skill repo.
# Run this whenever the canonical updates; commit the resulting diff.
#
# Usage:
#   scripts/sync-from-canonical.sh                # pull from main
#   scripts/sync-from-canonical.sh v0.5.0         # pull from a tag
set -euo pipefail

REF="${1:-main}"
URL="https://raw.githubusercontent.com/Lingtai-AI/lingtai-skill/${REF}/skills/lingtai/SKILL.md"
DEST="$(cd "$(dirname "$0")/.." && pwd)/skills/lingtai/SKILL.md"

echo "Fetching ${URL}"
curl -fsSL "$URL" -o "$DEST.new"
mv "$DEST.new" "$DEST"
echo "Wrote ${DEST}"
echo
echo "Diff vs HEAD:"
git -C "$(dirname "$DEST")" diff --stat -- SKILL.md || true
