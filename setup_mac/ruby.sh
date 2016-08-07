#!/bin/bash
#
# All the ruby things

################
# Manage RBENV #
################

rbenv_install_version() {
  if [ ! $(rbenv versions | grep -q $1) ]; then
    rbenv install "$1"
  else
    echo -e "rbenv version $1 already installed"
  fi
}

rbenv_set_global() {
  if [ -f 'rbenv global' ]; then
    #rbenv global 2.2.2
    echo "rbenv global $1"
  else
    RBENV_GLOBAL=$(rbenv global)
    echo "rbenv global already set to ${RBENV_GLOBAL}"
  fi
}

echo "Installing ruby versions using rbenv..."
rbenv_install_version 2.2.0
rbenv_set_global 2.2.0

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
    rbenv rehash
  fi
}

gems=(
  bundler
  xcode-install
  xcpretty
)

echo -e "Installing gems..."

for gem in "${gems[@]}"; do
  gem_install_or_update "${gem}"
done


gem install xcode-install
