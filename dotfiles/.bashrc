#!/bin/bash
#
# Based on https://github.com/holman/dotfiles/blob/master/zsh/zshrc.symlink
#
# Everything lives in the loader so that macOS, Linux and WSL run identical
# sourcing logic. Do not add config here — add a *.bash file to bash_includes/.

export DF="${DF:-$HOME/.df}"

. "$DF/bash_includes/loader.bash"
