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
# Usage:  ./setup.sh            run everything for this platform
#         ./setup.sh shell      run one section (see SECTIONS below)

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

FAILED=()

section() { printf '\n\033[1m=== %s ===\033[0m\n' "$1"; }
skip() { printf '  — %s\n' "$1"; }
ok() { printf '  ✓ %s\n' "$1"; }

run() {
    local fn="$1"
    section "$fn"
    if ! "$fn"; then
        printf '  ✗ %s FAILED\n' "$fn"
        FAILED+=("$fn")
    fi
}

# --------------------------------------------------------------------------
# ssh
# --------------------------------------------------------------------------

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
        read -r -p "Press ENTER once the key is added. " _
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

neovim() {
    if [ -e "$HOME/.config/nvim" ]; then
        skip "$HOME/.config/nvim already present"
        return 0
    fi
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim" || return 1
    rm -rf "$HOME/.config/nvim/.git"
    ok "installed LazyVim starter"
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

prompt_theme() {
    if [ -d "$HOME/.powerlevel10k" ]; then
        git -C "$HOME/.powerlevel10k" pull --ff-only >/dev/null || return 1
        skip "powerlevel10k already cloned, updated"
        return 0
    fi
    git clone --depth 1 https://github.com/romkatv/powerlevel10k.git "$HOME/.powerlevel10k" || return 1
    ok "cloned powerlevel10k"
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

flatpaks() {
    if [ "$_OS" = "mac" ]; then
        skip "Linux only"
        return 0
    fi
    command -v flatpak >/dev/null 2>&1 || { skip "flatpak not available"; return 0; }

    local apps=(
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

    local app
    for app in "${apps[@]}"; do
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

main() {
    local to_run=("${SECTIONS[@]}")
    if [ "$#" -gt 0 ]; then
        to_run=("$@")
    fi

    printf 'Platform: %s   Repo: %s\n' "$_OS" "$DF"

    local fn
    for fn in "${to_run[@]}"; do
        run "$fn"
    done

    if [ "${#FAILED[@]}" -eq 0 ]; then
        printf '\n\033[1mAll steps completed.\033[0m\n'
        return 0
    fi

    printf '\n\033[1m%d step(s) failed:\033[0m\n' "${#FAILED[@]}"
    printf '  %s\n' "${FAILED[@]}"
    return 1
}

main "$@"
