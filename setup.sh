#!/usr/bin/env bash
# ==============================================================================
#  macOS Setup & Environment Restorer
#  Automates Homebrew, iTerm2, Zsh plugins, Tokyo Night theming, Git, and macOS tweaks.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Styling
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}==>${NC} ${BOLD}$1${NC}"
}

success() {
    echo -e "${GREEN}✔${NC} $1"
}

warn() {
    echo -e "${YELLOW}▲${NC} $1"
}

error() {
    echo -e "${RED}✖${NC} $1"
}

header() {
    echo ""
    echo -e "${BOLD}${BLUE}====================================================================${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}====================================================================${NC}"
}

usage() {
    echo "Usage: ./setup.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --all        Run all setup steps (default)"
    echo "  --brew       Install Homebrew and bundle packages from Brewfile"
    echo "  --zsh        Install Oh My Zsh and Zsh plugins"
    echo "  --dotfiles   Deploy configuration files (~/.zshrc, starship, bat, fastfetch)"
    echo "  --iterm      Configure iTerm2 (Tokyo Night profile, color presets, preferences)"
    echo "  --git        Configure Git identity and SSH key for GitHub"
    echo "  --macos      Apply macOS developer system settings"
    echo "  --help       Show this help message"
    exit 0
}

# ------------------------------------------------------------------------------
# OS Verification
# ------------------------------------------------------------------------------
if [[ "$OSTYPE" != "darwin"* ]]; then
    error "This script is exclusively designed for macOS!"
    exit 1
fi

# ------------------------------------------------------------------------------
# Execution Flags
# ------------------------------------------------------------------------------
DO_BREW=false
DO_ZSH=false
DO_DOTFILES=false
DO_ITERM=false
DO_GIT=false
DO_MACOS=false
DO_ALL=true

if [[ $# -gt 0 ]]; then
    DO_ALL=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --all)
                DO_ALL=true
                shift
                ;;
            --brew)
                DO_BREW=true
                shift
                ;;
            --zsh)
                DO_ZSH=true
                shift
                ;;
            --dotfiles)
                DO_DOTFILES=true
                shift
                ;;
            --iterm)
                DO_ITERM=true
                shift
                ;;
            --git)
                DO_GIT=true
                shift
                ;;
            --macos)
                DO_MACOS=true
                shift
                ;;
            --help|-h)
                usage
                ;;
            *)
                error "Unknown option: $1"
                usage
                ;;
        esac
    done
fi

if [[ "$DO_ALL" == true ]]; then
    DO_BREW=true
    DO_ZSH=true
    DO_DOTFILES=true
    DO_ITERM=true
    DO_GIT=true
    DO_MACOS=true
fi

header "🚀 Starting macOS Environment Setup (mymacsetup)"

# ------------------------------------------------------------------------------
# 1. Xcode Command Line Tools & Homebrew
# ------------------------------------------------------------------------------
if [[ "$DO_BREW" == true ]]; then
    header "1. Xcode Command Line Tools"
    if xcode-select -p &>/dev/null; then
        success "Xcode Command Line Tools already installed."
    else
        info "Installing Xcode Command Line Tools..."
        xcode-select --install || true
        echo "Please complete the popup installer, then press [Enter] to continue..."
        read -r < /dev/tty || true
    fi

    header "2. Homebrew & Package Installation"
    if command -v brew &>/dev/null; then
        success "Homebrew is already installed: $(brew --version | head -n 1)"
    else
        info "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Configure Homebrew PATH for current session and ~/.zprofile
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

    if [[ -f "$SCRIPT_DIR/Brewfile" ]]; then
        info "Installing packages and casks from $SCRIPT_DIR/Brewfile..."
        brew bundle --file="$SCRIPT_DIR/Brewfile" || {
            warn "brew bundle completed (some packages may already be installed or up to date)."
        }
        success "Homebrew packages installed successfully."
    else
        error "Brewfile not found at $SCRIPT_DIR/Brewfile"
        exit 1
    fi
fi

