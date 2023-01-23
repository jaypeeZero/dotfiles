# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path changes
export PATH=$HOME/tools/confluent-5.3.1/bin:$PATH
export PATH="$PATH:/Users/wrigjame/.dotnet/tools"
export PATH="$PATH:/Users/wrigjame/tools/git-tidy"
export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:/Users/wrigjame/bin"

# Path to your oh-my-zsh installation.
export ZSH="/Users/wrigjame/.oh-my-zsh"
ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_AUTOSTART_ONCE=true
ZSH_TMUX_AUTOCONNECT=true
ZSH_THEME=powerlevel10k/powerlevel10k

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"
CASE_SENSITIVE="false"

plugins=(git kubectl tmux zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh
source ~/powerlevel10k/powerlevel10k.zsh-theme

# ALIASES
alias cat="bat"
alias csv='cd ~/code/Caesar-Vision-Next-Gen'
alias docker-burn="docker stop \$(docker ps -aq) && docker rm \$(docker ps -aq) && docker volume prune -f"
alias fnd="fzf --preview 'bat {-1} --color=always' -q"
alias fndif="rg . | fzf --print0 -e --preview 'bat {-1} --color=always' -q"
alias uuid="uuidgen"

# CUSTOM FUNCTIONS
whatport() {
    if [ -n "$1" ]
    then
        lsof -nP -i4TCP:"$1"
    else
        echo "Provide a port"
    fi
}
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

run() {
    number=$1
    shift
    for i in `seq $number`; do
        $@
    done
}

gdiff() {
    preview="git diff $@ --color=always -- {-1}"
    git diff $@ --name-only | fzf -m --ansi --preview $preview
}

# DOCKER SETTINGS
set COMPOSE_PARALLEL_LIMIT=6

export NVM_DIR="/usr/local/opt/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# vscode tmux session
codemux () {
    tmux a -t VSCode || tmux new -s VSCode
}

# replace
rpl() { ack -l "$1" --print0 | xargs -0 -n 1 sed -i '' -e "s/$1/$2/" }

# LITTLE CAESARS
# source ~/.lce_env

# COMMUNICARE
# source ~/.comcare_env

# NIPPER
# source ~/.nipper_env

# OMI
# source ~/.omi_env

# STIPPLING
# source ~/.stippling_env

# WINGSTOP
source ~/.wingstop_env

. /usr/local/opt/asdf/asdf.sh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/wrigjame/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/wrigjame/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/wrigjame/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/wrigjame/google-cloud-sdk/completion.zsh.inc'; fi

# Navigate to the current project directory
wing
