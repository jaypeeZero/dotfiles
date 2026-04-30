# My Dotfiles

This repo contains my dotfiles along with scripts for setting up my preferred environment. I use it on both macOS and Linux and try to keep configs portable across the two.

They are, as dotfiles repos tend to be, under constant construction.

# Layout

Files under `dotfiles/` are stowed into `$HOME` with [GNU stow](https://www.gnu.org/software/stow/) — `stow` creates a symlink in `$HOME` for each top-level entry. For example, `dotfiles/.zshrc` becomes `~/.zshrc -> ~/.df/dotfiles/.zshrc`, and `dotfiles/.config` becomes `~/.config -> ~/.df/dotfiles/.config`.

## Tracking files under `.config`

Because `~/.config` is symlinked to `dotfiles/.config`, every app that drops state, cache, or auth tokens in `~/.config` shows up inside this repo. To keep that noise out, `.gitignore` opts everything under `dotfiles/.config/*` out by default. To track a config you actually want, force-add it past the ignore:

```
git add -f dotfiles/.config/wezterm/wezterm.lua
```

Once tracked, future edits show up in `git status` normally.

# Before Bootstrapping

A few manual steps before running the bootstrap script.

## Common (macOS and Linux)

- Connect to Wi-Fi (or ethernet).
- Sign in to whatever app stores / cloud accounts you use.
- Run system updates to current.

## macOS-specific

- Set a login password and TouchID.
- Remap `Caps Lock` → `Escape` (System Settings → Keyboard → Modifier Keys). Hard to script reliably.
- On the Touch Bar (if present), replace Siri with Launchpad.
- Turn off "correct spelling automatically" — `defaults write` doesn't fully cover this.
- Sign in to iCloud and the App Store.

## Linux-specific

- Install the distro's base development tools (e.g. `build-essential` on Debian/Ubuntu, `base-devel` on Arch) — Homebrew on Linux needs these.
- Make sure `git` and `curl` are available.

# Bootstrapping

The bootstrap script clones this repo to `~/.df`, installs the package manager, stows dotfiles, and runs the rest of the setup.

It expects to be run on the box itself (some steps may require an interactive prompt).

```
bash <(curl -s https://raw.githubusercontent.com/jamespwright/dotfiles/master/bootstrap.sh)
```

## What the bootstrap does

- Generates an SSH key pair if one isn't present, and prints the public key to paste into GitHub.
- Installs Homebrew (used on both macOS and Linux).
- Clones this repo into `~/.df`.
- Stows `dotfiles/` into `$HOME`.
- Installs everything in the `Brewfile`.
- Sets up shell, prompt (powerlevel10k), and editor plugins.

# TODO

- Adjust `.Brewfile` for current app set (VS Code, etc.).
- Make `bootstrap.sh` Linux-aware so the same script works on both platforms (Homebrew install path differs, no `mas`, etc.).
- Audit `macos_defaults.sh` and equivalents for Linux.
