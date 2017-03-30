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
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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
    git clone git@github.com:kdbertel/dotfiles.git ~/.df
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

brew bundle -v --global


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
##############################################
###     INSTALL IRIDIUM TERMINAL THEME     ###
##############################################
"
# Found at https://github.com/geerlingguy/mac-dev-playbook/issues/26
osascript <<EOD
tell application "Terminal"
	local allOpenedWindows
	local initialOpenedWindows
	local windowID
	set themeName to "Iridium" (* Set the name of the theme*)
	(* Store the IDs of all the open terminal windows. *)
	set initialOpenedWindows to id of every window
	(* Open the custom theme so that it gets added to the list
	   of available terminal themes (note: this will open two
	   additional terminal windows). *)
	do shell script "open '$HOME/.df/files/" & themeName & ".terminal'"
	(* Wait a little bit to ensure that the custom theme is added. *)
	delay 1
	(* Set the custom theme as the default terminal theme. *)
	set default settings to settings set themeName
	(* Get the IDs of all the currently opened terminal windows. *)
	set allOpenedWindows to id of every window
	repeat with windowID in allOpenedWindows
		(* Close the additional windows that were opened in order
		   to add the custom theme to the list of terminal themes. *)
		if initialOpenedWindows does not contain windowID then
			close (every window whose id is windowID)
		(* Change the theme for the initial opened terminal windows
		   to remove the need to close them in order for the custom
		   theme to be applied. *)
		else
			set current settings of tabs of (every window whose id is windowID) to settings set themeName
		end if
	end repeat
end tell
EOD

echo "Iridium terminal theme installed"


echo -e "
############################
###     TMUX PLUGINS     ###
############################
"

if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ~/.tmux/plugins/tpm/bin/install_plugins
else
    ~/.tmux/plugins/tpm/bin/update_plugins all
fi
mkdir -p ~/.tmux/resurrect/


echo -e "
##############################
###     MACOS SETTINGS     ###
##############################
"

~/.df/setup_mac/macos.sh
