# 🍎 My Mac Setup (`mymacsetup`)

[![macOS](https://img.shields.io/badge/macOS-Sonoma%20%7C%20Sequoia-black?logo=apple)](https://www.apple.com/macos/)
[![Homebrew](https://img.shields.io/badge/Homebrew-Bundle-orange?logo=homebrew)](https://brew.sh/)
[![iTerm2](https://img.shields.io/badge/iTerm2-Tokyo%20Night-blue?logo=iterm2)](https://iterm2.com/)
[![Zsh](https://img.shields.io/badge/Shell-Oh%20My%20Zsh-brightgreen?logo=gnu-bash)](https://ohmyz.sh/)

An automated, one-line developer environment restorer and macOS configurator. Sets up **Homebrew packages**, **iTerm2 Tokyo Night theming**, **Oh My Zsh plugins**, **Git & SSH**, and **developer-friendly macOS system defaults** on fresh Mac installations in minutes.

---

## ⚡️ Quick Start: One-line Install

On your fresh Mac, open the default **Terminal.app** and run:

```bash
curl -fsSL https://raw.githubusercontent.com/CordySeph/mymacsetup/main/install.sh | bash
```

> **What the script does automatically:**
> 1. Checks and installs **Xcode Command Line Tools**
> 2. Checks and installs **Homebrew**, permanently configuring your `PATH` in `~/.zprofile`
> 3. Installs all CLI utilities, Nerd Fonts, and GUI applications via [`Brewfile`](Brewfile)
> 4. Installs **Oh My Zsh** and clones custom plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf-tab`, `zsh-completions`)
> 5. Backs up existing dotfiles and deploys configurations for `.zshrc`, `starship.toml`, `bat`, and `fastfetch`
> 6. Configures **iTerm2** with the **Tokyo Night** dynamic profile, color presets, and dark appearance
> 7. Configures **Git user identity** (interactively with custom options) and generates an **ED25519 SSH key** for GitHub
> 8. Applies **macOS system defaults for developers** (fast key repeat, Vim navigation, Finder enhancements)
> 9. Clones your custom Neovim configuration ([`nvim-config`](https://github.com/CordySeph/nvim-config)) into `~/.config/nvim`

---

## 📦 What's Included

### 1. Homebrew Bundle ([`Brewfile`](Brewfile))

#### 🛠 Command-Line Tools & Languages (Formulae)
| Tool | Description |
| :--- | :--- |
| `git` & `git-lfs` | Distributed version control & Large File Storage |
| `gh` | Official GitHub command-line client |
| `node` | Node.js JavaScript runtime environment |
| `go` | Go programming language compiler |
| `rust` | Rust compiler and Cargo package manager |
| `neovim` | Modern, extensible Vim-fork text editor |
| `make` | Build automation and compilation utility |
| `starship` | Fast, customizable cross-shell prompt with Tokyo Night theme |
| `fastfetch` | Lightning-fast system information tool with custom banner |
| `bat` | Enhanced `cat` clone with Tokyo Night syntax highlighting |
| `eza` | Modern replacement for `ls` with file icons and tree view |
| `fzf` & `fd` | Fuzzy finder and fast file search |
| `ripgrep` (`rg`) | Blazingly fast code search tool |
| `zoxide` | Smarter `cd` command that learns your habits |
| `jq` | Lightweight and flexible command-line JSON processor |

#### 🖥 GUI Applications & Nerd Fonts (Casks)
| Application | Description |
| :--- | :--- |
| `iterm2` | Terminal emulator replacement for macOS |
| `visual-studio-code` | Code editor |
| `docker-desktop` | Containerization platform |
| `google-chrome` | Web browser |
| `raycast` | Blazingly fast launcher and productivity tool |
| `tailscale` | Zero config mesh VPN |
| `github` | GitHub Desktop GUI client |
| `font-jetbrains-mono-nerd-font` | Developer font with Powerline glyphs and icons |
| `font-meslo-lg-nerd-font` | Meslo Nerd Font for Starship and terminal prompts |

---

### 2. Shell & Terminal Environment

#### ⚡️ Oh My Zsh & Custom Plugins
- **Oh My Zsh Framework**
- [`zsh-autosuggestions`](https://github.com/zsh-users/zsh-autosuggestions) — Fast asynchronous command suggestions based on your history
- [`zsh-syntax-highlighting`](https://github.com/zsh-users/zsh-syntax-highlighting) — Fish-like syntax highlighting for command verification
- [`zsh-completions`](https://github.com/zsh-users/zsh-completions) — Additional completion definitions for Zsh
- [`fzf-tab`](https://github.com/Aloxaf/fzf-tab) — Interactive fuzzy tab completions with live `eza` previews
- [`powerlevel10k`](https://github.com/romkatv/powerlevel10k) — Optional high-performance prompt theme

#### 🎨 iTerm2 & Tokyo Night Theme
- **Dynamic Profile (`tokyo-night.plist`)**: Installs a ready-to-use Tokyo Night profile with 10,000 lines of scrollback and built-in Powerline glyphs enabled.
- **Color Presets**: 4 Tokyo Night schemes imported into iTerm2: `tokyonight_night`, `tokyonight_storm`, `tokyonight_moon`, and `tokyonight_day`.
- **Minimal / Dark Mode**: Sets iTerm2 window and tabs to seamless dark styling.
- **Starship Prompt (`starship.toml`)**: Styled in Tokyo Night colors with icons for OS, git branch, node, python, go, rust, and docker.
- **Bat Theme (`TokyoNight_Night`)**: Tokyo Night color scheme for syntax highlighting.
- **Fastfetch (`config.jsonc`)**: Styled system information banner launched on interactive sessions.

---

### 3. Developer Defaults for macOS ([`scripts/macos_settings.sh`](scripts/macos_settings.sh))

- **Keyboard & Typing**:
  - Sets ultra-fast keyboard repeat rate (`KeyRepeat = 2`, `InitialKeyRepeat = 15`).
  - Disables press-and-hold character popup (`ApplePressAndHoldEnabled = false`) so you can hold `h`, `j`, `k`, `l` or arrow keys in Neovim and VS Code without delay.
- **Finder Enhancements**:
  - Shows all filename extensions (`AppleShowAllExtensions = true`).
  - Shows hidden files (`AppleShowAllFiles = true`).
  - Shows breadcrumb path bar and status bar (`ShowPathbar`, `ShowStatusBar`).
  - Searches current directory by default instead of entire Mac (`FXDefaultSearchScope = SCcf`).
  - Keeps folders on top when sorting by name.
- **System Hygiene**:
  - Disables `.DS_Store` file creation on network and external USB volumes.

---

### 4. Git & SSH Configuration ([`scripts/setup_git.sh`](scripts/setup_git.sh))

- Interactively sets your Git Name and Email (with defaults provided, or customized per user).
- Sets `init.defaultBranch = main` and enables `credential.helper = osxkeychain`.
- Checks for an existing SSH key. If none exists, prompts to generate an **ED25519** SSH key, configures macOS Keychain integration in `~/.ssh/config`, and copies the public key directly to your clipboard for pasting into [GitHub SSH Keys](https://github.com/settings/keys).

---

## 🛠 Manual & Modular Usage

You can also clone the repository manually and run individual parts of the setup:

```bash
git clone https://github.com/CordySeph/mymacsetup.git ~/mymacsetup
cd ~/mymacsetup
./setup.sh [OPTIONS]
```

### Available Options:
| Option | Description |
| :--- | :--- |
| `./setup.sh` or `./setup.sh --all` | Runs the full setup pipeline (Default) |
| `./setup.sh --brew` | Runs only Homebrew installation and package bundling |
| `./setup.sh --zsh` | Installs only Oh My Zsh and custom plugins |
| `./setup.sh --dotfiles` | Deploys only `.zshrc`, Starship, Bat, and Fastfetch configs |
| `./setup.sh --iterm` | Configures only iTerm2 profiles, colors, and appearance |
| `./setup.sh --git` | Configures only Git user info and SSH keys |
| `./setup.sh --macos` | Applies only macOS developer system defaults |
| `./setup.sh --help` | Displays command-line help |

---

## 📁 Repository Structure

```text
mymacsetup/
├── Brewfile                                    # Homebrew formulae and casks list
├── install.sh                                  # One-line curl bootstrap installer
├── setup.sh                                    # Main modular setup script
├── README.md                                   # Documentation
├── .gitignore
├── scripts/
│   ├── macos_settings.sh                       # Developer macOS defaults configuration
│   └── setup_git.sh                            # Interactive Git identity and SSH setup
└── configs/
    ├── zsh/
    │   └── .zshrc                              # Zsh config, plugins, and custom aliases
    ├── starship/
    │   └── starship.toml                       # Tokyo Night Starship prompt
    ├── fastfetch/
    │   └── config.jsonc                        # Fastfetch system info banner
    ├── bat/
    │   ├── config                              # Bat configuration
    │   └── themes/                             # Tokyo Night tmTheme files
    └── iterm2/
        ├── DynamicProfiles/
        │   └── tokyo-night.plist               # iTerm2 Dynamic Profile definition
        └── colors/                             # .itermcolors presets
```

---

## 🔄 Keeping Your Setup Updated

After installing new applications or packages with Homebrew in the future, you can keep your `Brewfile` in sync:

```bash
cd ~/mymacsetup
brew bundle dump --force --file=./Brewfile
git add Brewfile
git commit -m "chore: update Brewfile"
git push
```

---

## ☕️ Support & Donations

If you found this setup repository useful and would like to support its development and maintenance, donations are greatly appreciated!

| Currency | Network | Wallet Address |
| :--- | :--- | :--- |
| **BTC** | Native SegWit | `bc1qec7awee6j6ym34jy6qq9uswa397lvvw69cytyq` |
| **ETH** | Ethereum (ERC-20) | `0xd1f197009cbe1e7eea91ccf8c216aa7899cdc224` |
| **USDT** | ERC-20 / BEP-20 | `0xd1f197009cbe1e7eea91ccf8c216aa7899cdc224` |
| **BNB** | BNB Smart Chain (BEP-20) | `0xd1f197009cbe1e7eea91ccf8c216aa7899cdc224` |

Thank you for your support! ❤️