# ------------------------------------------------------------------------------
# 2. Oh My Zsh & Zsh Plugins
# ------------------------------------------------------------------------------
if [[ "$DO_ZSH" == true ]]; then
    header "3. Oh My Zsh & Custom Plugins"
    ZSH_DIR="${HOME}/.oh-my-zsh"
    ZSH_CUSTOM="${ZSH_DIR}/custom"

    if [[ -d "$ZSH_DIR" ]]; then
        success "Oh My Zsh is already installed at $ZSH_DIR"
    else
        info "Installing Oh My Zsh..."
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        success "Oh My Zsh installed successfully."
    fi

    clone_or_update() {
        local repo_url="$1"
        local dest_dir="$2"
        local name="$3"

        if [[ -d "$dest_dir" ]]; then
            info "Updating $name..."
            git -C "$dest_dir" pull --quiet || warn "Unable to pull latest $name (skipping)"
            success "$name is ready."
        else
            info "Cloning $name..."
            git clone --depth=1 "$repo_url" "$dest_dir" --quiet
            success "Installed $name successfully."
        fi
    }

    mkdir -p "${ZSH_CUSTOM}/plugins" "${ZSH_CUSTOM}/themes"

    clone_or_update "https://github.com/zsh-users/zsh-autosuggestions" \
        "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" "zsh-autosuggestions"

    clone_or_update "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
        "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" "zsh-syntax-highlighting"

    clone_or_update "https://github.com/zsh-users/zsh-completions" \
        "${ZSH_CUSTOM}/plugins/zsh-completions" "zsh-completions"

    clone_or_update "https://github.com/Aloxaf/fzf-tab" \
        "${ZSH_CUSTOM}/plugins/fzf-tab" "fzf-tab"

    clone_or_update "https://github.com/romkatv/powerlevel10k.git" \
        "${ZSH_CUSTOM}/themes/powerlevel10k" "powerlevel10k"
fi

# ------------------------------------------------------------------------------
# 3. Dotfiles & Config Syncing
# ------------------------------------------------------------------------------
if [[ "$DO_DOTFILES" == true ]]; then
    header "4. Dotfiles & Configuration Deployment"

    backup_and_copy() {
        local src="$1"
        local dest="$2"

        if [[ -f "$dest" ]]; then
            local timestamp
            timestamp=$(date +%Y%m%d_%H%M%S)
            cp "$dest" "${dest}.backup.${timestamp}"
            warn "Backed up existing file to: ${dest}.backup.${timestamp}"
        fi
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        success "Deployed: $dest"
    }

    # .zshrc
    if [[ -f "$SCRIPT_DIR/configs/zsh/.zshrc" ]]; then
        backup_and_copy "$SCRIPT_DIR/configs/zsh/.zshrc" "$HOME/.zshrc"
    fi

    # Starship Config
    if [[ -f "$SCRIPT_DIR/configs/starship/starship.toml" ]]; then
        mkdir -p "$HOME/.config"
        backup_and_copy "$SCRIPT_DIR/configs/starship/starship.toml" "$HOME/.config/starship.toml"
    fi

    # Fastfetch Config
    if [[ -f "$SCRIPT_DIR/configs/fastfetch/config.jsonc" ]]; then
        mkdir -p "$HOME/.config/fastfetch"
        backup_and_copy "$SCRIPT_DIR/configs/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
    fi

    # Bat Config & Themes
    if [[ -d "$SCRIPT_DIR/configs/bat" ]]; then
        mkdir -p "$HOME/.config/bat/themes"
        if [[ -f "$SCRIPT_DIR/configs/bat/config" ]]; then
            backup_and_copy "$SCRIPT_DIR/configs/bat/config" "$HOME/.config/bat/config"
        fi
        cp -R "$SCRIPT_DIR/configs/bat/themes/"* "$HOME/.config/bat/themes/" 2>/dev/null || true
        success "Copied Bat themes to $HOME/.config/bat/themes/"
        if command -v bat &>/dev/null; then
            bat cache --build &>/dev/null || true
            success "Bat cache built successfully."
        fi
    fi
fi

# ------------------------------------------------------------------------------
# 4. iTerm2 Customization & Tokyo Night Theme
# ------------------------------------------------------------------------------
if [[ "$DO_ITERM" == true ]]; then
    header "5. iTerm2 Profile & Tokyo Night Theme Setup"

    # Dynamic Profiles
    ITERM_APP_SUPPORT="$HOME/Library/Application Support/iTerm2"
    mkdir -p "$ITERM_APP_SUPPORT/DynamicProfiles"
    if [[ -f "$SCRIPT_DIR/configs/iterm2/DynamicProfiles/tokyo-night.plist" ]]; then
        cp "$SCRIPT_DIR/configs/iterm2/DynamicProfiles/tokyo-night.plist" "$ITERM_APP_SUPPORT/DynamicProfiles/"
        success "Installed Dynamic Profile: tokyo-night.plist"
    fi

    # Color Presets directory
    mkdir -p "$HOME/.config/iterm2/colors"
    if compgen -G "$SCRIPT_DIR/configs/iterm2/colors/*.itermcolors" > /dev/null; then
        cp "$SCRIPT_DIR/configs/iterm2/colors/"*.itermcolors "$HOME/.config/iterm2/colors/"
        success "Copied .itermcolors files to $HOME/.config/iterm2/colors/"
    fi

    # Python importer for iTerm2 Custom Color Presets
    python3 - << 'EOF'
