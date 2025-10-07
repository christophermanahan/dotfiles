# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# zoxide - a better cd command
eval "$(zoxide init zsh)"

# Custom aliases
alias ls="eza -T -L 1 --git-ignore -a"

# zsh-vi-mode - must load before other plugins that bind keys
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Activate syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Activate autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Bind ctrl-space to accept autosuggestion (after zsh-vi-mode loads)
function zvm_after_init() {
  bindkey "^ " autosuggest-accept
}
