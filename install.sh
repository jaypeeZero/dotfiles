#!/bin/bash

# Taken from https://github.com/phunehehe/terminal-dotfiles

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
aliases
bash_profile
environment
functions
git-prompt
gitignore
prompt
vimrc
"

for source in $dotfiles
do
	destination="$HOME/.${source}"
	link_file "$bin_dir/$source.sh" "$destination"
done

. ~/.bash_profile