import os, glob, plistlib, subprocess

colors_dir = os.path.expanduser("~/.config/iterm2/colors")
if not os.path.isdir(colors_dir):
    exit(0)

try:
    out = subprocess.check_output(['defaults', 'export', 'com.googlecode.iterm2', '-'], stderr=subprocess.DEVNULL)
    prefs = plistlib.loads(out)
except Exception:
    prefs = {}

custom_presets = prefs.setdefault('Custom Color Presets', {})
imported = 0
for fpath in glob.glob(os.path.join(colors_dir, '*.itermcolors')):
    preset_name = os.path.splitext(os.path.basename(fpath))[0]
    try:
        with open(fpath, 'rb') as f:
            custom_presets[preset_name] = plistlib.load(f)
        imported += 1
    except Exception:
        pass

if imported > 0:
    try:
        p = subprocess.Popen(['defaults', 'import', 'com.googlecode.iterm2', '-'], stdin=subprocess.PIPE)
        p.communicate(plistlib.dumps(prefs))
        print(f"✔ Imported {imported} Tokyo Night presets into iTerm2 preferences.")
    except Exception:
        pass
EOF

    # Configure iTerm2 defaults
    info "Setting iTerm2 preferences..."
    defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "tokyo-night-dynamic-guid" || true
    defaults write com.googlecode.iterm2 "TabStyleWithAutomaticOption" -int 3 || true
    defaults write com.googlecode.iterm2 "Draw Powerline Glyphs" -bool true || true
    defaults write com.googlecode.iterm2 "Use Built in Powerline Glyphs" -bool true || true
    success "Configured iTerm2 defaults."
fi

# ------------------------------------------------------------------------------
# 5. Git Identity & SSH Key Setup
# ------------------------------------------------------------------------------
if [[ "$DO_GIT" == true ]]; then
    header "6. Git & SSH Configuration"
    if [[ -f "$SCRIPT_DIR/scripts/setup_git.sh" ]]; then
        bash "$SCRIPT_DIR/scripts/setup_git.sh"
    fi
fi

# ------------------------------------------------------------------------------
# 6. macOS Developer System Settings
# ------------------------------------------------------------------------------
if [[ "$DO_MACOS" == true ]]; then
    header "7. macOS Developer System Settings"
    if [[ -f "$SCRIPT_DIR/scripts/macos_settings.sh" ]]; then
        bash "$SCRIPT_DIR/scripts/macos_settings.sh"
    fi
fi

# ------------------------------------------------------------------------------
# 7. Neovim Config
# ------------------------------------------------------------------------------
if [[ "$DO_ALL" == true || "$DO_DOTFILES" == true ]]; then
    header "8. Neovim Configuration"
    if [[ -d "$HOME/.config/nvim" ]]; then
        success "Neovim configuration already exists at $HOME/.config/nvim"
    else
        info "Cloning Neovim configuration from GitHub..."
        git clone --depth=1 "https://github.com/CordySeph/nvim-config.git" "$HOME/.config/nvim" --quiet || warn "Skipping nvim-config download"
        success "Neovim config installed successfully."
    fi
fi

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
header "🎉 Setup Complete!"

echo -e "${GREEN}${BOLD}Everything is configured and ready to go!${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. Reload your Zsh configuration now:"
echo -e "     ${YELLOW}source ~/.zshrc${NC}"
echo -e "  2. Launch ${BOLD}iTerm2${NC} (it will load your Tokyo Night profile automatically)"
echo -e "  3. If glyphs or icons look unusual, verify your font in:"
echo -e "     ${CYAN}iTerm2 -> Settings -> Profiles -> Text -> Font${NC}"
echo -e "     Recommended: ${BOLD}JetBrainsMono Nerd Font${NC} or ${BOLD}MesloLGS NF${NC}"
echo ""
echo -e "☕️ If you find this setup useful, consider supporting the project!"
echo -e "   Check README.md for crypto donation addresses (BTC / ETH / USDT / BNB) ❤️"
echo ""
