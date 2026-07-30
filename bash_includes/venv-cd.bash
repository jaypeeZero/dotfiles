#!/usr/bin/env bash
#
# Overrides the `cd` builtin to auto-activate a project's .venv.
#
# Kept in its own file because it is invasive: it runs on EVERY directory
# change in every shell. Delete this file to remove the behaviour entirely —
# nothing else depends on it.

cd() {
    local current_dir
    current_dir=$(pwd)

    builtin cd "$@" || return

    local new_dir
    new_dir=$(pwd)

    if [ -d "$new_dir/.venv" ]; then
        # shellcheck disable=SC1091
        source "$new_dir/.venv/bin/activate"
    elif [[ "$new_dir" != "$current_dir" && "$current_dir" == */.venv* ]]; then
        # Guarded: the condition tests the path string rather than whether a
        # venv is actually active, so it fires in cases where `deactivate` was
        # never defined. Without the guard that prints "command not found" on
        # ordinary directory changes.
        command -v deactivate >/dev/null 2>&1 && deactivate
    fi
}
