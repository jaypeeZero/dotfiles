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

# Things for git
alias gs='git status -sb'
alias gd='git diff --no-ext-diff'
alias gadd='git add -A && git status -sb'
alias gcomm='git commit -m'

# SourceTree
alias sourcetree='open -a SourceTree .'
alias st='sourcetree'
alias gitk='sourcetree'
