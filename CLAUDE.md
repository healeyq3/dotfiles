# CLAUDE.md

Personal dotfiles repo. Config files live here and are symlinked into `$HOME` by `install.sh`. See README.md for the full how-to.

## Layout

- `install.sh`: bash script whose `links=(...)` array holds `"repo/path:path-relative-to-HOME"` pairs. It backs up existing targets to `~/.dotfiles_backup/<timestamp>/` and then symlinks them. It is idempotent.
- `zsh/zshrc` → `~/.zshrc`: PATH setup, `eza` aliases, and a custom prompt built on gitstatus (`my_git_prompt` precmd hook).
- `zsh/zprofile` → `~/.zprofile`: Homebrew shellenv.
- `zsh/zshenv` → `~/.zshenv`: cargo env.
- `git/gitconfig` → `~/.gitconfig`: shared settings only, ending with `[include] path = ~/.gitconfig.local`.
- `git/ignore` → `~/.config/git/ignore`.
- `~/.gitconfig.local` is untracked and holds each machine's git identity. The personal Mac uses the personal identity, and a separate work machine uses the work identity.

## Conventions

- Repo filenames have no leading dot; the target path in `install.sh` adds it.
- When adding a config file, copy it into the repo, add a `links` entry, and run `./install.sh`. Keep README.md's structure tree in sync.
- The files in `~` are symlinks into this repo, so editing `~/.zshrc` edits the repo file directly.
- Guard sourcing of tool-specific files with an existence check (`[[ -f path ]] && . path`) so the config works on machines without that tool.
- Target platform is macOS (Homebrew at `/opt/homebrew`). `install.sh` must stay compatible with macOS's bash 3.2: no associative arrays and no `readlink -f`.
- After editing zsh files, check syntax with `zsh -n zsh/zshrc`.
- Never commit secrets or identity (git name/email, tokens, keys, SSH host details). Put them in untracked `*.local` files.
- Never run `git config --global` for identity, because `~/.gitconfig` is a symlink into this repo. Use `git config --file ~/.gitconfig.local`.
- Keep the `[include]` of `~/.gitconfig.local` at the end of `git/gitconfig` so local values win.
- gitstatus comes from the `romkatv/gitstatus` tap, not homebrew-core: `brew install romkatv/gitstatus/gitstatus`.
