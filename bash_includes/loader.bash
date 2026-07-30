#!/usr/bin/env bash
#
# The one entry point for interactive bash on every platform.
#
#   macOS/WSL : dotfiles/.bashrc sources this directly
#   Linux     : ~/.bashrc.d/00-loader.sh is a symlink to this file, and
#               Fedora's stock ~/.bashrc globs ~/.bashrc.d/*
#
# Location comes from $DF and is never self-resolved: on the Linux side
# BASH_SOURCE reports the symlink path rather than the target, and `readlink -f`
# is not portable to stock macOS.
#
# shellcheck disable=SC1090  # every sourced path is resolved at runtime

DF="${DF:-$HOME/.df}"
_bi="$DF/bash_includes"

case "$(uname -s)" in
    Darwin) _OS=mac   ;;
    Linux)  _OS=linux ;;
esac
[ -n "${WSL_DISTRO_NAME:-}" ] && _OS=wsl
export _OS

# Ordered first: path before anything that resolves a brew binary, colors
# before prompt, which builds PS1 out of $IBlack/$IPurple/$Color_Off.
for _f in path colors prompt; do
    [ -r "$_bi/$_f.bash" ] && . "$_bi/$_f.bash"
done

# Then everything else, alphabetically. New files are picked up automatically;
# only *.bash is ever sourced, so a stray README can't break a login shell.
for _f in "$_bi"/*.bash; do
    case "${_f##*/}" in
        path.bash|colors.bash|prompt.bash|loader.bash) continue ;;
    esac
    [ -r "$_f" ] && . "$_f"
done

# Secrets last so they win over anything above. Both optional, both gitignored.
[ -r "$HOME/.secrets" ] && . "$HOME/.secrets"
[ -r "$HOME/.env" ] && . "$HOME/.env"

unset _f _bi
