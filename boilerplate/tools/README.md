# Boilerplate tools

This folder contains small helper scripts used by the boilerplate repository.

install_bazelisk.sh
- Installs a repo-local `bazel` wrapper (Bazelisk) into a destination directory (default: `.local/bin`).
- Usage examples:

```bash
# dry-run
bash boilerplate/tools/install_bazelisk.sh --dry-run

# install using checksum from versions.lock
bash boilerplate/tools/install_bazelisk.sh --require-checksum --dest ./.local/bin
```

versions.lock
- Format: `tool@version=sha256`
- Populate with the sha256 of the release binary used by the installer. CI is recommended to run the installer with `--require-checksum`.
# Boilerplate tools

This directory contains helper scripts used by the boilerplate repository.

Included:
- `install_bazelisk.sh` - installs a repo-local `bazel` launcher (Bazelisk). Supports checksum verification.
- `versions.lock` - pins tool versions and sha256 checksums. Format: `tool@version=sha256`.

Quick use:

Dry-run:
```bash
bash install_bazelisk.sh --dry-run
```

Install with checksum lookup from `versions.lock`:
```bash
bash install_bazelisk.sh --require-checksum --dest $(pwd)/.local/bin
```

To update the checksum for a tool, download the exact release asset and compute sha256:
```bash
curl -fsSL -o /tmp/binary <URL>
sha256sum /tmp/binary | awk '{print $1}'
```
Then edit `versions.lock` and replace the placeholder or add an entry like:
```
bazelisk@1.20.0=<sha256>
```

CI:
The repository includes a GitHub Actions workflow (`.github/workflows/verify-tools.yml`) which verifies `versions.lock` and runs the installer with `--require-checksum` on push/PR to `boilerplate/tools`.
# Tools and runtime helpers

This directory holds small, safe installers and helper scripts for third-party developer tools we want to treat as part of the master template.

## Bazelisk (what you called "baselisk")

Bazelisk is the recommended Bazel launcher distributed by the Bazel team. It transparently downloads an appropriate Bazel version and acts as `bazel` in your PATH.

Why include Bazelisk here:
- Keeps a repo-local, reproducible launcher for Bazel builds used by templates.
- Makes CI and contributors' developer setup easier by offering a one-line installer.

Files:
- `install_bazelisk.sh` — idempotent installer that downloads a pinned Bazelisk binary into the repo's `.local/bin` by default. Supports `--dest`, `--dry-run`, and `--force`.

Implementation strategy (recommended):

1. Provide a repo-local launcher
   - Add `.local/bin` to the repository (ignored by git) and provide `install_bazelisk.sh` so contributors can run the installer locally.
   - Update README / CONTRIBUTING to instruct contributors to run the installer and add `.local/bin` to their PATH.

2. CI integration
   - In CI jobs that require Bazel, call `boilerplate/tools/install_bazelisk.sh --dest $CI_WORKSPACE/.local/bin --yes` early in the job and add that path to `$PATH` for the job.

3. Versioning and updates
   - Keep `BAZELISK_VERSION` pinned in `install_bazelisk.sh`. Update in PRs when you need newer Bazel functionality.
   - Consider adding a `tools/versions.lock` file if you add more tools, or centralize versions in `boilerplate/TEMPLATE_CATALOG.json`.

4. Security
   - Prefer GitHub release downloads over arbitrary URLs. Verify checksums if you require extra security.

5. Optional: package manager wrappers
   - For distributions where native packages exist, add distro-specific wrappers (APT/Homebrew) that prefer the native package by default but fall back to the repo-local installer.

Example usage (local):

```bash
# dry-run
bash boilerplate/tools/install_bazelisk.sh --dry-run

# install into the repo local bin
bash boilerplate/tools/install_bazelisk.sh --dest $(pwd)/.local/bin

# install and overwrite without prompt
bash boilerplate/tools/install_bazelisk.sh --force --dest $(pwd)/.local/bin
```

If you'd like, I can also:
- Add a `boilerplate/tools/versions.lock` file and register Bazelisk there.
- Add a small GitHub Actions snippet showing how to call the installer in CI.
