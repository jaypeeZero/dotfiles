#!/bin/bash
#
# Brew all the things

# Ask for admin password upfront
sudo -v

# Run a keep-alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

#####################
# Utility Functions #
#####################
brew_expand_alias() {
  brew info "$1" 2>/dev/null | head -1 | awk '{gsub(/:/, ""); print $1}'
}

brew_cask_expand_alias() {
  brew cask info "$1" 2>/dev/null | head -1 | awk '{gsub(/:/, ""); print $1}'
}

brew_is_installed() {
  local name="$(brew_expand_alias $1)"

  brew list -1 | grep -Fqx "$1"
}

brew_is_upgradable() {
  local name="$(brew_expand_alias $1)"

  ! brew outdated --quiet "$1" >/dev/null
}

brew_install_or_upgrade() {
  if brew_is_installed "$1"; then
    if brew_is_upgradable "$1"; then
      echo "Upgrading $1..."
      brew upgrade "$@"
    else
      echo "Already using the latest version of $1. Skipping..."
    fi
  else
    echo "Installing $1..."
    brew install "$@"
  fi
}
######################
# Actual Brew Things #
######################

# Check for Homebrew and install it if we don't have it
if [ ! -f "$(which brew)" ]; then
    echo "Installing Homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	chown /usr/local `whoami`
else
    echo "Homebrew found."
fi
echo ""

echo "Brew Doctor..."
brew doctor

echo ""
echo "Brew Update..."
brew update

casks=(
    appcleaner
    charles
    fluid
    flux
	google-chrome
    keepingyouawake
    postman
    vlc
	wwdc
)

echo ""
echo "Brew Casks..."
for cask in "${casks[@]}"; do
	brew cask install "${cask}"
done

echo ""
echo "Tap Caskroom Fonts..."
brew tap caskroom/fonts

fonts=(
    font-meslo-lg-for-powerline
)

echo ""
echo "Brew Cask Fonts..."
for font in "${fonts[@]}"; do
	brew cask install "${font}"
done

echo ""
echo "Cleanup..."
brew cleanup
