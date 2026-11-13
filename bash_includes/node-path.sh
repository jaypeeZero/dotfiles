# shellcheck shell=bash
#
# Puts the node named by the nearest .nvmrc, else nvm's default alias, first on
# PATH. dotfiles/.zshenv sources it for every zsh and exports it as BASH_ENV,
# so every non-interactive bash sources it too.
#
# Not *.bash on purpose: loader.bash must not pick it up, because interactive
# bash gets node from nvm.bash.
#
# bash applies command-line options before it reads BASH_ENV, so every line
# here has to survive `bash -euo pipefail`.

_np_nvm="${NVM_DIR:-$HOME/.nvm}"
_np_dir="$PWD"
_np_want=""
while [ -n "$_np_dir" ]; do
    if [ -r "$_np_dir/.nvmrc" ]; then
        # read fails on a file with no trailing newline, yet still fills the variable.
        read -r _np_want < "$_np_dir/.nvmrc" || true
        break
    fi
    _np_dir="${_np_dir%/*}"
done
if [ -z "$_np_want" ] && [ -r "$_np_nvm/alias/default" ]; then
    _np_dir=""
    read -r _np_want < "$_np_nvm/alias/default" || true
fi
_np_want="${_np_want%$'\r'}"
_np_want="${_np_want#v}"

_np_pick=""
if [ -n "$_np_want" ] && [ -d "$_np_nvm/versions/node" ]; then
    # `command`: an interactive zsh sources this after aliases.bash turns ls into `ls -F`.
    _np_pick="$(command ls "$_np_nvm/versions/node" | sort -V | while read -r _np_v; do
        case "$_np_v" in "v$_np_want" | "v$_np_want".*) printf '%s\n' "$_np_v" ;; esac
    done | tail -1)"
fi

if [ -n "$_np_pick" ]; then
    case "$PATH" in
        "$_np_nvm/versions/node/$_np_pick/bin:"*) ;;
        *) export PATH="$_np_nvm/versions/node/$_np_pick/bin:$PATH" ;;
    esac
elif [ -n "$_np_want" ]; then
    echo "node-path: no nvm install matches '$_np_want' (from ${_np_dir:-nvm default})" >&2
fi
unset _np_nvm _np_dir _np_want _np_pick
