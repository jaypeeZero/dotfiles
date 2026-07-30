#!/usr/bin/env bash

export PYENV_ROOT="$HOME/.pyenv"
[ -d "$PYENV_ROOT/bin" ] && export PATH="$PYENV_ROOT/bin:$PATH"

# Guard the eval, not just the PATH prepend: pyenv may be installed via brew
# (already on PATH) or not at all, and an unguarded `pyenv init` is a login
# error on any machine without it.
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi
