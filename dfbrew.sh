#!/bin/bash
#
# Brew all the things

# Ask for admin password upfront
sudo -v
# Run a keep-alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Check for Homebrew and install it if we don't have it
if [ ! -f "$(which brew)" ]; then
    echo "Installing Homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "Homebrew found."
fi
echo ""

echo "Brew Doctor..."
brew doctor

echo ""
echo "Brew Update..."
brew update

binaries=(
    carthage
    cloc
    git
    git-annex
    python
    rbenv
    reattach-to-user-namespace
    ruby-build
    tig
    tmux
    tree
    vim --env-std --override-system-vim
)

echo ""
echo "Brew Binaries..."
brew install "${binaries[@]}"

#echo ""
#echo "Brew Caskroom..."
#brew install caskroom/cask/brew-cask

casks=(
    flux
    font-meslo-lg-for-powerline
    inkscape
    keepingyouawake
    vlc
)

echo ""
echo "Brew Caskroom Fonts..."
brew tap caskroom/fonts

echo ""
echo "Brew Casks..."
brew cask install "${casks[@]}"

echo ""
echo "Cleanup..."
brew cleanup

if [ ! -f "$(which pip)" ]; then
    echo "Installing pip..."
    curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python2.7
else
    echo "pip already installed."
fi
echo ""

if [ ! -f "$(pip list | grep psutil)" ]; then
    echo "Installing psutil..."
    pip install psutil
else
    echo "psutil already installed."
fi

echo ""
echo "Installing powerline-status..."
pip install powerline-status

