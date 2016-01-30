#!/bin/bash
#
# This file is only executed for login shells. That means it gets executed when logging in over SSH or logging into KDE, but not when a new OS X terminal window is opened

# All of my settings are in bashrc, so just use that

if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

#export PATH=/opt/local/bin:/opt/local/sbin:/usr/local/sbin:$PATH

#[[ -s "$HOME/.local.bash_profile" ]] && source "$HOME/.local.bash_profile"

#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
