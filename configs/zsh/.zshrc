# -------------------------------------------------------------
# Homebrew Environment
# -------------------------------------------------------------
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# -------------------------------------------------------------
# Path Configurations
# -------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"

# -------------------------------------------------------------
# Oh My Zsh Configuration
# -------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"

# Starship prompt is used as prompt engine
ZSH_THEME=""

# Plugins to load
# Note: zsh-syntax-highlighting must be loaded last
plugins=(
  git
  zsh-completions
  zsh-autosuggestions
  fzf-tab
  sudo
  extract
  copypath
  copyfile
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# -------------------------------------------------------------
# Tokyo Night Styling & Environment
# -------------------------------------------------------------
# Editor
if command -v nvim &>/dev/null; then
  export EDITOR="nvim"
  export VISUAL="nvim"
fi

# Bat Theme
export BAT_THEME="TokyoNight_Night"

# FZF Tokyo Night Theme & Defaults
export FZF_DEFAULT_OPTS=" \
--color=bg+:#283457,bg:#1a1b26,spinner:#ff007c,hl:#f7768e \
--color=fg:#c0caf5,header:#7aa2f7,info:#7aa2f7,pointer:#ff007c \
--color=marker:#9ece6a,fg+:#c0caf5,prompt:#7dcfff,hl+:#7aa2f7 \
--prompt='❯ ' \
--pointer='▶ ' \
--marker='✓ ' \
--layout=reverse \
--border=rounded \
--height=50% \
--info=inline"

if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND="fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fd --type d --strip-cwd-prefix --hidden --follow --exclude .git"
fi

if command -v bat &>/dev/null; then
  export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :300 {}'"
fi

if command -v eza &>/dev/null; then
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons {}'"
fi

# zsh-autosuggestions Tokyo Night styling
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#565f89"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# fzf-tab styling & preview
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'

# -------------------------------------------------------------
# Useful Aliases
# -------------------------------------------------------------
# Modern CLI replacements
if command -v eza &>/dev/null; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza -la --icons --git --group-directories-first"
  alias la="eza -a --icons --group-directories-first"
  alias lt="eza --tree --level=2 --icons"
  alias llt="eza -la --tree --level=2 --icons --git"
fi

if command -v bat &>/dev/null; then
  alias cat="bat --paging=never"
  alias catp="bat"
fi

# Navigation aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Quick utilities
alias cls="clear"
alias reload="source ~/.zshrc"
alias myip="curl -s https://ipinfo.io/ip; echo"
alias fetch="fastfetch"

# -------------------------------------------------------------
# Shell Integrations (fzf, zoxide, starship)
# -------------------------------------------------------------
# fzf integration
if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi

# zoxide integration (smarter cd)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# Starship prompt
if [[ "$TERM" != "dumb" ]] && command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# -------------------------------------------------------------
# Fastfetch Welcome Banner (on interactive terminal launch)
# -------------------------------------------------------------
if [[ -o interactive ]] && command -v fastfetch &>/dev/null; then
  fastfetch
fi
