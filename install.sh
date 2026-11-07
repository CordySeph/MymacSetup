#!/usr/bin/env bash
# ==============================================================================
#  One-line Bootstrap Installer for mymacsetup
#  Usage: curl -fsSL https://raw.githubusercontent.com/CordySeph/mymacsetup/main/install.sh | bash
# ==============================================================================

set -euo pipefail

REPO_URL="https://github.com/CordySeph/mymacsetup.git"
TARGET_DIR="${TARGET_DIR:-$HOME/mymacsetup}"

# Terminal Colors
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}====================================================================${NC}"
echo -e "${BOLD}${BLUE}   🍎 macOS Automated Setup & Environment Restorer (mymacsetup)     ${NC}"
echo -e "${BOLD}${BLUE}====================================================================${NC}"

# 1. Check OS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo -e "${RED}[✖] Error: This script is exclusively designed for macOS!${NC}"
    exit 1
fi

# 2. Check if running inside an already cloned repo
CURRENT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd || true)"

if [[ -f "${SCRIPT_DIR}/Brewfile" && -f "${SCRIPT_DIR}/setup.sh" ]]; then
    echo -e "${GREEN}[✓] Running directly from local repository: ${SCRIPT_DIR}${NC}"
    chmod +x "${SCRIPT_DIR}/setup.sh"
    exec "${SCRIPT_DIR}/setup.sh" "$@"
fi

# 3. Check Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    echo -e "${YELLOW}[*] Installing Xcode Command Line Tools...${NC}"
    xcode-select --install || true
    echo "Please finish the popup installer and press [Enter] to continue..."
    read -r < /dev/tty || true
else
    echo -e "${GREEN}[✓] Xcode Command Line Tools already installed.${NC}"
fi

# 4. Check & Install Homebrew
if ! command -v brew &>/dev/null; then
    echo -e "${YELLOW}[*] Homebrew not found. Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        if ! grep -q "brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
            (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> "$HOME/.zprofile"
        fi
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
        if ! grep -q "brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
            (echo; echo 'eval "$(/usr/local/bin/brew shellenv)"') >> "$HOME/.zprofile"
        fi
    fi
else
    echo -e "${GREEN}[✓] Homebrew is already installed: $(brew --version | head -n 1)${NC}"
fi

# 5. Check git command
if ! command -v git &>/dev/null; then
    echo -e "${YELLOW}[*] Installing git via Homebrew...${NC}"
    brew install git
fi

# 6. Clone or Update mymacsetup Repository
if [[ -d "$TARGET_DIR/.git" ]]; then
    echo -e "${BLUE}[*] Existing repository found at $TARGET_DIR. Updating...${NC}"
    git -C "$TARGET_DIR" pull --ff-only || true
elif [[ -d "$TARGET_DIR" ]]; then
    BACKUP_DIR="${TARGET_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}[!] Existing directory found. Backing up to $BACKUP_DIR...${NC}"
    mv "$TARGET_DIR" "$BACKUP_DIR"
    echo -e "${BLUE}[*] Cloning mymacsetup from $REPO_URL to $TARGET_DIR...${NC}"
    git clone "$REPO_URL" "$TARGET_DIR"
else
    echo -e "${BLUE}[*] Cloning mymacsetup from $REPO_URL to $TARGET_DIR...${NC}"
    git clone "$REPO_URL" "$TARGET_DIR"
fi

# 7. Execute main setup.sh with interactive TTY
echo -e "${GREEN}[✓] Download complete. Launching environment setup...${NC}\n"
chmod +x "$TARGET_DIR/setup.sh"

if [ -t 0 ]; then
    exec "$TARGET_DIR/setup.sh" "$@"
else
    exec "$TARGET_DIR/setup.sh" "$@" < /dev/tty
fi
