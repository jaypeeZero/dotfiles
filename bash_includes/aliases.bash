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
alias la='ls -a'
alias ll='ls -al'
alias lla='ls -al'

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

alias vi='vim'

alias be='bundle exec'

# Modern CLI tools
alias cat="bat"
alias vim="nvim"

# Docker
alias docker-burn="docker stop \$(docker ps -aq) && docker rm \$(docker ps -aq) && docker volume prune -f"

# Search
alias fnd="fzf --preview 'bat {-1} --color=always' -q"
alias fndif="rg . | fzf --print0 -e --preview 'bat {-1} --color=always' -q"

# Utilities
alias uuid="uuidgen"

# FUNCTIONS

# Check what's running on a port
whatport() {
    if [ -n "$1" ]
    then
        lsof -nP -i4TCP:"$1"
    else
        echo "Provide a port"
    fi
}

# Run a command N times
run() {
    number=$1
    shift
    for i in `seq $number`; do
        $@
    done
}

# Interactive git diff file selector
fdif() {
    preview="git diff $@ --color=always -- {-1}"
    git diff $@ --name-only | fzf -m --ansi --preview $preview
}

# VSCode tmux session
codemux () {
    tmux a -t VSCode || tmux new -s VSCode
}

# Replace text in files
rpl() { ack -l "$1" --print0 | xargs -0 -n 1 sed -i '' -e "s/$1/$2/" }

# Show head and tail of a file
function headtail
{
  head "$@" ; tail "$@"
}
