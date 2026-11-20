eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# brew shellenv just put /opt/homebrew/bin ahead of nvm's node; re-run the
# idempotent PATH fix from .zshenv so the picked node wins in login shells too.
source "$HOME/.zshenv"
