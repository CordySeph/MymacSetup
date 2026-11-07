#!/usr/bin/env bash
# ==============================================================================
#  macOS System Defaults for Developers
#  Configures keyboard repeat rate, Vim navigation, Finder preferences, and more.
# ==============================================================================

set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}==>${NC} ${BOLD}Configuring macOS Developer Preferences...${NC}"

# Close any open System Settings panes to prevent overriding changes
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

# ------------------------------------------------------------------------------
# 1. Keyboard & Typing (Essential for Neovim / Vim navigation)
# ------------------------------------------------------------------------------
echo -e "  Setting fast keyboard repeat rate and disabling press-and-hold..."

# Disable press-and-hold for keys in favor of key repeat (allows holding h/j/k/l to move)
defaults write -g ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate (2 = very fast)
defaults write NSGlobalDomain KeyRepeat -int 2

# Set delay until key repeat starts (15 = 225ms, standard is 30)
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable automatic capitalization, smart dashes, automatic period substitution, and smart quotes
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# ------------------------------------------------------------------------------
# 2. Finder Preferences
# ------------------------------------------------------------------------------
echo -e "  Configuring Finder preferences..."

# Show all filename extensions (e.g., .tar.gz, .config)
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar at the bottom of Finder windows
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar with available storage info
defaults write com.apple.finder ShowStatusBar -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default (not entire Mac)
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Use list view in all Finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# ------------------------------------------------------------------------------
# 3. Disk & Desktop Services
# ------------------------------------------------------------------------------
echo -e "  Disabling .DS_Store creation on network and USB volumes..."

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Avoid creating .DS_Store files on USB volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# ------------------------------------------------------------------------------
# 4. Restart affected applications
# ------------------------------------------------------------------------------
echo -e "  Restarting Finder..."
killall Finder &>/dev/null || true

echo -e "${GREEN}✔ macOS developer preferences configured successfully!${NC}"
echo -e "${YELLOW}Note: Some keyboard settings may require a logout or restart to take full effect.${NC}"
