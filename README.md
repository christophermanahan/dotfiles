# Dotfiles

Personal development environment configuration using GNU Stow.

## Features

### Core Tools
- **Git**: Version control with comprehensive aliases and modern defaults, git-delta integration for enhanced diffs
- **Wezterm**: Smart terminal with 85% transparency, custom tab formatting, smart-splits integration, and per-directory unique tab colors
- **Neovim**: NvChad v2.5 with full transparency support, extensive LSP, formatting, completion, and navigation plugins
- **ZSH**: Vi-mode, autosuggestions, syntax highlighting, FZF integration, and enhanced directory navigation with zoxide
- **Starship**: Custom prompt with Catppuccin Mocha theme
- **tmux**: Terminal multiplexer with floating terminal integration in Neovim

### Developer Tools (Floating Terminals)
- **lazygit** (Alt+h): Full-featured Git TUI in floating terminal
- **lazydocker** (Alt+d): Docker management TUI with container/image/volume control
- **k9s** (Alt+j): Kubernetes CLI manager with cluster selection menu and 80% namespace picker
- **Claude Code** (Alt+k): AI-powered development assistant terminal
- **Codex CLI** (Alt+o): OpenAI Codex assistant for code generation

### Terminal Browsers
- **w3m** (Alt+e to toggle, Alt+s to search): Lightweight browser with native vim keybindings, DuckDuckGo Lite integration
- **Carbonyl** (Alt+c): Chromium-based browser with modern web support (WebGL, video, animations)
- **Browsh** (Alt+b): Firefox-based browser with best rendering of modern websites

### AI Assistants
- **Avante.nvim** (Alt+a): Cursor-like AI coding assistant with Claude Sonnet 4.5 integration
- **CopilotChat**: GitHub Copilot integration for code completion and chat

### UI/UX Features
- **Telescope Transparency**: Fully transparent fuzzy finder matching Wezterm window opacity
- **Centered Input Prompts**: All vim.ui.input dialogs appear centered with 60-char width
- **Fuzzy Directory Changer** (leader+cd): Quick directory navigation from home with centered picker
- **Enhanced Line Numbers**: Optimized colors for visibility with transparency (bright cyan active line)

## Screenshots

### Wezterm with Split Terminals
![Wezterm Split Terminal](screenshots/wezterm-split-terminal-env.png)

### Neovim with Split Editor
![Neovim Split Editor](screenshots/nvim-split-editor.png)

### Neovim with Ripgrep Search
![Neovim Ripgrep Example](screenshots/nvim-ripgrep-example.png)

## Requirements

### Essential Tools
 - git
 - git-delta (optional but recommended for enhanced diffs)
 - stow (GNU Stow for symlink management)
 - neovim (0.9+)
 - font-hack-nerd-font

### Shell & Terminal
 - zsh
 - zsh-vi-mode
 - zsh-autosuggestions
 - zsh-syntax-highlighting
 - wezterm
 - starship (prompt)
 - tmux

### CLI Utilities
 - eza (modern ls replacement)
 - zoxide (smart directory jumping)
 - ripgrep (fast grep alternative)
 - fzf (fuzzy finder)
 - fd (find alternative)
 - bat (cat with syntax highlighting)

### Developer Tools
 - lazygit (Git TUI)
 - lazydocker (Docker TUI)
 - k9s (Kubernetes TUI)
 - codex (OpenAI Codex CLI)

### Terminal Browsers
 - w3m (lightweight, vim keys)
 - carbonyl (Chromium-based, via npm)
 - browsh (Firefox-based, requires Firefox)

## Installation

### 1. Install Homebrew dependencies

```bash
# Essential CLI tools and shell
brew install git git-delta stow neovim eza zoxide ripgrep fzf fd bat

# Shell configuration
brew install zsh zsh-vi-mode zsh-autosuggestions zsh-syntax-highlighting starship

# Terminal and multiplexer
brew install tmux
brew install --cask wezterm firefox

# Developer TUIs
brew install lazygit lazydocker k9s codex

# Terminal browsers
brew install w3m
brew tap browsh-org/homebrew-browsh
brew install browsh
npm install -g carbonyl

# Fonts
brew install --cask font-hack-nerd-font
```

### 2. Clone dotfiles repository

