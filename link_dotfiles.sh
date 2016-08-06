#!/bin/bash
#
# Based on https://github.com/robb/.dotfiles/blob/master/install.sh

set -e

symlinks=$(find . -name "*.symlink")

for file in $symlinks; do
    basename=$(basename $file .symlink)
    target="$HOME/.$basename"

    if [ -e "$target" ] || [ -h "$target" ]; then
      rm $target
    fi

    echo "Installing $target"
    ln -s "$PWD/$file" "$target"
done

