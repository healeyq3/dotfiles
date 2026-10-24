#!/usr/bin/env bash
# Install the packages this config expects.
#   macOS:  Homebrew, from ./Brewfile
#   Ubuntu: apt, from ./packages/apt.txt, plus gitstatus cloned into ~/.local/share
# Safe to re-run.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      echo "Homebrew is not installed; see https://brew.sh" >&2
      exit 1
    fi
    brew bundle --file="$DOTFILES/Brewfile"
    ;;

  Linux)
    if ! command -v apt-get >/dev/null 2>&1; then
      echo "Only apt-based distros (Ubuntu) are supported" >&2
      exit 1
    fi
    sudo apt-get update

    # Strip comments and blank lines; skip packages this release doesn't have.
    available=()
    for pkg in $(sed 's/#.*//' "$DOTFILES/packages/apt.txt"); do
      if apt-cache show "$pkg" >/dev/null 2>&1; then
        available+=("$pkg")
      else
        echo "skip    $pkg (not available in this Ubuntu release's apt repos)"
      fi
    done
    sudo apt-get install -y "${available[@]}"

    gitstatus_dir="$HOME/.local/share/gitstatus"
    if [[ -d "$gitstatus_dir/.git" ]]; then
      git -C "$gitstatus_dir" pull --ff-only
    else
      git clone --depth=1 https://github.com/romkatv/gitstatus.git "$gitstatus_dir"
    fi
    ;;

  *)
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac
