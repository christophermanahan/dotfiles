# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Add local bin to PATH
export PATH="$PATH:$HOME/.local/bin"

# Add Karabiner-Elements to PATH
export PATH="$PATH:/Library/Application Support/org.pqrs/Karabiner-Elements/bin"

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

  # ============================================================================
  # Fuzzy Command Search Functions
  # ============================================================================

  # Helper function to get command usage frequency from history
  _get_command_frequency() {
    fc -l 1 | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | \
    grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n500
  }

  # Helper function to create a sorted command list (most used first)
  _get_sorted_commands() {
    # Get all commands
    local all_cmds=$(print -rl -- ${(ko)commands})

    # Get command frequency and create a lookup
    local freq_file=$(mktemp)
    fc -l 1 | awk '{print $2}' | sort | uniq -c | sort -rn > "$freq_file"

    # Sort commands by frequency, then alphabetically
    echo "$all_cmds" | while read cmd; do
      local freq=$(grep -w "^[[:space:]]*[0-9]*[[:space:]]*$cmd$" "$freq_file" | awk '{print $1}' | head -1)
      if [ -z "$freq" ]; then
        freq=0
      fi
      printf "%05d %s\n" "$freq" "$cmd"
    done | sort -rn | cut -d' ' -f2-

    rm -f "$freq_file"
  }

  # Main command search widget (Alt+Q)
  # Note: Changed from Alt+X to avoid conflict with tmux's Alt+X (kill pane)
  # Now supports hierarchical commands (e.g., "git commit", "docker build")
  fzf-command-widget() {
    local cache_file="$HOME/.cache/paradiddle/commands.db"

    # Generate cache if missing or older than 7 days
    if [[ ! -f "$cache_file" ]] || [[ $(find "$cache_file" -mtime +7 2>/dev/null) ]]; then
      echo "🔄 Updating command cache (this may take a few seconds)..."
      if command -v paradiddle-update-commands &>/dev/null; then
        paradiddle-update-commands &>/dev/null &
      fi
    fi

    # Combine cached subcommands with top-level executables
    local subcommands=""
    if [[ -f "$cache_file" ]]; then
      subcommands=$(cat "$cache_file")
    fi

    local top_level=$(print -rl -- ${(ko)commands})

    # Merge (subcommands first for priority)
    local all_commands=$(printf "%s\n%s\n" "$subcommands" "$top_level" | grep -v '^$')

    local selected_cmd=$(echo "$all_commands" | \
      fzf --height=90% \
          --reverse \
          --border \
          --prompt="🔍 All Commands (with subcommands): " \
          --header="Alt+Q: Search commands | Ctrl+/: Preview | Enter: Insert | Ctrl+E: Execute | Ctrl+U: Update cache" \
          --preview='
            # Split command into parts (use {} which is the fzf placeholder)
            cmd_line="{}"
            parts=($=cmd_line)
            main_cmd=${parts[1]}
            sub_cmd=${parts[2]}

            # Show different info based on structure
            if [[ -n "$sub_cmd" ]]; then
              # Subcommand: show specific help
              echo "Command: $main_cmd $sub_cmd"
              echo "---"
              $main_cmd $sub_cmd --help 2>&1 | head -30 ||
              $main_cmd help $sub_cmd 2>&1 | head -30 ||
              man $main_cmd 2>&1 | grep -A 20 "$sub_cmd" ||
              echo "Subcommand help not available"
            else
              # Top-level: show regular preview
              (whatis $main_cmd 2>/dev/null) ||
              (man $main_cmd 2>/dev/null | head -30) ||
              ($main_cmd --help 2>&1 | head -20) ||
              (which $main_cmd 2>/dev/null | xargs file) ||
              echo "No info for: $main_cmd"
            fi
          ' \
          --preview-window=right:55%:wrap \
          --bind='ctrl-/:toggle-preview' \
          --bind='ctrl-e:execute(echo {} && zsh -c {})+abort' \
          --bind='ctrl-u:execute(paradiddle-update-commands)+reload(cat '$cache_file'; print -rl -- ${(ko)commands})' \
          --expect=ctrl-e)

    local key=$(echo "$selected_cmd" | head -1)
    local cmd=$(echo "$selected_cmd" | tail -1)

    if [ -n "$cmd" ]; then
      if [ "$key" = "ctrl-e" ]; then
        # Ctrl+E: Execute immediately (skip flag picker)
        BUFFER="$cmd"
        zle accept-line
      else
        # Stage 2: Check if flags are available and auto-trigger picker
        local flags_file="$HOME/.config/paradiddle/flags/${cmd// /_}.flags"
        local used_flag_picker=false

        if [[ -f "$flags_file" ]]; then
          # Flags available - trigger flag picker directly (no messages to avoid ZLE issues)
          used_flag_picker=true
          local built_cmd=$(fzf-flag-picker "$cmd")

          if [[ -n "$built_cmd" ]]; then
            # Flags were selected, use built command
            LBUFFER="${LBUFFER}${built_cmd} "
          else
            # Flag picker was cancelled, use base command
            LBUFFER="${LBUFFER}${cmd} "
          fi
        else
          # No flags available, insert base command
          LBUFFER="${LBUFFER}${cmd} "
        fi

        # Only call zle reset-prompt if we didn't use flag picker
        # (flag picker's fzf already handles terminal state)
        if [[ "$used_flag_picker" == "false" ]]; then
          zle reset-prompt
        fi
      fi
    fi
  }
  zle -N fzf-command-widget
  bindkey '\ex' fzf-command-widget  # Alt+x

  # Git commands search (Alt+Shift+G)
  fzf-git-command-widget() {
    local selected_cmd=$(print -rl -- ${(ko)commands} | grep '^git' | \
      fzf --height=90% \
          --reverse \
          --border \
          --prompt="🔍 Git Commands: " \
          --header="Alt+G: Git commands | Ctrl+/: Toggle preview | Enter: Insert | Ctrl+E: Execute" \
          --preview="man {} 2>/dev/null | head -n 30 || {} --help 2>&1 | head -20 || echo 'No info for {}'" \
          --preview-window=right:55%:wrap \
          --bind='ctrl-/:toggle-preview' \
          --bind='ctrl-e:execute(echo {} && zsh -c {})+abort' \
          --expect=ctrl-e)

    local key=$(echo "$selected_cmd" | head -1)
    local cmd=$(echo "$selected_cmd" | tail -1)

    if [ -n "$cmd" ]; then
      if [ "$key" = "ctrl-e" ]; then
        BUFFER="$cmd"
        zle accept-line
      else
        LBUFFER="${LBUFFER}${cmd}"
      fi
    fi

    zle reset-prompt
  }
  zle -N fzf-git-command-widget
  bindkey '\eG' fzf-git-command-widget  # Alt+Shift+G

  # Docker commands search (Alt+Shift+D)
  fzf-docker-command-widget() {
    local selected_cmd=$(print -rl -- ${(ko)commands} | grep -E '^docker|^lazydocker|^kubectl|^k9s' | \
      fzf --height=90% \
          --reverse \
          --border \
          --prompt="🐳 Docker/K8s Commands: " \
          --header="Alt+D: Docker/K8s | Ctrl+/: Toggle preview | Enter: Insert | Ctrl+E: Execute" \
          --preview="man {} 2>/dev/null | head -n 30 || {} --help 2>&1 | head -20 || echo 'No info for {}'" \
          --preview-window=right:55%:wrap \
          --bind='ctrl-/:toggle-preview' \
          --bind='ctrl-e:execute(echo {} && zsh -c {})+abort' \
          --expect=ctrl-e)

    local key=$(echo "$selected_cmd" | head -1)
    local cmd=$(echo "$selected_cmd" | tail -1)

    if [ -n "$cmd" ]; then
      if [ "$key" = "ctrl-e" ]; then
        BUFFER="$cmd"
        zle accept-line
      else
        LBUFFER="${LBUFFER}${cmd}"
      fi
    fi

    zle reset-prompt
  }
  zle -N fzf-docker-command-widget
  bindkey '\eD' fzf-docker-command-widget  # Alt+Shift+D

  # AWS commands search (Alt+Shift+A)
  fzf-aws-command-widget() {
    local selected_cmd=$(print -rl -- ${(ko)commands} | grep -E '^aws|^e1s|^e2s|^terraform|^tf' | \
      fzf --height=90% \
          --reverse \
          --border \
          --prompt="☁️  AWS Commands: " \
          --header="Alt+A: AWS/Cloud tools | Ctrl+/: Toggle preview | Enter: Insert | Ctrl+E: Execute" \
          --preview="man {} 2>/dev/null | head -n 30 || {} --help 2>&1 | head -20 || echo 'No info for {}'" \
          --preview-window=right:55%:wrap \
          --bind='ctrl-/:toggle-preview' \
          --bind='ctrl-e:execute(echo {} && zsh -c {})+abort' \
          --expect=ctrl-e)

    local key=$(echo "$selected_cmd" | head -1)
    local cmd=$(echo "$selected_cmd" | tail -1)

    if [ -n "$cmd" ]; then
      if [ "$key" = "ctrl-e" ]; then
        BUFFER="$cmd"
        zle accept-line
      else
        LBUFFER="${LBUFFER}${cmd}"
      fi
    fi

    zle reset-prompt
  }
  zle -N fzf-aws-command-widget
  bindkey '\eA' fzf-aws-command-widget  # Alt+Shift+A

  # Show aliases and functions (Alt+Shift+X)
  fzf-alias-widget() {
    # Combine aliases and functions with type indicators
    local selected=$(
      {
        print -rl -- ${(k)aliases} | awk '{print "[ALIAS] " $0}'
        print -rl -- ${(k)functions} | grep -v '^_' | awk '{print "[FUNC]  " $0}'
      } | sort | \
      fzf --height=90% \
          --reverse \
          --border \
          --prompt="🔧 Aliases & Functions: " \
          --header="Alt+Shift+X: Aliases/Functions | Ctrl+/: Toggle preview | Enter: Insert | Ctrl+E: Execute" \
          --preview='
            item=$(echo {} | sed "s/^\[.*\] //");
            type=$(echo {} | grep -oE "^\[.*\]");
            if [[ $type == "[ALIAS]" ]]; then
              alias $item 2>/dev/null || echo "Alias: $item";
            else
              which $item 2>/dev/null | tail -n +2 || echo "Function: $item";
            fi
          ' \
          --preview-window=right:55%:wrap \
          --bind='ctrl-/:toggle-preview' \
          --bind='ctrl-e:execute(echo {} | sed "s/^\[.*\] //" && zsh -c "$(echo {} | sed s/^\[.*\] //)")+abort' \
          --expect=ctrl-e)

    local key=$(echo "$selected" | head -1)
    local item=$(echo "$selected" | tail -1 | sed 's/^\[.*\] //')

    if [ -n "$item" ]; then
      if [ "$key" = "ctrl-e" ]; then
        BUFFER="$item"
        zle accept-line
      else
        LBUFFER="${LBUFFER}${item}"
      fi
    fi

    zle reset-prompt
  }
  zle -N fzf-alias-widget
  bindkey '\eX' fzf-alias-widget  # Alt+Shift+X

  # Homebrew package search (Alt+Shift+B)
  fzf-brew-widget() {
    local selected_cmd=$(brew list | \
      fzf --height=90% \
          --reverse \
          --border \
          --prompt="🍺 Homebrew Packages: " \
          --header="Alt+B: Installed brew packages | Ctrl+/: Toggle preview | Enter: Insert" \
          --preview="brew info {} 2>/dev/null || echo 'No info for {}'" \
          --preview-window=right:55%:wrap \
          --bind='ctrl-/:toggle-preview')

    if [ -n "$selected_cmd" ]; then
      LBUFFER="${LBUFFER}${selected_cmd}"
    fi

    zle reset-prompt
  }
  zle -N fzf-brew-widget
  bindkey '\eB' fzf-brew-widget  # Alt+Shift+B

  # ============================================================================
  # Flag Picker Function (Option A: Two-Stage Selection)
  # ============================================================================

  # Interactive flag picker for commands
  # Usage: fzf-flag-picker "docker build"
  fzf-flag-picker() {
    local cmd="$1"
    local flags_file="$HOME/.config/paradiddle/flags/${cmd// /_}.flags"

    # Check if flags file exists - silently return if not found
    if [[ ! -f "$flags_file" ]]; then
      return 1
    fi

    # Count total flags
    local total_flags=$(grep -v '^#' "$flags_file" | grep -v '^$' | wc -l | tr -d ' ')
    local common_flags=$(grep -v '^#' "$flags_file" | grep '|common|' | wc -l | tr -d ' ')

    # Load flags and format for display
    local flags_formatted=$(grep -v '^#' "$flags_file" | grep -v '^$' | awk -F'|' '
      {
        flag = $1
        short = $2
        type = $3
        desc = $4
        example = $5
        category = $6

        # Format display: show flag, short form, and description
        if (short != "") {
          display = sprintf("%-20s %-4s  %s", flag, short, desc)
        } else {
          display = sprintf("%-20s      %s", flag, desc)
        }

        # Add category indicator
        if (category == "common") {
          display = "⭐ " display
        } else {
          display = "   " display
        }

        # Store full line for later parsing
        print display "|METADATA|" $0
      }
    ')

    # Show fzf multi-select
    local selected=$(echo "$flags_formatted" | \
      fzf --multi \
          --height=90% \
          --reverse \
          --border \
          --prompt="🔧 $cmd flags ($common_flags common, $total_flags total): " \
          --header="Space: Select | Enter: Confirm | Esc: Skip flag selection" \
          --preview='
            # Extract metadata from selection
            metadata=$(echo {} | sed "s/.*|METADATA|//")

            # Parse flag details
            flag=$(echo "$metadata" | cut -d"|" -f1)
            short=$(echo "$metadata" | cut -d"|" -f2)
            type=$(echo "$metadata" | cut -d"|" -f3)
            desc=$(echo "$metadata" | cut -d"|" -f4)
            example=$(echo "$metadata" | cut -d"|" -f5)
            category=$(echo "$metadata" | cut -d"|" -f6)
            repeatable=$(echo "$metadata" | cut -d"|" -f8)

            # Display flag details
            echo "Flag: $flag"
            if [[ -n "$short" ]]; then
              echo "Short: $short"
            fi
            echo "Type: $type"
            echo "Category: $category"
            if [[ "$repeatable" == "true" ]]; then
              echo "Repeatable: Yes (can use multiple times)"
            fi
            echo ""
            echo "Description:"
            echo "  $desc"

            if [[ -n "$example" && "$example" != "<none>" ]]; then
              echo ""
              echo "Example:"
              echo "  '"$cmd"' $flag $example"
            fi
          ' \
          --preview-window=right:50%:wrap \
          --bind='ctrl-/:toggle-preview')

    # If no selection, return empty
    if [[ -z "$selected" ]]; then
      return 1
    fi

    # Build command with selected flags
    local built_cmd="$cmd"
    while IFS='|' read -r display metadata rest; do
      # Extract flag name from metadata
      local flag=$(echo "$metadata" | cut -d'|' -f1)
      local type=$(echo "$metadata" | cut -d'|' -f3)

      # Add flag to command
      if [[ "$type" == "boolean" ]]; then
        # Boolean flags don't need values
        built_cmd="$built_cmd $flag"
      else
        # Other flags need values - add placeholder
        built_cmd="$built_cmd $flag <$type>"
      fi
    done <<< "$selected"

    # Return the built command
    echo "$built_cmd"
  }
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

# Rust environment
export PATH="$HOME/.cargo/bin:$PATH"

# Load secrets (API keys, tokens, etc.) from separate gitignored file
# Create ~/.zshrc.secrets and add your secrets there:
#   export ANTHROPIC_API_KEY="sk-ant-your-key-here"
#   export OPENAI_API_KEY="sk-your-key-here"
# This file is gitignored to prevent accidental commits of sensitive data
if [ -f ~/.zshrc.secrets ]; then
  source ~/.zshrc.secrets
fi