```bash
git clone https://github.com/christophermanahan/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Deploy configurations with Stow

```bash
# Remove existing configs if present
rm -f ~/.zshrc

# Stow configurations (creates symlinks from repo to home directory)
stow git      # Deploys to ~/.gitconfig
stow wezterm
stow zsh
stow starship
stow nvim
stow tmux
stow k9s      # Cross-platform: deploys to ~/.config/k9s/ (K9S_CONFIG_DIR enforces XDG)
```

### 4. Reload shell configuration

```bash
source ~/.zshrc
```

### 5. Launch Neovim to install plugins

On first launch, Neovim will automatically:
- Install NvChad (v2.5)
- Install all plugins via Lazy.nvim
- Install LSP servers via Mason (HTML, CSS, TypeScript, Python, Rust, Terraform, Docker, Prisma, Markdown)

```bash
nvim
```

Wait for all installations to complete, then restart Neovim.

## Shortcuts

### Wezterm

**Leader Key:** `Ctrl+A`

#### Window Management
| Shortcut | Action |
|----------|--------|
| `Ctrl+'` | Split vertical |
| `Ctrl+b` | Split horizontal |
| `Ctrl+h/j/k/l` | Navigate between panes (nvim/wezterm) |
| `Ctrl+z` | Zoom pane |
| `Ctrl+x` or `Leader+[` | Copy mode (vi keys to navigate) |
| `Leader+h/j/k/l` | Resize panes |
| `Leader+f` | Toggle fullscreen |

#### Tab Management
| Shortcut | Action |
|----------|--------|
| `CMD+w` | Close current tab |
| `CMD+Shift+h` | Move tab left |
| `CMD+Shift+l` | Move tab right |
| `Leader+w` | Tab navigator |
| `Leader+m` | Quick launch menu (k9s, lazygit, lazydocker, btm, htop) |

#### Terminal
| Shortcut | Action |
|----------|--------|
| `CMD+L` | Clear terminal |

### Neovim

**Leader Key:** `Space`

#### File Navigation
| Shortcut | Action |
|----------|--------|
| `<leader>e` | Focus current file in tree |
| `Ctrl+h/j/k/l` | Navigate between splits |
| `s` + motion | Flash jump (quick navigation) |
| `S` + motion | Flash treesitter jump |

#### Nvim-Tree (File Explorer)
| Shortcut | Action |
|----------|--------|
| `h` | Close directory / Navigate to parent |
| `l` | Open directory or file |
| `W` | Collapse all directories |

#### Code Navigation
| Shortcut | Action |
|----------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | View references (telescope) |
| `<leader>D` | Go to type definition |
| `gpd` | Preview definition |
| `gpt` | Preview type definition |
| `gpi` | Preview implementation |
| `gpD` | Preview declaration |
| `gpr` | Preview references |
| `gP` | Close preview |

#### Code Actions
| Shortcut | Action |
|----------|--------|
| `ga` | Code actions |
| `<leader>ra` | Rename symbol |
| `<leader>S` | Search and replace (GrugFar) |

#### Tabs & Buffers
| Shortcut | Action |
|----------|--------|
| `gC` | New tab |
| `gt` | Next tab |
| `gT` | Previous tab |
| `<leader>X` | Close all other buffers |

#### Terminal Management
| Shortcut | Action |
|----------|--------|
| `ALT+i` | Toggle floating tmux terminal (auto-cleanup on exit) |
| `ALT+k` | Toggle Claude Code terminal |
| `ALT+j` | Toggle k9s terminal (cluster + namespace selection on first open) |
| `ALT+h` | Toggle lazygit terminal |
| `ALT+d` | Toggle lazydocker terminal (Docker TUI) |
| `ALT+o` | Toggle Codex CLI terminal (OpenAI Codex) |
| `ALT+e` | Toggle w3m browser (lightweight, vim keys) |
| `ALT+s` | Search in w3m (prompts for DuckDuckGo query) |
| `ALT+c` | Toggle Carbonyl browser (Chromium-based, cutting edge) |
| `ALT+b` | Toggle Browsh web browser (requires Firefox) |
| `ALT+a` | Ask Avante AI assistant (Cursor-like AI coding) |
| `ALT+p` | Kill any floating terminal (restarts on reopen) |
| `Ctrl+q` | Exit terminal mode to normal mode (allows scrolling) |

