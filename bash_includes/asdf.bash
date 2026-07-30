#!/usr/bin/env bash
#
# asdf >= 0.16 is a single binary: there is no asdf.sh to source. Wiring is
# shims-on-PATH plus completions, both guarded so an upgrade or uninstall
# degrades quietly instead of erroring at login.
#
# shellcheck disable=SC1090  # completion path is resolved at runtime

_asdf_data_dir="${ASDF_DATA_DIR:-$HOME/.asdf}"
if [ -d "$_asdf_data_dir/shims" ]; then
    export PATH="$_asdf_data_dir/shims:$PATH"
fi
unset _asdf_data_dir

_asdf_completion="${HOMEBREW_PREFIX:-}/opt/asdf/etc/bash_completion.d/asdf"
[ -r "$_asdf_completion" ] && . "$_asdf_completion"
unset _asdf_completion
