#!/usr/bin/env bash
set -euo pipefail

# Dry-run importer: copies selected files into a temp dir so you can inspect behavior
TMPDIR="$(mktemp -d)"
echo "Dry-run: copying example dotfiles into $TMPDIR"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO_ROOT/scripts/import_dotfiles.sh" || true

echo "Note: this script is a placeholder to remind you to run the interactive importer instead."
