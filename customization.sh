################################################################################
#
# PROFILE AND ENVIRONMENT CUSTOMIZATION
#
################################################################################

reload() {
	pushd ~
	. ~/.bash_profile
	popd
}

killdock() {
	killall Dock
}

################################################################################
#
# SHELL NAVIGATION
#
################################################################################

get_dir() {
    printf "%s" $(pwd | sed "s:$HOME:~:")
}

# Detect which `ls` flavor is in use
# From https://github.com/mathiasbynens/dotfiles/blob/master/.aliases
if ls --color > /dev/null 2>&1; then # GNU `ls`
	colorflag="--color"
	export LS_COLORS="di=34;48:ln=35;48:so=32;48:pi=33;48:ex=31;48:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:"
else # OS X `ls`
	colorflag="-G"
	export LSCOLORS=exfxcxdxbxegedabagacad
fi

alias ls='ls -Fh ${colorflag}'
alias ll='ls -al'
alias lla='ls -al'

################################################################################
#
# SHELL SAFETY
#
################################################################################

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

alias fuck='sudo $(fc -ln -1)'

################################################################################
#
# GIT
#
################################################################################

alias gs='git status -sb'
alias gd='git diff --no-ext-diff'
alias gadd='git add -A && git status -sb'

alias sourcetree='open -a SourceTree .'

################################################################################
#
# PROMPT
#
################################################################################

git_sha() {
    git rev-parse --short HEAD 2>/dev/null
}

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWCOLORHINTS=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWSTASHSTATE=1

export PS1="${Cyan}\u${Color_Off} @ ${Green}\h ${Color_Off}:${Red}\$(__git_ps1 \" %s \$(git_sha) ${Color_Off}:\") ${BYellow}\w${Color_Off}\n> "
