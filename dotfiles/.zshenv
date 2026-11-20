# Read by every zsh invocation (interactive or not, login or not) — unlike
# .zshrc, which only loads for interactive shells and is therefore invisible
# to non-interactive tool/CI shells.
export NVM_DIR="$HOME/.nvm"

# Machine-specific exports, gitignored. Here rather than in .zshrc so tool
# shells get them too.
_df_local_env="${DF:-$HOME/.df}/dotfiles/.zsh.env.local"
if [[ -r "$_df_local_env" ]]; then
  source "$_df_local_env"
fi
unset _df_local_env

# Non-interactive shells (tool shells, CI-style agents) never load nvm, so the
# first `node` on PATH is whatever Homebrew installed. node-path.sh puts the
# node it picks (nearest .nvmrc, nvm default, newest install) ahead of it.
# BASH_ENV hands the same script to every non-interactive bash started below
# this shell, which reads no other startup file.
_df_node_path="${DF:-$HOME/.df}/bash_includes/node-path.sh"
if [[ -r "$_df_node_path" ]]; then
  export BASH_ENV="$_df_node_path"
  source "$_df_node_path"

  # Re-pick on every cd, so a directory's .nvmrc applies without a new shell.
  _df_repick_node() { source "$_df_node_path" }
  autoload -Uz add-zsh-hook
  add-zsh-hook chpwd _df_repick_node
fi
