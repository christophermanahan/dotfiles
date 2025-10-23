# FZF (Fuzzy Finder) Configuration
# This file is sourced by .zshrc via: [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Use fd (find alternative) for file searching
# - --type f: only search for files
# - --hidden: include hidden files
# - --follow: follow symbolic links
# - --exclude .git: skip .git directories
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Use same command for CTRL-T (file selection in command line)
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# FZF display options with bat preview
# - --height 40%: use 40% of screen height
# - --layout=reverse: results on top, prompt at bottom
# - --border: show border around fzf window
# - --preview: show file preview using bat with syntax highlighting
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --color=always --style=numbers --line-range=:500 {}"'

# Load fzf key bindings and completion (installed via homebrew)
# These provide:
# - CTRL-T: Paste selected files/directories onto command line
# - CTRL-R: Search command history
# - ALT-C:  cd into selected directory
if [ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]; then
  source /opt/homebrew/opt/fzf/shell/completion.zsh
fi

if [ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi
