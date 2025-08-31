#!/usr/bin/env bash
set -euo pipefail

# Robust importer: scans $HOME for dotfiles and copies them to the repo's
# boilerplate/dotfiles/ directory as `.example` files. By default it prompts
# before copying. Use --dry-run to simulate, and --yes to accept all.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST_DIR="$REPO_ROOT/dotfiles"
mkdir -p "$DEST_DIR"

DRY_RUN=false
ASSUME_YES=false
MAX_DEPTH=3

while [[ ${1:-} != "" ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --yes) ASSUME_YES=true; shift ;;
    --depth) MAX_DEPTH="$2"; shift 2 ;;
    -h|--help)
      cat <<EOF
Usage: $(basename "$0") [--dry-run] [--yes] [--depth N]
Scans your home directory for dotfiles and copies selected ones into the repo as .example files.
Options:
  --dry-run   Do not write files; show what would be done
  --yes       Answer yes to all prompts
  --depth N   How deep under your home to search for dotfiles (default: 3)
EOF
      exit 0
      ;;
    *) echo "Unknown arg: $1"; exit 2 ;;
  esac
done

echo "Importer mode: dry-run=$DRY_RUN, assume-yes=$ASSUME_YES, depth=$MAX_DEPTH"

# Patterns to exclude entirely (sensitive or large directories)
EXCLUDE_PATTERNS=(
  ".cache"
  ".local/share"
  ".npm"
  ".node_modules"
  ".Trash"
  ".gnupg"
  ".ssh"
  ".aws"
  "Google"
)

is_excluded() {
  local path="$1"
  for p in "${EXCLUDE_PATTERNS[@]}"; do
    if [[ "$path" == *"/$p"* || "$path" == *"/$p/"* ]]; then
      return 0
    fi
  done
  return 1
}

# Search for visible dotfiles and config files under $HOME
mapfile -t candidates < <(find "$HOME" -maxdepth "$MAX_DEPTH" -type f -name ".*" -print 2>/dev/null || true)

echo "Found ${#candidates[@]} candidate files under $HOME (depth $MAX_DEPTH)."

for src in "${candidates[@]}"; do
  rel="${src#$HOME/}"
  # skip files in excluded patterns
  if is_excluded "$src"; then
    echo "Skipping excluded: $rel"
    continue
  fi

  # skip obvious secret files by name
  if [[ "$rel" =~ (id_rsa|id_ed25519|secret|password|passwd|token|credentials) ]]; then
    echo "Skipping sensitive file by pattern: $rel"
    continue
  fi

  dest="$DEST_DIR/$rel.example"
  mkdir -p "$(dirname "$dest")"

  action_ok=false
  if [ "$ASSUME_YES" = true ]; then
    action_ok=true
  else
    read -r -p "Copy $rel -> ${dest#$(pwd)/}? [y/N] " yn
    yn=${yn:-N}
    if [[ "$yn" =~ ^[Yy]$ ]]; then
      action_ok=true
    fi
  fi

  if [ "$action_ok" = true ]; then
    if [ "$DRY_RUN" = true ]; then
      echo "(dry-run) Would copy: $src -> $dest"
      continue
    fi

    # conservative redaction: if file contains credential-like keys, redact values
    if grep -Ei "(password|secret|token|api_key|aws_access_key_id|aws_secret_access_key)" "$src" >/dev/null 2>&1; then
      echo "Redacting credential-like strings in $rel"
      sed -E 's/(password|secret|token|api_key|aws_access_key_id|aws_secret_access_key)[[:space:]]*[:=].*/\1 = <REDACTED>/Ig' "$src" > "$dest"
    else
      cp -p "$src" "$dest"
    fi
    echo "Copied to $dest"
  else
    echo "Skipped $rel"
  fi
done

echo "Import pass complete. Review $DEST_DIR and commit when ready."
