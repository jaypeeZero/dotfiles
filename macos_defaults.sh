#!/bin/bash

CHK="\033[0;32m \xE2\x9c\x94 \033[0m"

echo -e "Configuring macOS..."

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

echo -e "Finder: hide hidden files $CHK"
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

echo -e "Dock: put on right side $CHK"
defaults write com.apple.dock orientation right

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

echo -e "Terminal: use Iridium $CHK"
defaults write com.apple.Terminal "Default Window Settings" -string "Iridium"
defaults write com.apple.Terminal "Startup Window Settings" -string "Iridium"


#echo -e "
######################
###     Safari     ###
######################
#"

echo -e "Safari: show full website address $CHK"
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

echo -e "Safari: show favorites bar $CHK"
defaults write com.apple.Safari ShowFavoritesBar -bool true
defaults write com.apple.Safari ShowFavoritesBar-v2 -bool true

echo -e "Safari: show status bar $CHK"
defaults write com.apple.Safari ShowStatusBar -bool true

echo -e "Safari: show overlay status bar $CHK"
defaults write com.apple.Safari ShowOverlayStatusBar -bool true

echo -e "Safari: hide sidebar in new windows $CHK"
defaults write com.apple.Safari ShowSidebarInNewWindows -bool false

echo -e "Safari: hide sidebar in Top Sites $CHK"
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

echo -e "Safari: blank pages on new tabs/windows $CHK"
defaults write com.apple.Safari NewTabBehavior -int 1
defaults write com.apple.Safari NewWindowBehavior -int 1

echo -e "Safari: restore session at launch $CHK"
defaults write com.apple.Safari AlwaysRestoreSessionAtLaunch -bool true

echo -e "Safari: disable autofill $CHK"
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillFromAddressBook -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false
defaults write com.apple.Safari AutoFillPasswords -bool false

echo -e "Safari: disable automatically opening \"safe\" downloads $CHK"
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

echo -e "Safari: enable devloper menu $CHK"
defaults write com.apple.Safari IncludeDevelopMenu -bool true

echo -e "Safari: enable debug menu $CHK"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

echo -e "Safari: search as \"contains\" instead of \"starts with\" $CHK"
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false


#echo -e "
#############################
###     Remote Access     ###
#############################
#"
#sudo systemsetup -f -setremotelogin on
#sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist


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

# echo -e "Keyboard: enable full keyboard access for all controls, such as tab in modal dialogs $CHK"
# defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

echo -e "Keyboard: disable autocorrect $CHK"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false



#echo -e "
#############################
###     Miscellaneous     ###
#############################
#"


# echo -e "Show IP address, hostname, OS version when clicking the clock in the login window $CHK"
# sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# echo -e "App Store: check for software updates daily $CHK"
# defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1


# echo -e "Enable snap-to-grid for icons on the desktop and in other icon views $CHK"
# /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
# /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
# /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist


echo -e "Devices: stop Photos from opening every time a new device is plugged in $CHK"
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true


#echo -e "
#############################
###     Accessibility     ###
#############################
#"

echo -e "Accessibility: enable zoom with scroll wheel $CHK"
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true

echo -e "Accessibility: disable antialiasing when zooming in $CHK"
defaults write com.apple.universalaccess closeViewSmoothImages -bool false

echo -e "Accessibility: use control key to zoom with scroll wheel $CHK"
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
defaults write com.apple.AppleMultitouchTrackpad HIDScrollZoomModifierMask -int 262144
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad HIDScrollZoomModifierMask -int 262144


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
########################
###     TextMate     ###
########################
#"

echo -e "TextMate: turn off automatically adding closing characters $CHK"
defaults write com.macromates.TextMate disableTypingPairs -bool true


#echo -e "
#########################
###     1Password     ###
#########################
#"

echo -e "1Password: turn off autosubmit $CHK"
defaults write 2BUA8C4S2C.com.agilebits.onepassword4-helper autosubmit -bool false


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


#echo -e "
#####################
###     Reset     ###
#####################
#"

# for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
#     "Dock" "Finder" "Flux" "Google Chrome" "Mail" "Messages" \
#     "Opera" "Photos" "Safari" "SizeUp" "Spectacle" "SystemUIServer" "Terminal" \
#     "Transmission" "Tweetbot" "Twitter" "iCal"; do
#     killall "${app}" &> /dev/null
# done

echo -e "macOS configuration complete. Restart computer to see any changes not already visible."
