get_dir() {
    printf "%s" $(pwd | sed "s:$HOME:~:")
}

reload() {
	cd ~
	. ~/.bash_profile
	cd -
}