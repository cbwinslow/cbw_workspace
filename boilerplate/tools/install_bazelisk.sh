#!/usr/bin/env bash
# Safe Bazelisk installer for the boilerplate repo.
# - default installs into $(pwd)/.local/bin in repo if run from repo root
# - supports --dest, --dry-run, --force

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_DEST="$REPO_ROOT/.local/bin"
DRY_RUN=false
FORCE=false

usage(){
  cat <<EOF
Usage: $(basename "$0") [--dest DIR] [--dry-run] [--force]

Installs Bazelisk (the Bazel launcher) as an executable named 'bazel' into a destination.
By default the script installs into: $DEFAULT_DEST

Options:
  --dest DIR   Destination directory for the bazel binary
  --dry-run    Print actions but don't download or write files
  --force      Overwrite existing file without prompting
  -h, --help    Show this help
EOF
}

while [[ ${#} -gt 0 ]]; do
  case "$1" in
    --dest) DEST="$2"; shift 2;;
    --dry-run) DRY_RUN=true; shift;;
    --force) FORCE=true; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2;;
  esac
done

DEST=${DEST:-$DEFAULT_DEST}
mkdir -p "$DEST"

ARCH=$(uname -m)
OS=$(uname -s)

# Map architecture to Bazelisk release naming
case "$ARCH" in
  x86_64|amd64) ARCH_TAG="amd64";;
  aarch64|arm64) ARCH_TAG="arm64";;
  *) ARCH_TAG="$ARCH";;
esac

case "$OS" in
  Linux) OS_TAG="linux";;
  Darwin) OS_TAG="darwin";;
  *) echo "Unsupported OS: $OS" >&2; exit 3;;
esac

BAZELISK_VERSION="1.20.0" # pinned stable-ish version; update if needed
URL="https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-${OS_TAG}-${ARCH_TAG}"
OUT="$DEST/bazel"

echo "Bazelisk installer"
echo "  version: ${BAZELISK_VERSION}"
echo "  os/arch: ${OS_TAG}/${ARCH_TAG}"
echo "  dest: ${OUT}"

if [[ -f "$OUT" && "$FORCE" != true ]]; then
  echo "Found existing $OUT" >&2
  read -r -p "Overwrite? [y/N] " resp || true
  resp=${resp:-N}
  if [[ ! "$resp" =~ ^[Yy]$ ]]; then
    echo "Aborting: not overwriting"; exit 0
  fi
fi

if [[ "$DRY_RUN" == true ]]; then
  echo "(dry-run) Would download: $URL -> $OUT"
  echo "(dry-run) Would chmod +x $OUT"
  exit 0
fi

echo "Downloading $URL"
curl -fsSL "$URL" -o "$OUT.partial" || { echo "Download failed" >&2; rm -f "$OUT.partial"; exit 4; }
mv "$OUT.partial" "$OUT"
chmod +x "$OUT"

echo "Bazelisk installed to: $OUT"
echo "Add '$DEST' to your PATH, e.g. export PATH=\"$DEST:\$PATH\""

exit 0
