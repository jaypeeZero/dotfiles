#!/usr/bin/env bash
#
# shellcheck disable=SC2154  # $file/$DATE_FOLDER live inside alias bodies

# Detect which `ls` flavor is in use
# From https://github.com/mathiasbynens/dotfiles/blob/master/.aliases
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
    export LS_COLORS="di=34;48:ln=35;48:so=32;48:pi=33;48:ex=31;48:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:"
else # BSD `ls`
    colorflag="-G"
    export LSCOLORS=exfxcxdxbxegedabagacad
fi

alias ls='ls -Fh ${colorflag}'
alias la='ls -a'
alias ll='ls -al'
alias lla='ls -al'

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Modern CLI tools
alias vi='vim'
alias vim="nvim"
alias cat="bat"

alias be='bundle exec'

# Docker
alias docker-burn="docker stop \$(docker ps -aq) && docker rm \$(docker ps -aq) && docker volume prune -f"

# Search
alias fnd="fzf --preview 'bat {-1} --color=always' -q"
alias fndif="rg . | fzf --print0 -e --preview 'bat {-1} --color=always' -q"

# Utilities
alias uuid="uuidgen"
alias mux="tmuxinator"

# git
alias lzg="lazygit"

# aws
alias lclstk="aws --profile localstack "

# Copy stdin to the system clipboard
if [ "$_OS" = "mac" ]; then
    alias copy="pbcopy"
else
    alias copy="xclip -selection clipboard"
fi

if [ "$_OS" != "mac" ]; then
    # Flatpak / toolbox — Fedora Silverblue only
    # Scripts for mpv -> ~/.var/app/io.mpv.Mpv/config/mpv/scripts
    alias mpv="flatpak run io.mpv.Mpv"
    alias tb="toolbox"
    alias tbc="toolbox create"
    alias tbe="toolbox enter"

    # gio is GNOME/GVfs; MTP mount paths are Linux-specific
    alias gopro-sync="DATE_FOLDER=\$(date +%Y-%m-%d) && mkdir -p \$HOME/Videos/gopro/\$DATE_FOLDER && gio list \"mtp://GoPro_HERO8_BLACK_C3331324795546/GoPro MTP Client Disk Volume/DCIM/100GOPRO/\" | while read file; do echo \"Copying: \$file\"; if ! gio copy \"mtp://GoPro_HERO8_BLACK_C3331324795546/GoPro MTP Client Disk Volume/DCIM/100GOPRO/\$file\" \$HOME/Videos/gopro/\$DATE_FOLDER/ --progress; then echo \"Failed to copy \$file, retrying...\"; sleep 2; gio copy \"mtp://GoPro_HERO8_BLACK_C3331324795546/GoPro MTP Client Disk Volume/DCIM/100GOPRO/\$file\" \$HOME/Videos/gopro/\$DATE_FOLDER/ --progress || echo \"Failed again: \$file\"; fi; done"
    alias peoplofi-backup="curl -X MKCOL --user jamesw 'https://ourstuff.online/remote.php/dav/files/jamesw/Peoplofi' 2>/dev/null || true && for file in \$HOME/Videos/gopro/*/*.MP4; do [ -f \"\$file\" ] && echo \"Uploading: \$(basename \"\$file\")\" && curl -T \"\$file\" --user jamesw \"https://ourstuff.online/remote.php/dav/files/jamesw/Peoplofi/\$(basename \"\$file\")\" && rm \"\$file\"; done && echo 'MP4 files moved to Peoplofi backup'"
fi
