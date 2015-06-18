#!/bin/bash

# Taken from https://github.com/phunehehe/terminal-dotfiles and modified to suit my purposes

# A better way of calling ln
link_file() {
	source="$1"
	destination="$2"
	
	dest_dir="$(dirname "$destination")"
	mkdir -p $dest_dir
	
	stamp=dotfiles
	now=$(date '+%Y-%m-%d_%H-%M-%S')
	
	[[ -h "$destination" ]] && rm "$destination"
	[[ -e "$destination" ]] && mv "$destination" "$destination.$stamp-$now"
	ln -sv "$source" "$destination"
}

bin_dir="$(cd "$(dirname "$0")" && pwd)"

dotfiles="
inputrc
gitconfig
gitignore
vimrc
"

for source in $dotfiles
do
	destination="$HOME/.${source}"
	link_file "$bin_dir/.$source" "$destination"
done

shellfiles="
git-prompt
git-completion
bash_profile
colors
customization
"

[[ -e $HOME/.environment ]] && rm $HOME/.environment
for source in $shellfiles
do
	destination="$HOME/.${source}"
	if [ $source != 'bash_profile' ]; then
		echo ". ${destination}" >> $HOME/.environment
	fi
	link_file "$bin_dir/$source.sh" "$destination"
done

. ~/.bash_profile