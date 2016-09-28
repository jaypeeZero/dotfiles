#!/bin/bash
#
# All the ruby things

###############
# Manage gems #
###############

gem_install_or_update() {
  if gem list "$1" --installed > /dev/null; then
    echo "Updating $1..."
    gem update "$@"
  else
    echo "Installing $1..."
    gem install "$@"
  fi
}

gems=(
  bundler
)

echo -e "Installing gems..."

for gem in "${gems[@]}"; do
  gem_install_or_update "${gem}"
done

