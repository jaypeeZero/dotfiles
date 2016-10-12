#!/bin/bash
#
# Brew all the things

##################
# Things to brew #
##################

binaries=(
    bash
    carthage
    chruby
    cloc
    dockutil
    git
    git-annex
    htmldoc
    mas
    multimarkdown
    python
    reattach-to-user-namespace
    ruby-install
    tig
    tmux
    tree
    vim
)

casks=(
    appcleaner
    atom
    charles
    dropbox
    fluid
    flux
    gimp
    google-chrome
    google-drive
    xquartz
    inkscape
    keepingyouawake
    macdown
    postman
    textmate
    vlc
    wwdc
)

fonts=(
    font-meslo-lg-for-powerline
    font-source-code-pro
    font-source-sans-pro
    font-source-serif-pro
)


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
      echo "$1: Upgrading"
      brew upgrade "$@"
    else
      echo "$1: Already up-to-date"
    fi
  else
    echo "$1: Installing"
    brew install "$@"
  fi
}


#####################
# Keep Brew Updated #
#####################

echo "Brew Doctor..."
brew doctor

echo ""
echo "Brew Update..."
brew update

if [[ -z $(brew tap | grep 'caskroom/cask') ]]; then
    echo ""
    echo "Tap Casks..."
    brew tap caskroom/cask
fi

echo ""
echo "Brew Cask Update..."
brew cask update

if [[ -z $(brew tap | grep 'caskroom/fonts') ]]; then
    echo ""
    echo "Tap Caskroom Fonts..."
    brew tap caskroom/fonts
fi


########################
# Actually Brew Things #
########################

echo ""
echo "Brew Binaries..."
for app in "${binaries[@]}"; do
	brew_install_or_upgrade "${app}"
done

brew install imagemagick --with-librsvg

echo ""
echo "Brew Casks..."
for cask in "${casks[@]}"; do
	brew cask install "${cask}"
done

echo ""
echo "Brew Cask Fonts..."
for font in "${fonts[@]}"; do
	brew cask install "${font}"
done


#########
# Clean #
#########

echo ""
echo "Cleanup..."
brew cleanup
brew cask cleanup

