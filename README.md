# My Dotfiles

Dotfiles plus the setup script that turns a bare machine into my working
environment. Runs on macOS, Linux (Fedora) and WSL from the same source.

# Layout

```
setup.sh              the one setup entry point, all platforms
Brewfile.mac          macOS-only casks and VSCode extensions
oh-my-zsh-install.sh  vendored oh-my-zsh installer
bash_includes/        interactive-shell config, sourced via loader.bash
bin/                  small scripts that end up on PATH
dotfiles/             everything stowed into $HOME
```

## Stow

Files under `dotfiles/` are stowed into `$HOME` with
[GNU stow](https://www.gnu.org/software/stow/) — one symlink per top-level
entry. `dotfiles/.zshrc` becomes `~/.zshrc -> ~/.df/dotfiles/.zshrc`, and
`dotfiles/.config` becomes `~/.config -> ~/.df/dotfiles/.config`.

## Shell wiring

`bash_includes/loader.bash` is the single entry point for interactive bash.
It sources `path`, `colors` and `prompt` first, in that order — the prompt is
built out of the colors, and brew binaries have to be on PATH before anything
resolves one — then every other `*.bash` alphabetically, then `~/.secrets` and
`~/.env` last so those win.

Two platforms, two ways in:

```
macOS / WSL   dotfiles/.bashrc  ──sources──▶  bash_includes/loader.bash
Linux         ~/.bashrc.d/00-loader.sh ──symlink──▶  bash_includes/loader.bash
              (Fedora's stock ~/.bashrc globs ~/.bashrc.d/*, so it is left alone)
```

New `*.bash` files are picked up automatically. Only `*.bash` is ever sourced,
so a stray README in that directory cannot break a login shell.

## Secrets

`~/.env` and `~/.secrets` are sourced if present and are **not** in this repo —
`.gitignore` excludes any path containing `env` along with anything named
`.secrets`. Copy them across by hand. `setup.sh` says so when neither exists.

## Tracking files under `.config`

Because `~/.config` is symlinked to `dotfiles/.config`, every app that drops
state, cache or auth tokens there shows up inside this repo. `.gitignore` opts
everything under `dotfiles/.config/*` out by default. To track one you actually
want, force-add past the ignore:

```
git add -f dotfiles/.config/wezterm/wezterm.lua
```

Once tracked, later edits show up in `git status` normally.

# Before setup

Manual steps that are not worth scripting.

## Common

- Connect to Wi-Fi (or ethernet).
- Sign in to whatever app stores / cloud accounts you use.
- Run system updates to current.

## macOS

- Set a login password and TouchID.
- Remap `Caps Lock` to `Escape` (System Settings -> Keyboard -> Modifier Keys).
- On the Touch Bar (if present), replace Siri with Launchpad.
- Turn off "correct spelling automatically" — `defaults write` doesn't fully
  cover this.
- Sign in to iCloud and the App Store.

## Linux

- Install the distro's base development tools (`build-essential` on
  Debian/Ubuntu, `base-devel` on Arch) — Homebrew on Linux needs them.
- Make sure `git` and `curl` are available.

# Setup

`setup.sh` does not clone this repo — it configures the machine around a clone
that already exists. Clone over HTTPS, because the SSH key it generates does
not exist yet:

```
git clone https://github.com/jaypeeZero/dotfiles.git ~/.df
cd ~/.df
./setup.sh
```

Run one section on its own by naming it:

```
./setup.sh shell
./setup.sh packages default_shell
```

Override the repo location with `DF` when it is not `~/.df`.

## Confirming each section

Every section prints what it is about to change — read off the machine's
current state, not a fixed script — and waits for `Y/n` before doing any of it.
Enter accepts:

```
=== default_shell ===
  → add /opt/homebrew/bin/bash to /etc/shells (needs sudo)
  → change the login shell: /bin/zsh -> /opt/homebrew/bin/bash
  Proceed? [Y/n]
```

Declining a section is not a failure — it is listed at the end and the script
still exits 0.

To run unattended, pass `--headless` (or `-y`), which answers Y to everything:

```
./setup.sh --headless
./setup.sh --headless packages fonts
```

Without a terminal to prompt on, sections decline rather than hang, so a
non-interactive run without `--headless` changes nothing.

Two sections still need a human even when confirmed: `ssh_key` waits while you
paste the public key into GitHub, and `default_shell` needs sudo to edit
`/etc/shells`. Under `--headless`, `ssh_key` prints the key and carries on
without waiting — add it to GitHub before anything clones over SSH.

Three guarantees the script keeps:

- **Idempotent.** A second run changes nothing and exits 0. Every section
  reports `—` against work already done and `✓` against work it performed.
- **Nothing changes before you have seen what it would change.** A typo'd
  section name is rejected up front, before any section runs.
- **A failing section never blocks the others,** and never leaves the machine
  worse than not having run. Failures are collected, listed at the end, and the
  script exits non-zero.

## What each section does

| Section | Platforms | Does |
|---|---|---|
| `ssh_key` | all | Generates `~/.ssh/id_rsa` when absent, prints the public half to add at <https://github.com/settings/keys>, adds github.com to `known_hosts` |
| `homebrew` | all | Installs Homebrew when absent, resolves its shellenv, installs `stow` |
| `packages` | all | `brew bundle` over `dotfiles/.Brewfile`, plus `Brewfile.mac` on macOS |
| `shell` | all | macOS/WSL: stows `dotfiles/`. Linux: symlinks `~/.bashrc.d/00-loader.sh` |
| `default_shell` | all | Adds brew's bash to `/etc/shells` and `chsh` to it |
| `neovim` | all | Installs the LazyVim starter, unless `~/.config/nvim` already exists |
| `fonts` | all | Installs Drafting* Mono — no brew package exists for it |
| `prompt_theme` | all | Clones or fast-forwards powerlevel10k into `~/.powerlevel10k` |
| `zsh_framework` | macOS | Runs the vendored oh-my-zsh installer |
| `flatpaks` | Linux | Installs the desktop apps, skipping any already present |

## Why two Brewfiles

Homebrew on Linux supports neither `cask` nor `vscode` entries. Keeping those in
`Brewfile.mac` is what lets `brew bundle` run unmodified against
`dotfiles/.Brewfile` on Fedora.

`setup.sh` passes each Brewfile by path rather than using `brew bundle
--global`, so packages install correctly even before `shell` has stowed
`~/.Brewfile`.

# After setup

`setup.sh` stops at the shell. The Claude Code environment is a separate repo
that installs itself:

```
git clone git@github.com:jaypeeZero/my-claude-settings.git ~/.claude
~/.claude/install.sh
```

That pulls in lean-ctx, the personal skills repo and the git hooks. Run it after
`packages`, since it needs `jq` and bash 4+. The clone is over SSH, so it works
only once `ssh_key` has run and the key has been added to GitHub.

# TODO

- Fold the Claude environment into `setup.sh` as its own section, so a machine
  comes up in one command instead of two.
- The initial clone is over HTTPS and the remote is never switched to SSH
  afterwards.
