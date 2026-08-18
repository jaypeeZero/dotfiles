#!/usr/bin/env bash
#
# One setup script for every machine. Replaces bootstrap.sh (macOS) and
# my_init.sh (Fedora).
#
# Two rules this script must keep:
#   1. Idempotent — a second run is a no-op and exits 0.
#   2. A failing step never leaves the machine worse than not running at all,
#      and never prevents the remaining steps from running.
#
# Every section says what it is about to change and waits for Y/n before
# touching anything. --headless answers Y to all of them, and is the only way
# to run this unattended.
#
# Usage:  ./setup.sh                  run everything for this platform
#         ./setup.sh shell            run one section (see SECTIONS below)
#         ./setup.sh --headless       run everything, never prompt
#         ./setup.sh --headless shell one section, no prompt

set -uo pipefail

DF="${DF:-$HOME/.df}"

case "$(uname -s)" in
    Darwin) _OS=mac ;;
    Linux) _OS=linux ;;
    *)
        echo "Unsupported platform: $(uname -s)" >&2
        exit 1
        ;;
esac
[ -n "${WSL_DISTRO_NAME:-}" ] && _OS=wsl
export _OS DF

# Space-separated names rather than arrays: stock macOS bash 3.2 treats an
# empty array expansion as an unbound variable under `set -u`, and both of
# these are empty on a clean run.
FAILED=""
DECLINED=""
HEADLESS=false

section() { printf '\n\033[1m=== %s ===\033[0m\n' "$1"; }
skip() { printf '  — %s\n' "$1"; }
ok() { printf '  ✓ %s\n' "$1"; }
will() { printf '  → %s\n' "$1"; }

# Read from the terminal rather than stdin, so the prompt still works when the
# script itself arrives on a pipe.
confirm() {
    [ "$HEADLESS" = true ] && return 0

    # Opening /dev/tty is the real test: `[ -r /dev/tty ]` passes in contexts
    # where the open still fails with "Device not configured". The subshell
    # keeps that failure from taking the script down with it.
    if ! (: < /dev/tty) 2>/dev/null; then
        printf '  no terminal to prompt on — re-run with --headless\n' >&2
        return 1
    fi

    # Initialised because `set -u` would otherwise trip on a read that was
    # interrupted before assigning.
    local reply=""
    read -r -p "  Proceed? [Y/n] " reply < /dev/tty
    case "$reply" in
        n | N | no | NO | No) return 1 ;;
        *) return 0 ;;
    esac
}

run() {
    local fn="$1"
    section "$fn"

    if declare -f "describe_$fn" >/dev/null 2>&1; then
        "describe_$fn"
    fi

    if ! confirm; then
        skip "declined"
        DECLINED="$DECLINED $fn"
        return 0
    fi

    if ! "$fn"; then
        printf '  ✗ %s FAILED\n' "$fn"
        FAILED="$FAILED $fn"
    fi
}

# --------------------------------------------------------------------------
# ssh
# --------------------------------------------------------------------------

describe_ssh_key() {
    if [ -f "$HOME/.ssh/id_rsa" ]; then
        will "keep the existing ~/.ssh/id_rsa"
    else
        will "generate ~/.ssh/id_rsa (RSA 4096, no passphrase)"
        will "print the public key and wait while you add it to GitHub"
    fi

    if ssh-keygen -F github.com >/dev/null 2>&1; then
        will "leave ~/.ssh/known_hosts alone, github.com is already trusted"
    else
        will "append github.com host keys to ~/.ssh/known_hosts"
    fi
}

ssh_key() {
    if [ -f "$HOME/.ssh/id_rsa" ]; then
        skip "key already exists"
    else
        ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N "" || return 1
        ok "generated ~/.ssh/id_rsa"
        echo
        echo "Add this to https://github.com/settings/keys :"
        echo
        cat "$HOME/.ssh/id_rsa.pub"
        echo
        if [ "$HEADLESS" = true ]; then
            echo "Not waiting. Add the key before anything clones over SSH."
        else
            read -r -p "Press ENTER once the key is added. " _
        fi
    fi

    # Append github's host keys rather than overwriting known_hosts, and only
    # when they are not already trusted.
    mkdir -p "$HOME/.ssh"
    touch "$HOME/.ssh/known_hosts"
    if ssh-keygen -F github.com >/dev/null 2>&1; then
        skip "github.com already in known_hosts"
    else
        ssh-keyscan github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null || return 1
        ok "added github.com to known_hosts"
    fi
}

