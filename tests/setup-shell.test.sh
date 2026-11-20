# shellcheck shell=bash
# Behavior tests for the `shell` section of setup.sh on macOS. Run from the
# repo root:
#   bash tests/setup-shell.test.sh
set -u

here="$(cd "$(dirname "$0")" && pwd)"
setup="$here/../setup.sh"

[ "$(uname -s)" = Darwin ] || { printf 'skip all (stow path is macOS only)\n'; exit 0; }
command -v stow >/dev/null 2>&1 || { printf 'skip all (stow not installed)\n'; exit 0; }

fix="$(mktemp -d)"
trap 'rm -rf "$fix"' EXIT

fails=0
check() {
    if [ "$3" = "$2" ]; then
        printf 'ok %s\n' "$1"
    else
        printf 'FAIL %s\n  expected: %s\n  actual:   %s\n' "$1" "$2" "$3"
        fails=$((fails + 1))
    fi
}

# new_machine <name> -> a DF checkout and a HOME under $fix/<name>, with a
# real ~/.zshrc and an absolute ~/.zshenv symlink, the two shapes stow refuses
new_machine() {
    local root="$fix/$1"
    mkdir -p "$root/df/dotfiles/.config/app" "$root/home"
    printf 'repo zshrc\n' > "$root/df/dotfiles/.zshrc"
    printf 'repo zshenv\n' > "$root/df/dotfiles/.zshenv"
    printf 'repo app\n' > "$root/df/dotfiles/.config/app/conf"
    printf 'hand-edited zshrc\n' > "$root/home/.zshrc"
    ln -s "$root/df/dotfiles/.zshenv" "$root/home/.zshenv"
}

# run_shell <name> -> exit status of `setup.sh --headless shell` on that machine
run_shell() {
    env DF="$fix/$1/df" HOME="$fix/$1/home" bash "$setup" --headless shell >"$fix/$1.log" 2>&1
}

new_machine ok
run_shell ok
check "stows over a real file and an absolute link, exit 0" "0" "$?"
check "the real ~/.zshrc is kept as ~/.zshrc.pre-stow" \
    "hand-edited zshrc" "$(cat "$fix/ok/home/.zshrc.pre-stow")"
check "~/.zshrc now reads the repo file" "repo zshrc" "$(cat "$fix/ok/home/.zshrc")"
check "~/.zshrc is a relative stow link" "../df/dotfiles/.zshrc" "$(readlink "$fix/ok/home/.zshrc")"
check "~/.zshenv is a relative stow link" "../df/dotfiles/.zshenv" "$(readlink "$fix/ok/home/.zshenv")"
check "~/.zshenv gets no backup, it already pointed at the repo" "no" \
    "$([ -e "$fix/ok/home/.zshenv.pre-stow" ] && echo yes || echo no)"

before="$(ls -A "$fix/ok/home")"
run_shell ok
check "second run exits 0" "0" "$?"
check "second run changes nothing in HOME" "$before" "$(ls -A "$fix/ok/home")"

new_machine taken
printf 'older backup\n' > "$fix/taken/home/.zshrc.pre-stow"
run_shell taken
check "an existing .pre-stow backup fails the section" "1" "$?"
check "the older backup is not overwritten" "older backup" "$(cat "$fix/taken/home/.zshrc.pre-stow")"
check "~/.zshrc is left as it was" "hand-edited zshrc" "$(cat "$fix/taken/home/.zshrc")"
check "~/.zshenv is left as it was" "$fix/taken/df/dotfiles/.zshenv" "$(readlink "$fix/taken/home/.zshenv")"

# A real file where the repo has a directory: stow refuses that one, after
# the section has already moved ~/.zshrc and removed ~/.zshenv.
new_machine stowfail
mkdir -p "$fix/stowfail/home/.config"
printf 'not a dir\n' > "$fix/stowfail/home/.config/app"
run_shell stowfail
check "a stow conflict fails the section" "1" "$?"
check "the section moved ~/.zshrc before stow failed" "yes" \
    "$(rg -q 'moved .*/\.zshrc to .*\.zshrc\.pre-stow' "$fix/stowfail.log" && echo yes || echo no)"
check "~/.zshrc is put back" "hand-edited zshrc" "$(cat "$fix/stowfail/home/.zshrc")"
check "~/.zshrc.pre-stow is gone" "no" "$([ -e "$fix/stowfail/home/.zshrc.pre-stow" ] && echo yes || echo no)"
check "~/.zshenv absolute link is put back" "$fix/stowfail/df/dotfiles/.zshenv" "$(readlink "$fix/stowfail/home/.zshenv")"

if [ "$fails" -gt 0 ]; then
    printf '%s test(s) failed\n' "$fails"
    exit 1
fi
