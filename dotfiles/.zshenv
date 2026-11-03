# Read by every zsh invocation (interactive or not, login or not) — unlike
# .zshrc, which only loads for interactive shells and is therefore invisible
# to non-interactive tool/CI shells.
export NVM_DIR="$HOME/.nvm"

# Non-interactive shells (tool shells, CI-style agents) never load nvm, so the
# first `node` on PATH is whatever Homebrew installed. Put the nvm default's
# newest matching install ahead of /opt/homebrew/bin.
if [[ -r "$NVM_DIR/alias/default" ]]; then
  _nvm_default="$(<"$NVM_DIR/alias/default")"
  _nvm_bins=("$NVM_DIR"/versions/node/v${_nvm_default#v}.*/bin(N/))
  if (( ${#_nvm_bins} )); then
    _nvm_sorted=(${(On)_nvm_bins})
    path=("$_nvm_sorted[1]" ${path:#$_nvm_sorted[1]})
    unset _nvm_sorted
  fi
  unset _nvm_default _nvm_bins
fi
