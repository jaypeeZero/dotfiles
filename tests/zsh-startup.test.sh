# shellcheck shell=bash
# Behavior tests for dotfiles/.zshenv. Run from the repo root:
#   bash tests/zsh-startup.test.sh
set -u

here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$here/.." && pwd)"
zshenv="$repo/dotfiles/.zshenv"

command -v zsh >/dev/null 2>&1 || { printf 'skip all (zsh not installed)\n'; exit 0; }

fix="$(mktemp -d)"
trap 'rm -rf "$fix"' EXIT

home="$fix/home"
mkdir -p "$home/.nvm/versions/node/v22.1.0/bin" "$home/.nvm/versions/node/v24.10.0/bin"
mkdir -p "$home/.nvm/alias"
printf '22\n' > "$home/.nvm/alias/default"

# A DF checkout holding the real bash_includes plus a local env file.
df="$fix/df"
mkdir -p "$df/dotfiles"
ln -s "$repo/bash_includes" "$df/bash_includes"
printf 'export DF_LOCAL_PROBE=from-local\n' > "$df/dotfiles/.zsh.env.local"

repo24="$fix/repo24"
mkdir -p "$repo24"
printf '24\n' > "$repo24/.nvmrc"
empty="$fix/empty"
mkdir -p "$empty"

fails=0
check() {
    if [ "$3" = "$2" ]; then
        printf 'ok %s\n' "$1"
    else
        printf 'FAIL %s\n  expected: %s\n  actual:   %s\n' "$1" "$2" "$3"
        fails=$((fails + 1))
    fi
}

# run_zsh <cwd> <zsh code> -> output of <code> run after sourcing .zshenv
run_zsh() {
    (cd "$1" && env -i HOME="$home" DF="$df" PATH=/usr/bin:/bin \
        zsh -f -c "source '$zshenv'; $2")
}

check "cd into a directory with .nvmrc switches node" \
    "$home/.nvm/versions/node/v24.10.0/bin" \
    "$(run_zsh "$empty" "cd '$repo24'; print -r -- \$path[1]")"

check "cd back out returns to the nvm default" \
    "$home/.nvm/versions/node/v22.1.0/bin" \
    "$(run_zsh "$repo24" "cd '$empty'; print -r -- \$path[1]")"

check "non-interactive zsh gets .zsh.env.local" \
    "from-local" \
    "$(run_zsh "$empty" "print -r -- \$DF_LOCAL_PROBE")"

if [ "$fails" -gt 0 ]; then
    printf '%s test(s) failed\n' "$fails"
    exit 1
fi
