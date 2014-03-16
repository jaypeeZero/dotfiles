# Detect which `ls` flavor is in use
# From https://github.com/mathiasbynens/dotfiles/blob/master/.aliases
if ls --color > /dev/null 2>&1; then # GNU `ls`
	colorflag="--color"
else # OS X `ls`
	colorflag="-G"
fi

alias ls='ls -Fh ${colorflag}'
alias ll='ls -al'
alias lla='ls -al'

# Things for git
alias gs='git status -sb'
alias gd='git diff --no-ext-diff'

# SourceTree
alias sourcetree='open -a SourceTree .'
alias st='sourcetree'
alias tree='sourcetree'
alias gitk='sourcetree'
