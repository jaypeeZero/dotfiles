# shellcheck shell=bash
# Behavior tests for bash_includes/node-path.sh. Run from the repo root:
#   bash tests/node-path.test.sh
set -u

here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../bash_includes/node-path.sh"

fix="$(mktemp -d)"
trap 'rm -rf "$fix"' EXIT

home="$fix/home"
mkdir -p "$home/.nvm/versions/node/v22.1.0/bin"
mkdir -p "$home/.nvm/versions/node/v24.9.0/bin"
mkdir -p "$home/.nvm/versions/node/v24.10.0/bin"
mkdir -p "$home/.nvm/alias"
printf '22\n' > "$home/.nvm/alias/default"

repo24="$fix/repo24"
mkdir -p "$repo24/sub"
printf '24\n' > "$repo24/.nvmrc"

empty="$fix/empty"
mkdir -p "$empty"

repo20="$fix/repo20"
mkdir -p "$repo20"
printf '20\n' > "$repo20/.nvmrc"

repo249="$fix/repo249"
mkdir -p "$repo249"
printf 'v24.9' > "$repo249/.nvmrc"

repocrlf="$fix/repocrlf"
mkdir -p "$repocrlf"
printf '24\r\n' > "$repocrlf/.nvmrc"

fails=0
check() {
    if [ "$3" = "$2" ]; then
        printf 'ok %s\n' "$1"
    else
        printf 'FAIL %s\n  expected: %s\n  actual:   %s\n' "$1" "$2" "$3"
        fails=$((fails + 1))
    fi
}

check_contains() {
    case "$3" in
        *"$2"*) printf 'ok %s\n' "$1" ;;
        *) printf 'FAIL %s\n  expected to contain: %s\n  actual: %s\n' "$1" "$2" "$3"
           fails=$((fails + 1)) ;;
    esac
}

# Single quotes: ${PATH%%:*} must expand inside the child shell, not here.
# shellcheck disable=SC2016
print_first='printf %s "${PATH%%:*}"'

# run_bash <cwd> [bash flags...] -> first PATH entry on stdout, stderr untouched
# Uses $run_home as HOME, which defaults to the fixture with a default alias.
run_home="$home"
run_bash() {
    local cwd="$1"
    shift
    (cd "$cwd" && env -i HOME="$run_home" NVM_DIR="$run_home/.nvm" PATH=/usr/bin:/bin \
        BASH_ENV="$script" "$BASH" "$@" -c "$print_first")
}

v24bin="$home/.nvm/versions/node/v24.10.0/bin"

check "subdir of repo with .nvmrc=24 picks newest 24.x" \
    "$v24bin" "$(run_bash "$repo24/sub")"

check "no .nvmrc falls back to nvm default alias" \
    "$home/.nvm/versions/node/v22.1.0/bin" "$(run_bash "$empty")"

out="$(run_bash "$repo20" 2>"$fix/err20")"
status=$?
check "uninstalled .nvmrc version falls through to nvm default alias" \
    "$home/.nvm/versions/node/v22.1.0/bin" "$out"
check_contains "uninstalled .nvmrc version warns on stderr" \
    "no nvm install matches '20'" "$(cat "$fix/err20")"
check "uninstalled .nvmrc version still exits 0" "0" "$status"

out="$(run_bash "$repo249" -euo pipefail)"
status=$?
check ".nvmrc without trailing newline survives bash -euo pipefail" \
    "$home/.nvm/versions/node/v24.9.0/bin" "$out"
check "bash -euo pipefail child exits 0" "0" "$status"

out="$(cd "$repo24" && env -i HOME="$home" PATH=/usr/bin:/bin \
    BASH_ENV="$script" "$BASH" -u -c "$print_first")"
check "NVM_DIR unset falls back to HOME/.nvm under bash -u" "$v24bin" "$out"

check ".nvmrc with CRLF line ending" "$v24bin" "$(run_bash "$repocrlf")"

