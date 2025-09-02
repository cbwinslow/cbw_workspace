#!/usr/bin/env bash
set -euo pipefail

BAZELISK_VERSION=${1:-1.20.0}
TMPDIR=${TMPDIR:-/tmp}

echo "Generating sha256 checksums for bazelisk v${BAZELISK_VERSION}"

download_and_sha() {
  os=$1
  arch=$2
  fname="bazelisk-${os}-${arch}"
  url="https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/${fname}"
  tmpfile="$TMPDIR/${fname}" 
  echo "Downloading $url"
  curl -fsSL -o "$tmpfile" "$url"
  sha=$(sha256sum "$tmpfile" | awk '{print $1}')
  echo "${os}_${arch}: $sha"
  rm -f "$tmpfile"
}

PLATFORMS=("linux amd64" "linux arm64" "darwin amd64" "darwin arm64")
for p in "${PLATFORMS[@]}"; do
  set -- $p
  download_and_sha $1 $2
done

echo "Done. Use the printed hashes to populate boilerplate/tools/versions.lock"
