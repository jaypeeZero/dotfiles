# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source all bash_includes files (works in both bash and zsh)
for file in $HOME/.df/bash_includes/*.bash; do
  source "$file"
done

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path changes
export PATH=$HOME/tools/confluent-5.3.1/bin:$PATH
export PATH="$PATH:/Users/jw/.dotnet/tools"
export PATH="$PATH:/Users/jw/tools/git-tidy"
export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:/Users/jw/bin"

# Things to define before oh-my-zsh
export FZF_BASE=/opt/homebrew/bin/fzf
export FZF_DEFAULT_OPTS="--preview 'bat {-1} --color=always'"

# Path to your oh-my-zsh installation.
export ZSH="/Users/jw/.oh-my-zsh"
ZSH_TMUX_AUTOSTART=false
ZSH_TMUX_AUTOSTART_ONCE=true
ZSH_TMUX_AUTOCONNECT=true
ZSH_THEME=powerlevel10k/powerlevel10k

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"
CASE_SENSITIVE="false"

plugins=(git kubectl tmux fzf)

source $ZSH/oh-my-zsh.sh
source ~/powerlevel10k/powerlevel10k.zsh-theme

# ZSH-SPECIFIC ALIASES (cross-shell aliases are in bash_includes/aliases.bash)
alias csv='cd ~/code/Caesar-Vision-Next-Gen'

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# DOCKER SETTINGS
set COMPOSE_PARALLEL_LIMIT=6

export NVM_DIR="/usr/local/opt/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# PROJECT ENVIRONMENTS
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
#if [ -f '/Users/jw/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/jw/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
#if [ -f '/Users/jw/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/jw/google-cloud-sdk/completion.zsh.inc'; fi

# Navigate to the current project directory
wing

# To customize prompt, run `p10k configure` or edit ~/.df/dotfiles/.p10k.zsh.
[[ ! -f ~/.df/dotfiles/.p10k.zsh ]] || source ~/.df/dotfiles/.p10k.zsh