# --------------------------------------------------------------------------
# homebrew
# --------------------------------------------------------------------------

describe_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        will "keep Homebrew at $(brew --prefix)"
    else
        will "download and run the official Homebrew installer"
    fi
    will "install stow"
}

homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        for _b in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
            [ -x "$_b" ] && eval "$("$_b" shellenv)" && break
        done
    fi

    if command -v brew >/dev/null 2>&1; then
        skip "already installed"
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return 1
        for _b in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
            [ -x "$_b" ] && eval "$("$_b" shellenv)" && break
        done
        ok "installed"
    fi

    command -v brew >/dev/null 2>&1 || return 1
    brew install stow >/dev/null || return 1
    ok "stow present"
}

describe_packages() {
    command -v brew >/dev/null 2>&1 || { will "nothing, brew is not installed yet"; return 0; }

    if brew bundle check --file "$DF/dotfiles/.Brewfile" >/dev/null 2>&1; then
        will "dotfiles/.Brewfile: already satisfied"
    else
        will "dotfiles/.Brewfile: install whatever is missing"
    fi

    [ "$_OS" = "mac" ] || return 0

    if brew bundle check --file "$DF/Brewfile.mac" >/dev/null 2>&1; then
        will "Brewfile.mac: casks and VSCode extensions already satisfied"
    else
        will "Brewfile.mac: install missing casks and VSCode extensions"
    fi
}

packages() {
    command -v brew >/dev/null 2>&1 || { skip "no brew, skipping"; return 0; }

    brew bundle --file "$DF/dotfiles/.Brewfile" || return 1
    ok "shared formulae"

    if [ "$_OS" = "mac" ]; then
        brew bundle --file "$DF/Brewfile.mac" || return 1
        ok "macOS casks and VSCode extensions"
    fi
}

# --------------------------------------------------------------------------
# shell wiring — the point of the whole repo
# --------------------------------------------------------------------------

describe_shell() {
    if [ "$_OS" = "mac" ]; then
        will "stow $DF/dotfiles into $HOME, replacing any symlink it owns"
    else
        will "symlink ~/.bashrc.d/00-loader.sh -> $DF/bash_includes/loader.bash"
    fi

    if [ ! -e "$HOME/.env" ] && [ ! -e "$HOME/.secrets" ]; then
        will "warn that neither ~/.env nor ~/.secrets exists, they are hand-carried"
    fi
}

shell() {
    if [ "$_OS" = "mac" ]; then
        # stow places ~/.bashrc, which sources bash_includes/loader.bash
        stow --restow --dir "$DF" --target "$HOME" --ignore='\.DS_Store' dotfiles || return 1
        ok "stowed dotfiles"
    else
        # Fedora ships its own ~/.bashrc which globs ~/.bashrc.d/* — don't
        # overwrite it, feed it a single file instead.
        mkdir -p "$HOME/.bashrc.d" || return 1
        ln -sfn "$DF/bash_includes/loader.bash" "$HOME/.bashrc.d/00-loader.sh" || return 1
        ok "linked ~/.bashrc.d/00-loader.sh -> $DF/bash_includes/loader.bash"
    fi

    if [ ! -e "$HOME/.env" ] && [ ! -e "$HOME/.secrets" ]; then
        skip "no ~/.env or ~/.secrets — copy one over by hand, they are gitignored"
    fi
}

