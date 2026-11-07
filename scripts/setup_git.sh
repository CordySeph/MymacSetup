#!/usr/bin/env bash
# ==============================================================================
#  Git Identity & SSH Key Setup
#  Interactively configures Git user/email and generates an SSH key for GitHub.
# ==============================================================================

set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}==>${NC} ${BOLD}Configuring Git & SSH Settings...${NC}"

# Read input supporting interactive terminals, curl piping, and test pipes
read_input() {
    local prompt="$1"
    local default_val="$2"
    local answer=""

    if [ -t 0 ]; then
        read -r -p "$prompt" answer
    elif [ -e /dev/tty ] && [ -r /dev/tty ] && read -r -p "$prompt" answer < /dev/tty 2>/dev/null; then
        :
    else
        read -r -p "$prompt" answer 2>/dev/null || answer=""
    fi

    echo "${answer:-$default_val}"
}

# ------------------------------------------------------------------------------
# 1. Git User Identity
# ------------------------------------------------------------------------------
CURRENT_NAME="$(git config --global user.name 2>/dev/null || echo "")"
CURRENT_EMAIL="$(git config --global user.email 2>/dev/null || echo "")"
GIT_NAME=""
GIT_EMAIL=""

echo -e "\n${BOLD}Git Identity Configuration:${NC}"

# If already configured on this machine, ask to keep it
if [[ -n "$CURRENT_NAME" && -n "$CURRENT_EMAIL" ]]; then
    echo -e "Existing Git identity detected on this machine:"
    echo -e "  Name:  ${BOLD}${CURRENT_NAME}${NC}"
    echo -e "  Email: ${CYAN}${CURRENT_EMAIL}${NC}"
    KEEP_EXISTING=$(read_input "Do you want to keep this identity? [Y/n]: " "Y")
    
    if [[ "$KEEP_EXISTING" =~ ^[Yy]$ ]]; then
        GIT_NAME="$CURRENT_NAME"
        GIT_EMAIL="$CURRENT_EMAIL"
        echo -e "${GREEN}✔ Retained existing Git identity.${NC}"
    fi
fi

# Prompt for custom credentials if unset or user wants to change
if [[ -z "$GIT_NAME" || -z "$GIT_EMAIL" ]]; then
    echo -e "Please enter your Git identity:"
    while true; do
        GIT_NAME=$(read_input "Enter your Git Full Name: " "")
        GIT_EMAIL=$(read_input "Enter your Git Email: " "")
        
        if [[ -n "$GIT_NAME" && -n "$GIT_EMAIL" ]]; then
            git config --global user.name "$GIT_NAME"
            git config --global user.email "$GIT_EMAIL"
            echo -e "${GREEN}✔ Git configured for: ${BOLD}${GIT_NAME}${NC} <${CYAN}${GIT_EMAIL}${NC}>"
            break
        else
            echo -e "${YELLOW}Name or Email was left empty.${NC}"
            SKIP_GIT=$(read_input "Do you want to skip Git identity configuration? [y/N]: " "N")
            if [[ "$SKIP_GIT" =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}Skipped Git identity configuration.${NC}"
                break
            fi
        fi
    done
fi

# Always configure standard Git developer defaults
git config --global init.defaultBranch "main"
git config --global credential.helper "osxkeychain"
git config --global core.autocrlf "input"

# ------------------------------------------------------------------------------
# 2. SSH Key for GitHub
# ------------------------------------------------------------------------------
SSH_KEY_FILE="$HOME/.ssh/id_ed25519"

echo -e "\n${BOLD}SSH Key Setup for GitHub:${NC}"
if [[ -f "$SSH_KEY_FILE" ]]; then
    echo -e "${GREEN}✔ Existing SSH key found at: ${SSH_KEY_FILE}${NC}"
    if command -v pbcopy &>/dev/null; then
        pbcopy < "${SSH_KEY_FILE}.pub"
        echo -e "${CYAN}Public key copied to clipboard!${NC}"
    fi
else
    GEN_SSH=$(read_input "Do you want to generate a new ED25519 SSH key for GitHub? [Y/n]: " "Y")
    
    if [[ "$GEN_SSH" =~ ^[Yy]$ ]]; then
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        
        SSH_COMMENT="${GIT_EMAIL:-$(whoami)@$(hostname)}"
        ssh-keygen -t ed25519 -C "$SSH_COMMENT" -f "$SSH_KEY_FILE" -N ""
        
        # Configure ~/.ssh/config for macOS Keychain integration
        SSH_CONFIG="$HOME/.ssh/config"
        if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
            cat << 'EOF' >> "$SSH_CONFIG"

Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
            chmod 600 "$SSH_CONFIG"
        fi
        
        # Add to agent
        eval "$(ssh-agent -s)" >/dev/null 2>&1 || true
        ssh-add --apple-use-keychain "$SSH_KEY_FILE" 2>/dev/null || ssh-add "$SSH_KEY_FILE" 2>/dev/null || true
        
        if command -v pbcopy &>/dev/null; then
            pbcopy < "${SSH_KEY_FILE}.pub"
            echo -e "${GREEN}✔ SSH key generated and copied to your clipboard!${NC}"
        else
            echo -e "${GREEN}✔ SSH key generated at ${SSH_KEY_FILE}.pub${NC}"
        fi
        
        echo -e "Add this key to your GitHub account: ${CYAN}https://github.com/settings/keys${NC}"
    else
        echo -e "${YELLOW}Skipping SSH key generation.${NC}"
    fi
fi
