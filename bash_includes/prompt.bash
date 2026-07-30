#!/usr/bin/env bash
#
# Sourced after colors.bash by loader.bash — PS1 is built from $I* colours.
#
# shellcheck disable=SC2034  # GIT_PS1_* are read by __git_ps1, not by us
# shellcheck disable=SC2154  # $I*/$Color_Off come from colors.bash
# shellcheck disable=SC1090  # git-prompt.sh path is resolved at runtime

git_sha() {
    git rev-parse --short HEAD 2>/dev/null
}

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWCOLORHINTS=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUPSTREAM="verbose"

# __git_ps1 ships with git's contrib, in a different place on every platform
# and not always installed at all.
for _gp in \
    "$HOMEBREW_PREFIX/etc/bash_completion.d/git-prompt.sh" \
    /usr/share/git-core/contrib/completion/git-prompt.sh \
    /usr/share/bash-completion/completions/git-prompt.sh \
    /etc/bash_completion.d/git-prompt.sh
do
    if [ -r "$_gp" ]; then
        . "$_gp"
        break
    fi
done
unset _gp

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    hostPart="${Underline}${IPurple}\h${Color_Off}"
else
    hostPart="${IPurple}\h${Color_Off}"
fi

# Fall back to a git-less prompt rather than calling an undefined function on
# every render.
if type -t __git_ps1 >/dev/null 2>&1; then
    gitPart="${IRed}\$(__git_ps1 \" \$(git_sha) %s ${Color_Off}:\")"
else
    gitPart=""
fi

export PS1="${IBlack}\A${Color_Off} ${IBlue}\u${Color_Off} @ ${hostPart} :${gitPart} ${IYellow}\w${Color_Off}\n> "

unset hostPart gitPart
