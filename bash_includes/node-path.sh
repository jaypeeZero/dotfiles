# shellcheck shell=bash
#
# Puts the node named by the nearest .nvmrc, else nvm's default alias, else the
# newest nvm install, first on PATH. Each step that names a version with no
# matching install falls through to the next. With no nvm install at all, the
# newest `node` already on PATH goes first. dotfiles/.zshenv sources it for every zsh and exports it as
# BASH_ENV, so every non-interactive bash sources it too.
#
# Not *.bash on purpose: loader.bash must not pick it up, because interactive
# bash gets node from nvm.bash.
#
# bash applies command-line options before it reads BASH_ENV, so every line
# here has to survive `bash -euo pipefail`.

_np_nvm="${NVM_DIR:-$HOME/.nvm}"

# _np_read <file> -> first line of <file>, minus a CR and a leading "v"
_np_read() {
    local line=""
    # read fails on a file with no trailing newline, yet still fills the variable.
    read -r line < "$1" || true
    line="${line%$'\r'}"
    printf '%s' "${line#v}"
}

# _np_match [version] -> newest installed vX.Y.Z matching [version], or the
# newest install of all when [version] is omitted; nothing when none match
_np_match() {
    [ -d "$_np_nvm/versions/node" ] || return 0
    # `command`: an interactive zsh sources this after aliases.bash turns ls into `ls -F`.
    command ls "$_np_nvm/versions/node" | sort -V | while read -r _np_v; do
        if [ "$#" -eq 0 ]; then
            case "$_np_v" in v[0-9]*) printf '%s\n' "$_np_v" ;; esac
        else
            case "$_np_v" in "v$1" | "v$1".*) printf '%s\n' "$_np_v" ;; esac
        fi
    done | tail -1
}

# _np_newest_outside -> the PATH dir holding the newest `node`, or nothing when
# that dir already holds the first `node` on PATH
_np_newest_outside() {
    local rest="$PATH:" dir v first="" best="" best_v=""
    while [ -n "$rest" ]; do
        dir="${rest%%:*}"
        rest="${rest#*:}"
        [ -n "$dir" ] && [ -x "$dir/node" ] || continue
        v="$("$dir/node" --version 2>/dev/null)" || continue
        [ -n "$first" ] || first="$dir"
        if [ -z "$best" ] || [ "$(printf '%s\n%s\n' "${best_v#v}" "${v#v}" | sort -V | tail -1)" != "${best_v#v}" ]; then
            best="$dir"
            best_v="$v"
        fi
    done
    [ "$best" = "$first" ] || printf '%s' "$best"
}

# _np_strip_nvm -> $PATH without any nvm version's bin dir, so a re-run in
# another directory replaces the earlier pick rather than stacking on it
_np_strip_nvm() {
    local rest="$PATH:" dir out="" sep=""
    while [ -n "$rest" ]; do
        dir="${rest%%:*}"
        rest="${rest#*:}"
        case "$dir" in "$_np_nvm"/versions/node/*/bin) continue ;; esac
        out="$out$sep$dir"
        sep=":"
    done
    printf '%s' "$out"
}

_np_dir="$PWD"
_np_pick=""
while [ -n "$_np_dir" ]; do
    if [ -r "$_np_dir/.nvmrc" ]; then
        _np_want="$(_np_read "$_np_dir/.nvmrc")"
        if [ -n "$_np_want" ]; then
            _np_pick="$(_np_match "$_np_want")"
            [ -n "$_np_pick" ] ||
                echo "node-path: no nvm install matches '$_np_want' (from $_np_dir)" >&2
        fi
        break
    fi
    _np_dir="${_np_dir%/*}"
done

if [ -z "$_np_pick" ] && [ -r "$_np_nvm/alias/default" ]; then
    _np_want="$(_np_read "$_np_nvm/alias/default")"
    [ -z "$_np_want" ] || _np_pick="$(_np_match "$_np_want")"
fi

[ -n "$_np_pick" ] || _np_pick="$(_np_match)"

if [ -n "$_np_pick" ]; then
    export PATH="$_np_nvm/versions/node/$_np_pick/bin:$(_np_strip_nvm)"
else
    _np_bin="$(_np_newest_outside)"
    [ -z "$_np_bin" ] || export PATH="$_np_bin:$PATH"
fi
unset _np_nvm _np_dir _np_want _np_pick _np_bin
unset -f _np_read _np_match _np_newest_outside _np_strip_nvm
