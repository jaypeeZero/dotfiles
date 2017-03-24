#!/usr/bin/env bash

set -e

echo -e "
##################################
###     SSH KEY GENERATION     ###
##################################
"

# eval "$(ssh-agent -s)"
# ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
# ssh-add ~/.ssh/id_rsa
# echo -e "Paste the following into Github's allowed public keys to connect
# ---
# "
# cat ~/.ssh/id_rsa.pub
# echo -e "
# ---
# "

# read -p "Press ENTER when done." trash
# unset trash
# echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
# " > ~/.ssh/known_hosts


echo -e "
########################
###     HOMEBREW     ###
########################
"

# /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"


echo -e "
###################################
###     CLONE DOTFILES REPO     ###
###################################
"

# git clone git@github.com:kdbertel/dotfiles.git ~/.df


