# Read by every zsh invocation (interactive or not, login or not) — unlike
# .zshrc, which only loads for interactive shells and is therefore invisible
# to non-interactive tool/CI shells.
export NVM_DIR="$HOME/.nvm"