nodefault="$fix/nodefault"
mkdir -p "$nodefault/.nvm/versions/node/v22.1.0/bin" "$nodefault/.nvm/versions/node/v24.10.0/bin"
run_home="$nodefault"
check "no .nvmrc and no default alias picks newest nvm install" \
    "$nodefault/.nvm/versions/node/v24.10.0/bin" "$(run_bash "$empty")"
check "uninstalled .nvmrc and no default alias picks newest nvm install" \
    "$nodefault/.nvm/versions/node/v24.10.0/bin" "$(run_bash "$repo20" 2>/dev/null)"

namedefault="$fix/namedefault"
mkdir -p "$namedefault/.nvm/versions/node/v22.1.0/bin" "$namedefault/.nvm/versions/node/v24.10.0/bin"
mkdir -p "$namedefault/.nvm/alias"
printf 'lts/*\n' > "$namedefault/.nvm/alias/default"
run_home="$namedefault"
check "default alias naming no install picks newest nvm install" \
    "$namedefault/.nvm/versions/node/v24.10.0/bin" "$(run_bash "$empty")"
run_home="$home"

# fake_node <dir> <version> -> <dir>/node, an executable that prints <version>
fake_node() {
    mkdir -p "$1"
    printf '#!/bin/sh\necho %s\n' "$2" > "$1/node"
    chmod +x "$1/node"
}
fake_node "$fix/old-node" v20.0.0
fake_node "$fix/new-node" v26.1.0
nonvm="$fix/nonvm"
mkdir -p "$nonvm"
two_nodes="$fix/old-node:$fix/new-node:/usr/bin:/bin"

out="$(cd "$empty" && env -i HOME="$nonvm" NVM_DIR="$nonvm/.nvm" PATH="$two_nodes" \
    BASH_ENV="$script" "$BASH" -euo pipefail -c "$print_first")"
check "without nvm installs, the newest node on PATH goes first" "$fix/new-node" "$out"

out="$(cd "$empty" && env -i HOME="$nonvm" NVM_DIR="$nonvm/.nvm" \
    PATH="$fix/new-node:$fix/old-node:/usr/bin:/bin" \
    BASH_ENV="$script" "$BASH" -c 'printf %s "$PATH"')"
check "without nvm installs, PATH is untouched when the newest node is already first" \
    "$fix/new-node:$fix/old-node:/usr/bin:/bin" "$out"

out="$(cd "$empty" && env -i HOME="$home" NVM_DIR="$home/.nvm" PATH="$two_nodes" \
    BASH_ENV="$script" "$BASH" -c "$print_first")"
check "with nvm installs, a newer node outside nvm does not win" \
    "$home/.nvm/versions/node/v22.1.0/bin" "$out"

if command -v zsh >/dev/null 2>&1; then
    out="$(cd "$repo24" && env -i HOME="$home" NVM_DIR="$home/.nvm" PATH=/usr/bin:/bin \
        zsh -f -c "alias ls='ls -F'; source '$script'; print -r -- \"\$path[1]\"")"
    check "zsh with ls aliased still picks .nvmrc node" "$v24bin" "$out"
else
    printf 'skip zsh with ls aliased (zsh not installed)\n'
fi

out="$(cd "$repo24" && env -i HOME="$home" NVM_DIR="$home/.nvm" PATH=/usr/bin:/bin \
    "$BASH" -c "source '$script'; source '$script'; printf %s \"\$PATH\"")"
count="$(printf %s "$out" | tr ':' '\n' | rg -c 'v24\.10\.0/bin' || true)"
check "sourcing twice puts the bin dir on PATH once" "1" "$count"

out="$(cd "$repo24" && env -i HOME="$home" NVM_DIR="$home/.nvm" PATH=/usr/bin:/bin \
    "$BASH" -c "source '$script'; cd '$empty'; source '$script'; printf %s \"\$PATH\"")"
check "re-sourcing in another directory replaces the earlier nvm pick" \
    "$home/.nvm/versions/node/v22.1.0/bin:/usr/bin:/bin" "$out"

if [ "$fails" -gt 0 ]; then
    printf '%s test(s) failed\n' "$fails"
    exit 1
fi
