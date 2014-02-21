
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWCOLORHINTS=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWSTASHSTATE=1

export PS1="${Cyan}\u${Color_Off} @ ${Green}\h ${Color_Off}:${Red}\$(__git_ps1 \" %s \$(get_sha) ${Color_Off}:\") ${BYellow}\w${Color_Off}\n> "
