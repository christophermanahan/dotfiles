# Dotfiles

Personal development environment configuration using GNU Stow.

## Features

### Core Environment
- **Git**: Enhanced with delta integration for beautiful side-by-side diffs and extensive time-saving aliases
- **Wezterm**: Transparent terminal (85% opacity) with unique per-directory tab colors and seamless Neovim split navigation
- **Neovim**: NvChad v2.5 extended with full transparency, AI assistants, and integrated developer tools
- **ZSH**: Lightning-fast vi-mode (10ms ESC), smart directory jumping (zoxide), and FZF fuzzy finding
- **Starship**: Minimal Catppuccin-themed prompt with git status and directory context
- **tmux**: Floating terminal integration providing isolated shells within Neovim

### Integrated Developer Tools
One-keystroke access to full-screen TUIs without leaving Neovim:
- **lazygit** (Alt+h): Visual Git workflow with staging, commits, rebasing, and branch management
- **lazydocker** (Alt+d): Complete Docker environment control - containers, images, volumes, logs
- **k9s** (Alt+j): Kubernetes cluster management with **interactive cluster and namespace selection via FZF**
- **Claude Code** (Alt+k): AI pair programming assistant in dedicated terminal
- **Codex CLI** (Alt+o): OpenAI-powered code generation and explanation

### Terminal Web Browsers
Research and browse documentation without leaving your terminal:
- **w3m** (Alt+e/Alt+s): Lightweight with **native vim keybindings** (j/k/h/l) and **centered search prompts**
- **Carbonyl** (Alt+c): Full Chromium engine - modern JavaScript, WebGL, video support
- **Browsh** (Alt+b): Firefox-based rendering for visually complex modern websites

### AI Coding Assistants
- **Avante.nvim** (Alt+a): **Cursor-like inline AI** with sidebar chat, code editing, and Claude Sonnet 4.5 integration
- **CopilotChat**: Conversational AI for code explanation, refactoring, and debugging

### Enhanced UX Features
Beyond vanilla NvChad:
- **Full Window Transparency**: Telescope, file trees, floating windows, and status bar all transparent
- **Centered Input Dialogs**: All prompts appear centered on screen (search, file operations, git commits)
- **Fuzzy Directory Changer** (leader+cd): Navigate entire home directory with Telescope from anywhere
- **Optimized for Transparency**: Custom line number colors (bright cyan active line) designed for see-through backgrounds
- **Smart Terminal Management**: Auto-cleanup of background processes, visibility detection for terminal commands

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
**One-keystroke access to developer tools and browsers:**

| Shortcut | Action |
|----------|--------|
| `ALT+h` | lazygit - Visual Git workflow |
| `ALT+d` | lazydocker - Docker container management |
| `ALT+j` | k9s - Kubernetes with FZF cluster/namespace picker |
| `ALT+k` | Claude Code - AI pair programming |
| `ALT+o` | Codex CLI - OpenAI code generation |
| `ALT+i` | tmux - Isolated shell session |
| `ALT+e` | w3m - Lightweight browser with vim keys |
| `ALT+s` | w3m search - Centered DuckDuckGo prompt |
| `ALT+c` | Carbonyl - Full Chromium engine browser |
| `ALT+b` | Browsh - Firefox-based browser |
| `ALT+a` | Avante AI - Cursor-like inline assistant |
| `ALT+p` | Kill terminal - Smart cleanup with process detection |
| `Ctrl+q` | Exit terminal mode - Switch to normal mode for scrolling |

**Smart Features:**
- **FZF Cluster Selection**: k9s prompts for cluster then namespace on first open (ESC to cancel either step)
- **Auto-cleanup**: tmux sessions automatically killed when Neovim exits (no orphaned processes)
- **Centered Search**: w3m search (ALT+s) opens centered dialog, works whether browser is open or closed
- **Process Detection**: ALT+p intelligently detects running apps - press Ctrl+q first if app is active, or quit app then ALT+p
- **Native Vim Keys**: w3m uses j/k/h/l for navigation, perfect for documentation browsing
- **Modern Web Support**: Carbonyl renders JavaScript/WebGL, Browsh gives full Firefox rendering

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
- **Full Transparency**: Telescope, file trees, floating windows all see-through (matches Wezterm)
- **Centered Dialogs**: All input prompts auto-center on screen (dressing.nvim) for focused interaction
- **Transparency-Optimized Colors**: Line numbers with bright cyan active line, visible through transparent background
- noice.nvim (modern command line UI with LSP progress)
- nvim-notify (beautiful notification popups)
- trouble.nvim (diagnostic quickfix with LSP integration)
- rainbow-delimiters (colorized bracket pairs for nested code)
- catppuccin theme (Mocha flavor, customized for transparency)

**Other:**
- nvim-surround (surround text objects)
- grug-far.nvim (search and replace)
- goto-preview (preview definitions)
- todo-comments (highlight TODO/FIXME/etc)
- markdown-preview.nvim (live markdown preview in browser)

### Wezterm Features

Unique terminal experience beyond default Wezterm:
- **Seamless Neovim Integration**: Ctrl+hjkl navigates between Neovim splits AND Wezterm panes (smart-splits)
- **Visual Context at a Glance**: Each directory gets a unique tab color (deterministic from path), instant visual orientation
- **Process-Aware Tabs**: Tab icons automatically change based on running process (nvim 󰈹, docker , git , etc.)
- **Transparency Throughout**: 85% window opacity reveals desktop wallpaper, Catppuccin Mocha theme optimized for see-through design
- **Quick Launch Productivity**: Leader+m instantly opens menu for k9s, lazygit, lazydocker, btm, htop
- **Smart Tab Formatting**: Tab shows index + process + shortened directory path for efficient navigation
- **Diagonal Cascade Pattern**: Floating terminals offset for easy visual distinction and layered appearance

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

