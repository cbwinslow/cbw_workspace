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
