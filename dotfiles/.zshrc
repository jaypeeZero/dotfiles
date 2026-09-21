# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Docker.app's zsh completions are symlinked from site-functions into
# /Applications, which is group-writable by design on macOS. compaudit
# treats that as insecure and skips loading completions entirely,
# breaking compdef. Trust it rather than chmod'ing a shared system dir.
# Must be set before bash_includes below: nvm's own zsh completion script
# (sourced from there) reads this same variable to decide whether to call
# `compinit -u` or a bare, prompting `compinit`.
ZSH_DISABLE_COMPFIX=true

# Source all bash_includes files (works in both bash and zsh)
for file in $HOME/.df/bash_includes/*.bash; do
  source "$file"
done

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path changes
# Static nvm PATH entry, not a sourced nvm.sh function call: .zprofile's
# `brew shellenv` runs macOS's path_helper, which resets whatever PATH
# .zshenv built up before this file even loads, so nvm has to be re-added
# here as a plain export to survive that reset.
export PATH="$HOME/.nvm/versions/node/v22.23.2/bin:$PATH"
export PATH=$HOME/tools/confluent-5.3.1/bin:$PATH
export PATH="$PATH:$HOME/.dotnet/tools"
export PATH="$PATH:$HOME/tools/git-tidy"
export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:$HOME/bin"
export PATH="$HOME/.codeium/windsurf/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Things to define before oh-my-zsh
export FZF_BASE=/opt/homebrew/bin/fzf
export FZF_DEFAULT_OPTS="--preview 'bat {-1} --color=always'"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_TMUX_AUTOSTART=false
ZSH_TMUX_AUTOSTART_ONCE=true
ZSH_TMUX_AUTOCONNECT=true
ZSH_THEME=powerlevel10k/powerlevel10k

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"
CASE_SENSITIVE="false"

plugins=(git kubectl tmux fzf)

source $ZSH/oh-my-zsh.sh
source ~/.powerlevel10k/powerlevel10k.zsh-theme

# ZSH-SPECIFIC ALIASES (cross-shell aliases are in bash_includes/aliases.bash)
alias csv='cd ~/code/Caesar-Vision-Next-Gen'

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# DOCKER SETTINGS
set COMPOSE_PARALLEL_LIMIT=6

# PROJECT ENVIRONMENTS
# source ~/.some_project.env

# MACHINE SPECIFIC ENVIRONMENT
[[ -f "$HOME/.df/dotfiles/.zsh.env.local" ]] && source "$HOME/.df/dotfiles/.zsh.env.local"


# The next line updates PATH for the Google Cloud SDK.
#if [ -f '$HOME/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
#if [ -f '$HOME/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/google-cloud-sdk/completion.zsh.inc'; fi

# To customize prompt, run `p10k configure` or edit ~/.df/dotfiles/.p10k.zsh.
[[ ! -f ~/.df/dotfiles/.p10k.zsh ]] || source ~/.df/dotfiles/.p10k.zsh
# lean-ctx shell hook — begin
if [ -f "$HOME/.config/lean-ctx/shell-hook.zsh" ]; then
. "$HOME/.config/lean-ctx/shell-hook.zsh"
fi
# lean-ctx shell hook — end
