# Read by every zsh invocation (interactive or not, login or not) — unlike
# .zshrc, which only loads for interactive shells and is therefore invisible
# to non-interactive tool/CI shells.
export NVM_DIR="$HOME/.nvm"

# Non-interactive shells (tool shells, CI-style agents) never load nvm, so the
# first `node` on PATH is whatever Homebrew installed. node-path.sh puts the
# node a repo's .nvmrc names, else the nvm default, ahead of /opt/homebrew/bin.
# BASH_ENV hands the same script to every non-interactive bash started below
# this shell, which reads no other startup file.
_node_path="${DF:-$HOME/.df}/bash_includes/node-path.sh"
if [[ -r "$_node_path" ]]; then
  export BASH_ENV="$_node_path"
  source "$_node_path"
fi
unset _node_path
