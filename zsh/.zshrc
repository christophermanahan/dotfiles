# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Force k9s to use XDG config directory (cross-platform)
export K9S_CONFIG_DIR="$HOME/.config/k9s"

# Initialize completion system
autoload -Uz compinit
compinit

# Starship config path (init happens in zvm_after_init to avoid conflicts)
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# zoxide - a better cd command
eval "$(zoxide init zsh)"

# Custom aliases
alias ls="eza -T -L 1 --git-ignore -a"

# Enable completion menu selection
zstyle ':completion:*' menu select
zmodload zsh/complist

# Reduce ESC key delay for vi mode (default is 40 = 400ms, set to 1 = 10ms)
# This makes entering/exiting vi modes feel instant
KEYTIMEOUT=1

# Configure zsh-vi-mode BEFORE sourcing the plugin
function zvm_config() {
  # Use the better readkey engine (NEX) for improved performance
  # This engine provides better handling of key sequences and text objects
  ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_NEX

  # Set key timeout for multi-key sequences (text objects like 'diw', 'ciw')
  # Default is 0.4 seconds, keeping it low for responsiveness
  ZVM_KEYTIMEOUT=0.4
}

# zsh-vi-mode - must load before other plugins that bind keys
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Activate syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Activate autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Run after zsh-vi-mode loads (fixes conflicts with starship and other plugins)
function zvm_after_init() {
  # Initialize starship prompt AFTER zsh-vi-mode to avoid zle-keymap-select conflicts
  eval "$(starship init zsh)"

  # Bind ctrl-space to accept autosuggestion
  bindkey "^ " autosuggest-accept

  # Rebind Tab for completion (zsh-vi-mode overrides it)
  bindkey '^I' expand-or-complete

  # Vi-style navigation in completion menu
  bindkey -M menuselect 'h' vi-backward-char
  bindkey -M menuselect 'j' vi-down-line-or-history
  bindkey -M menuselect 'k' vi-up-line-or-history
  bindkey -M menuselect 'l' vi-forward-char

  # ALT+n to launch nvim
  # Creates a widget that accepts the current line, runs nvim, and resets the prompt
  launch-nvim() {
    BUFFER="nvim"
    zle accept-line
  }
  zle -N launch-nvim
  bindkey '\en' launch-nvim  # ALT+n

  # Load FZF key bindings AFTER zsh-vi-mode to ensure they work in vi insert mode
  # This prevents zsh-vi-mode from overriding Ctrl+R, Ctrl+T, Alt+C
  if [ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  fi
}
# Enhanced file viewing
alias cat="bat"
alias find="fd"

# Load FZF configuration (includes exports, keybindings, and completion)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Define git aliases
alias lg="lazygit"
alias gst="git status"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gp="git push"
alias gpl="git pull"
alias gcm="git commit -m"
alias glog="git log --oneline --graph --decorate --all"
