# dotfiles

My shell and git configuration, kept under version control and symlinked into `$HOME` by `install.sh`.
The approach follows MIT's [Missing Semester](https://missing.csail.mit.edu/2026/command-line-environment/) dotfiles lecture.

## Structure

```
~/dotfiles/
├── install.sh        # symlinks everything into ~
├── zsh/
│   ├── zshrc         → ~/.zshrc      (aliases, gitstatus prompt)
│   ├── zprofile      → ~/.zprofile   (Homebrew shellenv)
│   └── zshenv        → ~/.zshenv     (cargo env)
└── git/
    ├── gitconfig     → ~/.gitconfig  (shared settings; includes ~/.gitconfig.local)
    └── ignore        → ~/.config/git/ignore   (global gitignore)

~/.gitconfig.local    # NOT in the repo: this machine's git name/email
```

Files in the repo have no leading dot so they're visible; `install.sh` maps each one to its real location.

## Setting up a new machine

```sh
# 1. Homebrew (https://brew.sh), then the tools the zsh config uses
brew install romkatv/gitstatus/gitstatus eza

# 2. Clone and link
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh

# 3. Git identity for this machine (personal or work), kept out of the repo
git config --file ~/.gitconfig.local user.name  "Your Name"
git config --file ~/.gitconfig.local user.email "you@example.com"
```

Open a new terminal tab to pick up the config.

## Git identity

The shared `git/gitconfig` holds no personal info. It ends with
`[include] path = ~/.gitconfig.local`, and that untracked file holds the identity for each machine.
My personal Mac has my personal identity there, and my work machine has my work identity.

Because `~/.gitconfig` is a symlink into this repo, **`git config --global ...` writes into the repo**.
Use `git config --file ~/.gitconfig.local ...` for anything machine-specific or private.

## How `install.sh` works

For each entry in its `links=(...)` list, it:

- does nothing if the correct symlink is already in place (`ok`),
- otherwise moves any existing file at the target to `~/.dotfiles_backup/<timestamp>/` (`backup`),
- then creates the symlink (`linked`).

It's safe to re-run at any time.

## Day-to-day use

- **Editing:** edit `~/.zshrc` (or the file in the repo, which is the same file), then commit from `~/dotfiles`.
- **Adding a new config file:**
  1. Copy it into the repo, without the leading dot, e.g. `cp ~/.vimrc vim/vimrc`.
  2. Add a line to `links` in `install.sh`, e.g. `"vim/vimrc:.vimrc"`.
  3. Run `./install.sh`. It backs up the original and links in the repo copy.
  4. Commit.
- **Removing a file:** delete its line from `install.sh`, then replace the symlink with a real copy:
  `cp ~/dotfiles/foo/foorc /tmp/foorc && rm ~/.foorc && mv /tmp/foorc ~/.foorc`.

## Portability

Lines that source tool-specific files (uv, cargo, gitstatus) check that the file exists first, so a fresh machine without those tools starts a shell without errors.
Follow the same pattern for anything machine-specific: `[[ -f path ]] && . path`.

## Notes

- Don't commit secrets or identifying info, such as git name/email, tokens, private keys, or a `~/.ssh/config` with real hosts.
  Put them in untracked `*.local` files that the tracked config includes or sources.
