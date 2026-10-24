#!/usr/bin/env bash
# Symlink dotfiles into $HOME.
# Anything already at a target path is moved to ~/.dotfiles_backup/<timestamp>/ first.
# Safe to re-run: links that are already correct are left alone.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles_backup/$(date +%Y%m%d-%H%M%S)"

# "path in this repo:path relative to \$HOME"
links=(
  "shell/env:.shell_env"
  "shell/aliases:.aliases"
  "git/gitconfig:.gitconfig"
  "git/ignore:.config/git/ignore"
)

case "$(uname -s)" in
  Darwin)
    links+=(
      "zsh/zshrc:.zshrc"
      "zsh/zprofile:.zprofile"
      "zsh/zshenv:.zshenv"
    )
    ;;
  Linux)
    links+=(
      "bash/bashrc:.bashrc"
    )
    ;;
esac

for pair in "${links[@]}"; do
  rel="${pair#*:}"
  src="$DOTFILES/${pair%%:*}"
  dst="$HOME/$rel"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "ok      ~/$rel"
    continue
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    mkdir -p "$(dirname "$BACKUP/$rel")"
    mv "$dst" "$BACKUP/$rel"
    echo "backup  ~/$rel -> $BACKUP/$rel"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "linked  ~/$rel -> $src"
done

# Git identity is per machine and not tracked in this repo.
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  echo
  echo "note    ~/.gitconfig.local is missing; set this machine's git identity with:"
  echo "          git config --file ~/.gitconfig.local user.name  \"Your Name\""
  echo "          git config --file ~/.gitconfig.local user.email \"you@example.com\""
fi
