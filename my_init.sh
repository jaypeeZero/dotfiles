#!/bin/bash

flatpak install -y flathub com.discordapp.Discord
flatpak install -y flathub com.slack.Slack
flatpak install -y flathub io.github.zen_browser.zen
flatpak install -y flathub com.rafaelmardojai.Blanket
flatpak install -y flathub com.bitwarden.desktop
flatpak install -y flathub io.dbeaver.DBeaverCommunity
flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux
flatpak install -y flathub io.freetubeapp.FreeTube
flatpak install -y flathub de.haeckerfelix.Shortwave
flatpak install -y flathub io.github.mhogomchungu.media-downloader
flatpak install -y flathub com.valvesoftware.Steam
flatpak install -y flathub io.mpv.Mpv
flatpak install -y flathub net.lutris.Lutris
# Sunshine
#flatpak install -y flathub dev.lizardbyte.app.Sunshine
#flatpak run --command=additional-install.sh dev.lizardbyte.app.Sunshine
#sudo -i PULSE_SERVER=unix:/run/user/$(id -u $whoami)/pulse/native flatpak run dev.lizardbyte.app.Sunshine

echo "All requested Flatpak apps have been installed!"

echo "Installing from Brewfile"

brew bundle install

#sudo usermod -aG docker jw

# Create policy file
#echo '
#module docker_access 1.0;

#require {
#    type container_runtime_t;
#    type container_var_run_t;
#    class sock_file write;
#    class unix_stream_socket connectto;
#}

#============= container_runtime_t ==============
#allow container_runtime_t container_var_run_t:sock_file write;
#allow container_runtime_t self:unix_stream_socket connectto;
#' > docker_access.te

# Compile and install policy
#checkmodule -M -m -o docker_access.mod docker_access.te
#semodule_package -o docker_access.pp -m docker_access.mod
#sudo semodule -i docker_access.pp

# Cleanup
#rm docker_access.te docker_access.mod docker_access.pp

# AWS CLI install
#curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#unzip awscliv2.zip
#sudo ./aws/install