**Note:**
- Each Neovim instance creates a unique tmux session. The session is automatically killed when Neovim exits, preventing orphaned tmux sessions.
- k9s terminal shows a two-step selection menu (via fzf) on first open: first select cluster, then select namespace (or "all"). Press ESC to cancel selection at either step.
- Codex CLI terminal auto-starts the `codex` command on first open for quick access to OpenAI's Codex assistant.
- **Browsers:**
  - **w3m** (ALT+e to toggle, ALT+s to search): Lightweight, native vim keybindings (j/k/h/l), best for documentation and text-heavy sites
  - **Carbonyl** (ALT+c): Chromium-based, supports modern web (WebGL, video, animations), auto-opens DuckDuckGo
  - **Browsh** (ALT+b): Firefox-based, requires Firefox installation, best rendering of modern sites
- **To kill a terminal with a running app (like k9s):** Press `Ctrl+q` first to exit terminal mode, then press `ALT+p`. Alternatively, quit the app first (e.g., press `q` in k9s), then `ALT+p` works directly.

#### Window & Display
| Shortcut | Action |
|----------|--------|
| `<leader><` | Decrease window width |
| `<leader>>` | Increase window width |
| `<leader>tw` | Toggle word wrap |
| `<leader>mp` | Toggle markdown preview in browser |
| `<leader>.` | Repeat last command |

#### General
| Shortcut | Action |
|----------|--------|
| `<leader>w` | Write (save) |
| `<leader>q` | Quit |
| `<leader>Q` | Quit all |
| `<leader>cd` | Change working directory (fuzzy finder) |

### tmux

**Leader Key:** `Ctrl+F`

#### Pane Management
| Shortcut | Action |
|----------|--------|
| `ALT+v` | Split vertical (no prefix) |
| `ALT+s` | Split horizontal (no prefix) |
| `ALT+x` | Close pane (no prefix) |
| `Ctrl+h/j/k/l` | Navigate panes (no prefix) |
| `Leader+h/j/k/l` | Resize panes |

#### Window Management
| Shortcut | Action |
|----------|--------|
| `Leader+c` | New window |
| `Leader+r` | Rename window |
| `Leader+w` | Window navigator |

#### Copy Mode (Scrolling)
| Shortcut | Action |
|----------|--------|
| `Leader+[` | Enter copy mode |
| `j/k` | Scroll down/up (in copy mode) |
| `Ctrl+d/Ctrl+u` | Page down/up (in copy mode) |
| `g/G` | Top/bottom of scrollback (in copy mode) |
| `/` | Search forward (in copy mode) |
| `q` or `Esc` | Exit copy mode |

### ZSH

#### General Shell
| Shortcut | Action |
|----------|--------|
| `Ctrl+Space` | Accept autosuggestion |
| `Tab` | Show completions / cycle through options |
| `Arrow keys` or `h/j/k/l` | Navigate completion menu |
| `Enter` | Accept selected completion |
| `Esc` | Cancel completion menu |
| `ALT+n` | Launch nvim instantly |
| `ls` | Enhanced tree view (eza) with git-ignore |
| `cd` → `z` | Smart directory jumping (zoxide) |
| `cat` | Enhanced file viewing with syntax highlighting (bat) |
| `find` | Fast file searching (fd) |

#### Vi Mode
| Shortcut | Action |
|----------|--------|
| `ESC` | Enter normal mode (10ms delay) |
| `i` | Enter insert mode |
| `v` | Enter visual mode |

#### FZF (Fuzzy Finder)
| Shortcut | Action |
|----------|--------|
| `Ctrl+T` | Paste selected files/directories onto command line |
| `Ctrl+R` | Search command history (fuzzy) |
| `Alt+C` | cd into selected directory |

#### Git Aliases (Shell)
| Alias | Command |
|-------|---------|
| `lg` | lazygit |
| `gst` | git status |
| `gco` | git checkout |
| `gcb` | git checkout -b |
| `gp` | git push |
| `gpl` | git pull |
| `gcm` | git commit -m |
| `glog` | git log --oneline --graph --decorate --all |

## Configuration Details

### Git Configuration

**Useful Aliases:**
- `git s` - Short status
- `git br` - List branches sorted by last modified
- `git lg` - Commit history with graph
- `git l` - Short log (last 10 commits)
- `git amend` - Amend last commit without editing message
- `git undo` - Undo last commit but keep changes
- `git today` - Show commits from today
- `git pushf` - Push force with lease (safer than --force)
- `git clean-merged` - Delete branches that have been merged

