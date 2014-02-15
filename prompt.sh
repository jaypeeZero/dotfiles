. git-prompt.sh

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWCOLORHINTS=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWSTASHSTATE=1

export PS1='\[\033[36m\]\u\[\033[m\] @ \[\033[32m\]\h \[\033[33;0m\]:\[\033[0;31m\]$(__git_ps1 " %s $(get_sha) \[\033[33;0m\]:") \[\033[33;1m\]\w\[\033[m\]\n> '
