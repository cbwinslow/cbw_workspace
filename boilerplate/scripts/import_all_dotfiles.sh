#!/usr/bin/env bash
set -euo pipefail

# Wrapper to run the importer non-interactively (use with care)
boilerplate_dir="$(cd "$(dirname "$0")/.." && pwd)"
"$boilerplate_dir/scripts/import_dotfiles.sh" --yes --dry-run
echo "Dry-run complete. Remove --dry-run to actually copy files."