**Modern Defaults:**
- Auto-setup remote tracking on push
- Rebase by default on pull with auto-stash
- Auto-prune deleted remote branches
- Use 'main' as default branch name
- Better diff algorithm (histogram)
- Show moved lines in diffs
- Conflict style with common ancestor (diff3)
- Delta integration for syntax-highlighted diffs with side-by-side view and line numbers

### FZF Configuration

**Managed via `.fzf.zsh` (stowed to `~/.fzf.zsh`)**

**Search Commands:**
- Uses `fd` (fast find alternative) for file searching
- Includes hidden files and follows symlinks
- Excludes .git directories automatically

**Display Options:**
- 40% screen height with reverse layout
- Border around window
- Live preview with `bat` (syntax-highlighted, 500 lines)

**Key Bindings:**
- `Ctrl+T`: Fuzzy find files and paste path
- `Ctrl+R`: Fuzzy search command history
- `Alt+C`: Fuzzy find and cd to directory

**Integration:**
- Works seamlessly with `fd`, `bat`, and `ripgrep`
- Compatible with zsh-vi-mode (keybindings work in vi insert mode)
- Completion and key bindings from homebrew installation
- Custom preview window with syntax highlighting

### Neovim Plugins

**LSP & Language Support:**
- mason-lspconfig (auto-installs: HTML, CSS, TypeScript, Python, Rust, Terraform, Docker, Prisma, Markdown)
- typescript-tools.nvim (root detection via .npmrc)
- pyright (Python LSP)

**Formatting:**
- conform.nvim with prettierd (JS/TS/CSS/HTML), biome, and stylua (Lua)
- Auto-format on save enabled

**Completion:**
- nvim-cmp with Copilot integration
- LSP prioritized over Copilot suggestions
- Signature help enabled

**AI Assistance:**
- avante.nvim (Cursor-like AI coding assistant with Claude integration)
- Keybindings: `ALT+a` to ask, `<leader>aa` to ask, `<leader>ae` to edit selection, `<leader>at` to toggle sidebar
- CopilotChat.nvim for GitHub Copilot integration

**Navigation:**
- smart-splits.nvim (seamless pane navigation with wezterm)
- flash.nvim (quick jumps with `s` and `S`)
- telescope.nvim with fzf extension

**Git:**
- lazygit (via floating terminal with `ALT+h`)
- diffview.nvim for enhanced diff viewing
- gitsigns disabled (using lazygit)

**UI Enhancements:**
- noice.nvim (command line UI)
- nvim-notify (notifications)
- trouble.nvim (diagnostics)
- rainbow-delimiters (bracket colorization)
- catppuccin theme (Mocha flavor, transparent background)
- dressing.nvim (centered input prompts with 60-char width)
- Full transparency support (Telescope, NvimTree, all floating windows)
- Enhanced line numbers (optimized colors for transparent backgrounds)

**Other:**
- nvim-surround (surround text objects)
- grug-far.nvim (search and replace)
- goto-preview (preview definitions)
- todo-comments (highlight TODO/FIXME/etc)
- markdown-preview.nvim (live markdown preview in browser)

### Wezterm Features

- **85% window transparency** (shows desktop wallpaper through all content)
- Smart-splits integration for Ctrl+hjkl navigation between Neovim and Wezterm panes
- Custom tab formatting: tab index, process icon, current directory
- Per-directory unique tab colors (derived from cwd path hash)
- Status bar with hostname, date/time, battery indicator
- Quick launch menu for common tools (Leader+m: k9s, lazygit, lazydocker, btm, htop)
- Catppuccin Mocha theme (background image commented out for transparency)
- Process-aware tab icons (nvim, docker, git, k9s, etc.)
- Diagonal cascade floating terminals for visual distinction

### tmux Configuration

- Dracula theme with custom status bar
- Status bar at top
- Custom left status: pane count
- Custom right status: current directory, current command, PREFIX indicator
- Window zoom indicator
- Catppuccin-inspired colors

### Deprecated

 - `kitty` (replaced by wezterm)
 - `ohmyzsh` (using minimal zsh config)
 - `powerlevel10k` (replaced by starship)

