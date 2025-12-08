#!/usr/bin/env bash
# Shared aliases and functions between bash and zsh

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
