## Boilerplate catalog

This folder is the curated catalog for your personal boilerplate: dotfiles, scripts, full templates, and reusable configs.

Conventions

- Each top-level subfolder is a category: `dotfiles/`, `scripts/`, `templates/`, `configs/`, `gists/`.
- Dotfiles provided as examples must use the `.example` suffix (e.g. `.zshrc.example`) to avoid accidental overwrites.
- `scripts/setup.sh` is an idempotent installer that prompts before making changes.
- Add a short README in each subfolder describing purpose and usage.

How to add new items

1. Add files under the correct category.
2. Update `TEMPLATE_CATALOG.json` with an index entry.
3. Add documentation to the category README.

Support

If you'd like, I can:
- import gists
- add a dotfiles installer per OS
- create per-template generators (cookiecutter, yeoman, or simple bash)
