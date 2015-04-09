get_dir() {
    printf "%s" $(pwd | sed "s:$HOME:~:")
}

reload() {
	cd ~
	. ~/.bash_profile
	cd -
}

cleandd() {
	rm -rf ~/Library/Developer/Xcode/DerivedData
	echo "Removed all derived data."
}

alias cleardd=cleandd