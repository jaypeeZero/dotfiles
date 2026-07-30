#!/usr/bin/env bash
#
# Sourced first by loader.bash — everything downstream may resolve a binary.

export PATH="$PATH:/usr/local/sbin"

# Homebrew. The prefix differs per platform (Apple Silicon, Intel, Linux), so
# find the binary rather than assume a path, and let `shellenv` set
# HOMEBREW_PREFIX/MANPATH/INFOPATH correctly for whichever it is.
for _brew in \
    /opt/homebrew/bin/brew \
    /usr/local/bin/brew \
    /home/linuxbrew/.linuxbrew/bin/brew
do
    if [ -x "$_brew" ]; then
        eval "$("$_brew" shellenv)"
        break
    fi
done
unset _brew

if [ "$_OS" = "mac" ]; then
    export PATH="$PATH:$HOME/Library/Python/2.7/bin"
fi

export PATH="$PATH:${DF:-$HOME/.df}/bin"
