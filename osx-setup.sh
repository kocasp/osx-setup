#!/bin/bash

# close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# ask for the administrator password upfront
sudo -v

# keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ----------------------------------------
# GENERAL
# ----------------------------------------

# set computer name (as done via System Preferences → Sharing)
# sudo scutil --set ComputerName ""

# disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# disable user interface sound effects
defaults write NSGlobalDomain "com.apple.sound.uiaudio.enabled" -bool false

# disable volume change feedback
defaults write NSGlobalDomain "com.apple.sound.beep.feedback" -bool false
defaults write NSGlobalDomain "com.apple.sound.beep.volume" -float 0

# menu bar
defaults write com.apple.systemuiserver menuExtras -array \
	"/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
	"/System/Library/CoreServices/Menu Extras/AirPort.menu" \
	"/System/Library/CoreServices/Menu Extras/Battery.menu" \
	"/System/Library/CoreServices/Menu Extras/Clock.menu"

# set clock to show date and time in AM/PM format
defaults write com.apple.menuextra.clock "DateFormat" "EEE d MMM  h:mm a"

# login items
# alternative: https://github.com/OJFord/loginitems/blob/master/loginitems
# osascript -e 'tell application "System Events" to get the name of every login item'
osascript -e 'tell application "System Events" to delete login item "TripMode"' &> /dev/null
osascript -e 'tell application "System Events" to make login item at end with properties {name:"Flux", path:"/Applications/Flux.app", hidden:false}' &> /dev/null
osascript -e 'tell application "System Events" to make login item at end with properties {name:"iTerm", path:"/Applications/iTerm.app", hidden:false}' &> /dev/null
osascript -e 'tell application "System Events" to make login item at end with properties {name:"InsomniaX", path:"/Applications/InsomniaX.app", hidden:false}' &> /dev/null

# expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# aave to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# remove duplicates in the “Open With” menu (also see `lscleanup` alias)
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

# ----------------------------------------
# TRACKPAD, MOUSE, KEYBOARD, INPUT
# ----------------------------------------

# trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# disable automatical words capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# stop iTunes from responding to the keyboard media keys
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

# ----------------------------------------
# FINDER
# ----------------------------------------

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# when performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# use list view in all Finder windows by default
# four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# show Library directory
chflags nohidden ~/Library/

# show the /Volumes folder
sudo chflags nohidden /Volumes

# ----------------------------------------
# DOCK
# ----------------------------------------

# set Dock orientation to right
defaults write com.apple.dock orientation -string right

# show only open applications in the Dock
defaults write com.apple.dock static-only -bool true

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# hide OS X Dock for (almost) good
defaults write com.apple.dock autohide-delay -float 1000

# resize Dock tiles
defaults write com.apple.dock tilesize -float 16

# do not rearrange spaces based on recent use
defaults write com.apple.dock mru-spaces -bool false

# ----------------------------------------
# SPOTLIGHT
# ----------------------------------------

# hide Spotlight tray-icon (and subsequent helper)
# sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search

# ----------------------------------------
# APPS
# ----------------------------------------

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "/Users/$USER/.iterm"

# disable idle sleep when on AC in InsomniaX
defaults write net.semaja2.InsomniaX.plist disableIdleSleepOnAC -bool true
defaults write net.semaja2.InsomniaX.plist enableIdleSleepOnBattery -bool true

# disable spelling auto-correction in Messenger
defaults write me.rsms.fbmessenger.plist WebAutomaticSpellingCorrectionEnabled -bool false

# change default Screenshots directory
mkdir -p ~/Pictures/Screenshots
defaults write com.apple.screencapture location ~/Pictures/Screenshots

# ----------------------------------------
# KILL AFFECTED APPLICATIONS
# ----------------------------------------

for app in "cfprefsd"	"Dock" "Finder" "SystemUIServer" "iTerm2" "InsomniaX" "Messenger"; do
	killall "${app}" &> /dev/null
done
echo "Done. Note that some of these changes require a logout/restart to take effect."
