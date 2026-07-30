#!/usr/bin/env bash
#
# asdf >= 0.16 is a single binary: there is no asdf.sh to source. Wiring is
# shims-on-PATH plus completions, both guarded so an upgrade or uninstall
# degrades quietly instead of erroring at login.

_asdf_data_dir="${ASDF_DATA_DIR:-$HOME/.asdf}"
if [ -d "$_asdf_data_dir/shims" ]; then
    export PATH="$_asdf_data_dir/shims:$PATH"
fi
unset _asdf_data_dir

if [ -n "$HOMEBREW_PREFIX" ] && [ -r "$HOMEBREW_PREFIX/opt/asdf/etc/bash_completion.d/asdf" ]; then
    . "$HOMEBREW_PREFIX/opt/asdf/etc/bash_completion.d/asdf"
fi
