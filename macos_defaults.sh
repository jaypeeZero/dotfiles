#!/bin/bash

CHK="\033[0;32m \xE2\x9c\x94 \033[0m"

echo -e "Configuring macOS..."

#echo -e "
######################
###     Hardware   ###
######################
#"

echo -e "Hardware: Enable AptX Bluetooth codec $CHK"
sudo defaults write bluetoothaudiod "Enable AptX codec" -bool true

echo -e "Hardware: Disable AAC Bluetooth codec $CHK"
sudo defaults write bluetoothaudiod "Enable AAC codec" -bool false

#echo -e "
######################
###     Finder     ###
######################
#"

echo -e "Finder: show status bar $CHK"
defaults write com.apple.finder ShowStatusBar -bool true

echo -e "Finder: show path bar $CHK"
defaults write com.apple.finder ShowPathbar -bool true

echo -e "Finder: show the ~/Library folder $CHK"
chflags nohidden ~/Library

echo -e "Finder: show hidden files $CHK"
defaults write com.apple.finder AppleShowAllFiles -bool false

echo -e "Finder: show all filename extensions $CHK"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo -e "Finder: avoid creating .DS_Store files on network volumes $CHK"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo -e "Finder: expand save panel by default $CHK"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

echo -e "Finder: enable AirDrop over ethernet $CHK"
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

echo -e "Finder: make new windows start at \$HOME $CHK"
defaults write com.apple.finder NewWindowTarget -string 'PfHm'
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

echo -e "Finder: don't show hard drives on desktop $CHK"
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

#echo -e "
##########################################################
###     Dock, Mission Control, Spaces, Hot Corners     ###
##########################################################
#"

echo -e "Dock: set dock tilesize $CHK"
defaults write com.apple.dock tilesize -int 64

echo -e "Dock: put on bottom $CHK"
defaults write com.apple.dock orientation bottom

echo -e "Dock: automatically hide $CHK"
defaults write com.apple.dock autohide -bool true

echo -e "Dock: minimize to application $CHK"
defaults write com.apple.dock minimize-to-application -bool true

echo -e "Dock: minimize by scaling $CHK"
defaults write com.apple.dock mineffect scale

echo -e "Dock: disable magnification $CHK"
defaults write com.apple.dock magnification -int 0

echo -e "Dock: disable indicators for open applications $CHK"
defaults write com.apple.dock show-process-indicators -bool false

echo -e "Dock: hide recents $CHK"
defaults write com.apple.dock show-recents -bool false

echo -e "Dock: don't bounce icons"
defaults write com.apple.dock no-bouncing -bool FALSE;

echo -e "Mission Control: do not group by app $CHK"
defaults write com.apple.dock expose-group-by-app -bool false

echo -e "Spaces: Don’t automatically rearrange Spaces based on most recent use $CHK"
defaults write com.apple.dock mru-spaces -bool false

echo -e "Hot Corners: set bottom-right to start screen saver $CHK"
defaults write com.apple.dock wvous-br-corner -int 5
defaults write com.apple.dock wvous-br-modifier -int 0

echo -e "Screensaver: Set timeout value to five minutes $CHK"
defaults -currentHost write com.apple.screensaver idleTime 300

#echo -e "
###########################
###     Screenshots     ###
###########################
#"

echo -e "Screenshots: disable shadow $CHK"
defaults write com.apple.screencapture disable-shadow -bool true


#echo -e "
########################
###     Terminal     ###
########################
#"

echo -e "Terminal: disable line marks $CHK"
defaults write com.apple.terminal ShowLineMarks -bool false

echo -e "Terminal: use Obsidian $CHK"
defaults write com.apple.Terminal "Default Window Settings" -string "Obsidian"
defaults write com.apple.Terminal "Startup Window Settings" -string "Obsidian"


#echo -e "
########################
###     Keyboard     ###
########################
#"

echo -e "Keyboard: set the fastest key repeat rate $CHK"
defaults write NSGlobalDomain KeyRepeat -int 2

echo -e "Keyboard: disable press-and-hold for keys in favor of key repeat $CHK"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

echo -e "Keyboard: speed up initial key repeat $CHK"
defaults write NSGlobalDomain InitialKeyRepeat -int 25

echo -e "Keyboard: disable autocorrect $CHK"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false



#echo -e "
#############################
###     Miscellaneous     ###
#############################
#"

echo -e "Devices: stop Photos from opening every time a new device is plugged in $CHK"
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true


#echo -e "
###############################
###     BetterTouchTool     ###
###############################
#"

# From https://www.reddit.com/r/BetterTouchTool/comments/3rdaal/commandline_importexport/
echo -e "BetterTouchTool: copy settings $CHK"
cp ~/.df/files/BetterTouchTool.export ~/Library/Application\ Support/BetterTouchTool/bttdata2


#echo -e "
####################
###     Flux     ###
####################
#"

echo -e "Flux: set wake time to 7am $CHK"
defaults write com.herf.Flux wakeTime 420

echo -e "Flux: sleep late on weekends $CHK"
defaults write com.herf.Flux sleepLate 1


#echo -e "
#####################
###     Xcode     ###
#####################
#"

echo -e "Xcode: continue building after errors $CHK"
defaults write com.apple.dt.Xcode IDEBuildingContinueBuildingAfterErrors -bool true

echo -e "Xcode: set default color scheme to Dusk $CHK"
defaults write com.apple.dt.Xcode XCFontAndColorCurrentTheme -string Dusk.xccolortheme

echo -e "Xcode: show line numbers $CHK"
defaults write com.apple.dt.Xcode DVTTextShowLineNumbers -bool true


#echo -e "
#######################
###     MacDown     ###
#######################
#"

echo -e "MacDown: ensure newlines at the end of files $CHK"
defaults write com.uranusjr.macdown editorEnsuresNewlineAtEndOfFile -bool true

echo -e "MacDown: turn on automatic updates $CHK"
defaults write com.uranusjr.macdown SUEnableAutomaticChecks -bool true

echo -e "macOS configuration complete. Restart computer to see any changes not already visible."
