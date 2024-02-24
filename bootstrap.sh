#!/usr/bin/env bash

set -e

echo -e "
##################################
###     SSH KEY GENERATION     ###
##################################
"
if [ ! -f ~/.ssh/id_rsa ]; then
    eval "$(ssh-agent -s)"
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
    ssh-add ~/.ssh/id_rsa
    echo -e "Paste the following into Github's allowed public keys to connect
    ---
    "
    cat ~/.ssh/id_rsa.pub
    echo -e "
    ---
    "

    read -p "Press ENTER when done." trash
    unset trash
    echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
    " > ~/.ssh/known_hosts
else
    echo -e "SSH Key already generated"
fi

echo -e "
########################
###     HOMEBREW     ###
########################
"

if [ ! -f "$(which brew)" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # pre-2024 version -- /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo -e "Homebrew already installed"
fi


echo -e "
############################
###     INSTALL STOW     ###
############################
"

if $(brew list -1 | grep -Fqx "stow"); then
    echo "Stow already installed"
else
    brew install stow
fi


echo -e "
###################################
###     CLONE DOTFILES REPO     ###
###################################
"

if [ ! -d ~/.df ]; then
    git clone https://github.com/jamespwright/dotfiles.git ~/.df
else
    echo "Dotfiles already cloned"
fi


echo -e "
#############################
###     STOW DOTFILES     ###
#############################
"

stow --verbose --restow --dir ~/.df/ --target ~/ --ignore=\.DS_Store dotfiles


echo -e "
###########################
###     BREW BUNDLE     ###
###########################
"

brew update
brew upgrade
brew bundle -v --global
brew cleanup


echo -e "
###################################
###     INSTALL VIM PLUGINS     ###
###################################
"

if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
else
    echo "Vundle already installed"
fi

vim +PluginInstall +qall


echo -e "
######################################
###     SET BREW BASH AS SHELL     ###
######################################
"
if [[ "$SHELL" != "/usr/local/bin/bash" ]]; then
    if $(grep -Fqx "/usr/local/bin/bash" /etc/shells); then
        echo "Brew bash already included as standard shell"
    else
        echo "echo /usr/local/bin/bash >> /etc/shells"
        sudo sh -c 'echo /usr/local/bin/bash >> /etc/shells'
    fi
    chsh -s /usr/local/bin/bash
else
    echo "Brew bash already set as shell"
fi


echo -e "
############################
###     INSTALL RUBY     ###
############################
"

# ruby-install -L
# ruby-install -c --no-reinstall ruby-2.6.0
# gem install bundler --conservative


echo -e "
###########################
###     INSTALL PIP     ###
###########################
"

pip install --quiet --upgrade pip
pip3 install --quiet --upgrade pip


echo -e "
###########################
###     PIP PACKAGES    ###
###########################
"

pip install --quiet --user --upgrade -r ~/.Pipfile
pip3 install --quiet --user --upgrade -r ~/.Pipfile

echo -e "
###############################################
###     SETUP Oh-my-zsh                 #######
###############################################
"
# BASED OFF OF 
# bash <(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)
~/.df/oh-my-zsh-install.sh

echo -e "
############################
###     POWERLEVEL10K    ###
############################
"
git clone https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k


echo -e "
############################
###     TMUX PLUGINS     ###
############################
"

#if [ ! -d ~/.tmux/plugins/tpm ]; then
#    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
#    ~/.tmux/plugins/tpm/bin/install_plugins
#else
#    ~/.tmux/plugins/tpm/bin/update_plugins all
#fi
#mkdir -p ~/.tmux/resurrect/


echo -e "
##############################
###     NVM SETUP          ###
##############################"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | zsh

echo -e "
##############################
###     MACOS SETTINGS     ###
##############################
"

~/.df/macos_defaults.sh
