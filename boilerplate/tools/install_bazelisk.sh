#!/usr/bin/env bash
# Safe Bazelisk installer for the boilerplate repo.
# Safe Bazelisk installer for the boilerplate repo.
# - default installs into $(pwd)/.local/bin in repo if run from repo root
# - supports --dest, --dry-run, --force
# - supports optional checksum verification via --checksum or a versions.lock file

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_DEST="$REPO_ROOT/.local/bin"
DRY_RUN=false
FORCE=false
REQUIRE_CHECKSUM=false
EXPECTED_CHECKSUM=""

usage(){
  cat <<EOF
Usage: $(basename "$0") [--dest DIR] [--dry-run] [--force] [--checksum HEX] [--require-checksum]

Installs Bazelisk (the Bazel launcher) as an executable named 'bazel' into a destination.
By default the script installs into: $DEFAULT_DEST

Options:
  --dest DIR            Destination directory for the bazel binary
  --dry-run             Print actions but don't download or write files
  --force               Overwrite existing file without prompting
  --checksum HEX        Expected sha256 checksum for the downloaded binary
  --require-checksum    Fail if no checksum is available or verification can't run
  -h, --help            Show this help
EOF
}

while [[ ${#} -gt 0 ]]; do
  case "$1" in
    --dest) DEST="$2"; shift 2;;
    --dry-run) DRY_RUN=true; shift;;
    --checksum) EXPECTED_CHECKSUM="$2"; shift 2;;
    --require-checksum) REQUIRE_CHECKSUM=true; shift;;
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
VERSIONS_LOCK="$REPO_ROOT/tools/versions.lock"

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
  if [[ -n "$EXPECTED_CHECKSUM" ]]; then
    echo "(dry-run) Would verify checksum: $EXPECTED_CHECKSUM"
  else
    if [[ -f "$VERSIONS_LOCK" ]]; then
      LOCK_VAL=$(grep -E "^bazelisk@${BAZELISK_VERSION}=" "$VERSIONS_LOCK" || true)
      if [[ -n "$LOCK_VAL" ]]; then
        echo "(dry-run) Would verify checksum from $VERSIONS_LOCK: ${LOCK_VAL#*=}"
      fi
    fi
  fi
  echo "(dry-run) Would chmod +x $OUT"
  exit 0
fi

curl -fsSL "$URL" -o "$OUT.partial" || { echo "Download failed" >&2; rm -f "$OUT.partial"; exit 4; }

# If no explicit checksum passed, try to read from versions.lock (format: tool@version=sha256)
if [[ -z "$EXPECTED_CHECKSUM" && -f "$VERSIONS_LOCK" ]]; then
  EXPECTED_CHECKSUM=$(grep -E "^bazelisk@${BAZELISK_VERSION}=" "$VERSIONS_LOCK" | head -n1 | cut -d'=' -f2- || true)
  EXPECTED_CHECKSUM=${EXPECTED_CHECKSUM:-}
fi

if [[ -n "$EXPECTED_CHECKSUM" ]]; then
  echo "Verifying downloaded file checksum against expected value"
  # prefer sha256sum, fallback to shasum
  if command -v sha256sum >/dev/null 2>&1; then
    ACTUAL_CHECKSUM=$(sha256sum "$OUT.partial" | awk '{print $1}')
  elif command -v shasum >/dev/null 2>&1; then
    ACTUAL_CHECKSUM=$(shasum -a 256 "$OUT.partial" | awk '{print $1}')
  else
    echo "No sha256 checksum tool (sha256sum/shasum) available to verify file" >&2
    if [[ "$REQUIRE_CHECKSUM" == true ]]; then
      echo "Checksum required but no tool available to verify" >&2; rm -f "$OUT.partial"; exit 5
    else
      echo "Continuing without checksum verification" >&2
      ACTUAL_CHECKSUM=""
    fi
  fi

  if [[ -n "$ACTUAL_CHECKSUM" ]]; then
    if [[ "$ACTUAL_CHECKSUM" != "$EXPECTED_CHECKSUM" ]]; then
      echo "Checksum mismatch: expected $EXPECTED_CHECKSUM but got $ACTUAL_CHECKSUM" >&2
      rm -f "$OUT.partial"
      exit 5
    fi
    echo "Checksum OK"
  fi
else
  if [[ "$REQUIRE_CHECKSUM" == true ]]; then
    echo "Checksum required but no checksum provided in args or $VERSIONS_LOCK" >&2
    rm -f "$OUT.partial"; exit 6
  else
    echo "No checksum provided; skipping verification (use --require-checksum to enforce)."
  fi
fi

mv "$OUT.partial" "$OUT"
chmod +x "$OUT"

echo "Bazelisk installed to: $OUT"
echo "Add '$DEST' to your PATH, e.g. export PATH=\"$DEST:\$PATH\""

exit 0

