Chezmoi integration

This folder contains helpers for using `chezmoi` with this repo as the canonical dotfiles store.

Guidance

1. Install chezmoi: https://www.chezmoi.io/
2. Initialize chezmoi with this repository as the source:

   chezmoi init --apply <your-git-remote-or-local-path>

3. Use `chezmoi add` to add files you want managed. You can import example files from `../dotfiles/` first.

Helper scripts

- `init-chezmoi.sh` — small wrapper to initialize chezmoi pointing at this repository (it will not run chezmoi for you; it just prints the recommended commands).
