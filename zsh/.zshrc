# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Initialize completion system
autoload -Uz compinit
compinit

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# zoxide - a better cd command
eval "$(zoxide init zsh)"

# Custom aliases
alias ls="eza -T -L 1 --git-ignore -a"

# Enable completion menu selection
zstyle ':completion:*' menu select
zmodload zsh/complist

# zsh-vi-mode - must load before other plugins that bind keys
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Activate syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Activate autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Bind ctrl-space to accept autosuggestion (after zsh-vi-mode loads)
function zvm_after_init() {
  bindkey "^ " autosuggest-accept
  # Rebind Tab for completion (zsh-vi-mode overrides it)
  bindkey '^I' expand-or-complete
  bindkey -M menuselect 'h' vi-backward-char
  bindkey -M menuselect 'j' vi-down-line-or-history
  bindkey -M menuselect 'k' vi-up-line-or-history
  bindkey -M menuselect 'l' vi-forward-char

}
# Enhanced file viewing
alias cat="bat"
alias find="fd"

# FZF integration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --color=always --style=numbers --line-range=:500 {}"'

# Enable FZF keybindings
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
