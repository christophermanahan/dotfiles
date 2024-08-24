# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# zoxide - a better cd command
eval "$(zoxide init zsh)"

# Custom aliases
alias ls="eza -T -L 1 --git-ignore -a"

# zsh vi mode
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# source plugins that zsh-vi-mode overrides
function zvm_after_init() {
  # Activate syntax highlighting
  source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  # Bind ctrl-space to accept autosuggestion
  bindkey "^ " autosuggest-accept
  # Activate autosuggestions
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
}