describe_default_shell() {
    command -v brew >/dev/null 2>&1 || { will "nothing, brew is not installed yet"; return 0; }

    local brew_bash
    brew_bash="$(brew --prefix)/bin/bash"

    if [ ! -x "$brew_bash" ]; then
        will "nothing, $brew_bash is not installed"
    elif [ "$SHELL" = "$brew_bash" ]; then
        will "keep $brew_bash as the login shell"
    else
        grep -Fqx "$brew_bash" /etc/shells || will "add $brew_bash to /etc/shells (needs sudo)"
        will "change the login shell: $SHELL -> $brew_bash"
    fi
}

default_shell() {
    command -v brew >/dev/null 2>&1 || { skip "no brew, skipping"; return 0; }

    local brew_bash
    brew_bash="$(brew --prefix)/bin/bash"
    [ -x "$brew_bash" ] || { skip "brew bash not installed"; return 0; }

    if [ "$SHELL" = "$brew_bash" ]; then
        skip "already the login shell"
        return 0
    fi

    if ! grep -Fqx "$brew_bash" /etc/shells; then
        echo "  sudo is needed to add $brew_bash to /etc/shells"
        sudo sh -c "echo $brew_bash >> /etc/shells" || return 1
    fi
    chsh -s "$brew_bash" || return 1
    ok "login shell set to $brew_bash"
}

# --------------------------------------------------------------------------
# editors and fonts
# --------------------------------------------------------------------------

describe_neovim() {
    if [ -e "$HOME/.config/nvim" ]; then
        will "keep the existing ~/.config/nvim"
    else
        will "clone the LazyVim starter into ~/.config/nvim and drop its .git"
    fi
}

neovim() {
    if [ -e "$HOME/.config/nvim" ]; then
        skip "$HOME/.config/nvim already present"
        return 0
    fi
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim" || return 1
    rm -rf "$HOME/.config/nvim/.git"
    ok "installed LazyVim starter"
}

describe_fonts() {
    local font_dir
    case "$_OS" in
        mac) font_dir="$HOME/Library/Fonts" ;;
        *) font_dir="$HOME/.local/share/fonts" ;;
    esac

    if ls "$font_dir"/Drafting*.otf >/dev/null 2>&1; then
        will "keep Drafting* Mono, already in $font_dir"
    else
        will "copy Drafting* Mono .otf/.ttf files into $font_dir"
    fi
}

fonts() {
    # https://github.com/indestructible-type/Drafting — no brew package.
    local font_dir
    case "$_OS" in
        mac) font_dir="$HOME/Library/Fonts" ;;
        *) font_dir="$HOME/.local/share/fonts" ;;
    esac

    if ls "$font_dir"/Drafting*.otf >/dev/null 2>&1; then
        skip "Drafting* Mono already installed"
        return 0
    fi

    mkdir -p "$font_dir" || return 1
    local tmp
    tmp=$(mktemp -d) || return 1
    git clone --depth 1 https://github.com/indestructible-type/Drafting.git "$tmp" || { rm -rf "$tmp"; return 1; }
    find "$tmp" -type f \( -name '*.otf' -o -name '*.ttf' \) -exec cp {} "$font_dir"/ \;
    rm -rf "$tmp"

    if [ "$_OS" != "mac" ] && command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$font_dir"
    fi
    ok "installed Drafting* Mono"
}

describe_prompt_theme() {
    if [ -d "$HOME/.powerlevel10k" ]; then
        will "fast-forward ~/.powerlevel10k"
    else
        will "clone powerlevel10k into ~/.powerlevel10k"
    fi
}

prompt_theme() {
    if [ -d "$HOME/.powerlevel10k" ]; then
        git -C "$HOME/.powerlevel10k" pull --ff-only >/dev/null || return 1
        skip "powerlevel10k already cloned, updated"
        return 0
    fi
    git clone --depth 1 https://github.com/romkatv/powerlevel10k.git "$HOME/.powerlevel10k" || return 1
    ok "cloned powerlevel10k"
}

describe_zsh_framework() {
    if [ "$_OS" != "mac" ]; then
        will "nothing, macOS only"
    elif [ -d "$HOME/.oh-my-zsh" ]; then
        will "keep the existing ~/.oh-my-zsh"
    else
        will "run $DF/oh-my-zsh-install.sh"
    fi
}

