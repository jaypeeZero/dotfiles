#!/usr/bin/env bash

export NVM_DIR="$HOME/.nvm"

# brew-installed nvm first, then a manual ~/.nvm install. Every path guarded so
# a machine without nvm simply gets nothing.
for _nvm_root in "${HOMEBREW_PREFIX:-}/opt/nvm" "$NVM_DIR"; do
    if [ -s "$_nvm_root/nvm.sh" ]; then
        . "$_nvm_root/nvm.sh"
        [ -s "$_nvm_root/etc/bash_completion.d/nvm" ] && . "$_nvm_root/etc/bash_completion.d/nvm"
        [ -s "$_nvm_root/bash_completion" ] && . "$_nvm_root/bash_completion"
        break
    fi
done
unset _nvm_root