zsh_framework() {
    if [ "$_OS" != "mac" ]; then
        skip "macOS only"
        return 0
    fi
    if [ -d "$HOME/.oh-my-zsh" ]; then
        skip "oh-my-zsh already installed"
        return 0
    fi
    "$DF/oh-my-zsh-install.sh" || return 1
    ok "installed oh-my-zsh"
}

# --------------------------------------------------------------------------
# fedora desktop apps (absorbed from my_init.sh)
# --------------------------------------------------------------------------

FLATPAK_APPS=(
    com.discordapp.Discord
    com.slack.Slack
    io.github.zen_browser.zen
    com.rafaelmardojai.Blanket
    com.bitwarden.desktop
    io.dbeaver.DBeaverCommunity
    com.github.IsmaelMartinez.teams_for_linux
    io.freetubeapp.FreeTube
    de.haeckerfelix.Shortwave
    io.github.mhogomchungu.media-downloader
    com.valvesoftware.Steam
    io.mpv.Mpv
    net.lutris.Lutris
)

describe_flatpaks() {
    if [ "$_OS" = "mac" ]; then
        will "nothing, Linux only"
        return 0
    fi
    command -v flatpak >/dev/null 2>&1 || { will "nothing, flatpak is not available"; return 0; }

    local app missing=0
    for app in "${FLATPAK_APPS[@]}"; do
        flatpak info "$app" >/dev/null 2>&1 || missing=$((missing + 1))
    done

    if [ "$missing" -eq 0 ]; then
        will "keep all ${#FLATPAK_APPS[@]} flatpaks, nothing missing"
    else
        will "install $missing of ${#FLATPAK_APPS[@]} flatpaks from flathub"
    fi
}

flatpaks() {
    if [ "$_OS" = "mac" ]; then
        skip "Linux only"
        return 0
    fi
    command -v flatpak >/dev/null 2>&1 || { skip "flatpak not available"; return 0; }

    local app
    for app in "${FLATPAK_APPS[@]}"; do
        if flatpak info "$app" >/dev/null 2>&1; then
            skip "$app"
        else
            flatpak install -y flathub "$app" || return 1
            ok "$app"
        fi
    done
}

# --------------------------------------------------------------------------

SECTIONS=(ssh_key homebrew packages shell default_shell neovim fonts prompt_theme zsh_framework flatpaks)

usage() {
    sed -n '3,18p' "$0" | sed 's/^#\{0,1\} \{0,1\}//'
}

REQUESTED=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        --headless | -y | --yes) HEADLESS=true ;;
        -h | --help)
            usage
            exit 0
            ;;
        -*)
            printf 'Unknown option: %s\n\n' "$1" >&2
            usage >&2
            exit 1
            ;;
        *) REQUESTED="$REQUESTED $1" ;;
    esac
    shift
done

main() {
    local to_run fn
    to_run="${REQUESTED:-${SECTIONS[*]}}"

    # Reject a typo'd section name before any section has changed anything.
    for fn in $to_run; do
        if ! declare -f "$fn" >/dev/null 2>&1; then
            printf 'Unknown section: %s\n' "$fn" >&2
            printf 'Available: %s\n' "${SECTIONS[*]}" >&2
            return 1
        fi
    done

    printf 'Platform: %s   Repo: %s   Mode: %s\n' \
        "$_OS" "$DF" "$([ "$HEADLESS" = true ] && echo headless || echo interactive)"

    for fn in $to_run; do
        run "$fn"
    done

    if [ -n "$DECLINED" ]; then
        printf '\n\033[1mDeclined:\033[0m\n'
        for fn in $DECLINED; do printf '  %s\n' "$fn"; done
    fi

    if [ -n "$FAILED" ]; then
        printf '\n\033[1mFailed:\033[0m\n'
        for fn in $FAILED; do printf '  %s\n' "$fn"; done
        return 1
    fi

    if [ -z "$DECLINED" ]; then
        printf '\n\033[1mAll steps completed.\033[0m\n'
    fi
    return 0
}

main
