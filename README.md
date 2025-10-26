# Dotfiles

A CLI-first development environment where terminal tools are first-class citizens.

## Philosophy: CLI Tools as First-Class Citizens

This isn't just NvChad with plugins. It's a complete development environment built around the idea that **CLI tools should be instantly accessible** without breaking your flow. Every tool you need—from Kubernetes dashboards to AI assistants to web browsers—is one keystroke away, launching with intelligent defaults and auto-configuration.

### What Makes This Different from Stock NvChad?

**11 Integrated Floating Terminals** with cascading window positions (ALT+k/i/j/h/o/b/d/e/c/1/2):
- Each terminal auto-starts its tool with smart defaults
- Seamless context switching without leaving your editor
- Visual window stacking prevents disorientation
- Kill and restart any terminal instantly (ALT+p)

**Intelligent Auto-Start Behavior:**
- **k9s** prompts for Kubernetes cluster → namespace selection
- **e1s** prompts for AWS profile → region selection (ECS)
- **e2s** launches with interactive AWS instance browser (EC2)
- **Claude Code** and **Codex** CLI ready immediately
- **Browsers** (w3m, Carbonyl, Browsh) open to useful defaults

The result: A development environment where CLI tools aren't separate apps—they're integrated, context-aware, and instantly available.

## Features

- **Neovim**: CLI-first IDE built on NvChad v2.5 with 11 integrated floating terminals
- **Wezterm**: Smart terminal with custom tab formatting, smart-splits integration, and per-directory tab colors
- **ZSH**: Vi-mode, autosuggestions, syntax highlighting, FZF integration, and enhanced directory navigation
- **Git**: Version control with comprehensive aliases and modern defaults
- **Starship**: Custom prompt with Catppuccin Mocha theme

### Integrated CLI Tools (First-Class Citizens)

- **Claude Code** (ALT+k): AI pair programmer with auto-launch
- **Tmux** (ALT+i): Terminal multiplexer with unique session per nvim instance
- **k9s** (ALT+j): Kubernetes manager with cluster/namespace selection
- **Lazygit** (ALT+h): TUI for git operations
- **Codex CLI** (ALT+o): OpenAI assistant with auto-launch
- **Browsh** (ALT+b): Firefox-based terminal browser
- **Lazydocker** (ALT+d): Docker TUI for container management
- **w3m** (ALT+e): Lightweight browser with vim keys + search (ALT+s)
- **Carbonyl** (ALT+c): Chromium-based terminal browser
- **e1s** (ALT+1): AWS ECS cluster browser with profile/region selection
- **e2s** (ALT+2): AWS EC2 instance browser with interactive fzf menus

## Requirements

 - git
 - git-delta (optional but recommended for enhanced diffs)
 - eza
 - zoxide
 - stow
 - wezterm
 - starship
 - neovim
 - font-hack-nerd-font
 - ripgrep
 - tmux
 - k9s
 - lazydocker (Docker TUI)
 - fzf (fuzzy finder)
 - fd (find alternative)
 - bat (cat alternative with syntax highlighting)
 - codex (OpenAI Codex CLI)
 - w3m (lightweight terminal browser with vim keys)
 - carbonyl (Chromium-based terminal browser, via npm)
 - browsh (terminal web browser, requires Firefox)
 - e1s (AWS ECS terminal UI)
 - e2s (AWS EC2 browser, custom-built: https://github.com/christophermanahan/e2s)
 - aws-cli (required for e1s/e2s)
 - zsh
 - zsh-vi-mode
 - zsh-autosuggestions
 - zsh-syntax-highlighting

## Installation

### 1. Install Homebrew dependencies

```bash
brew install eza zoxide stow zsh zsh-vi-mode zsh-autosuggestions zsh-syntax-highlighting starship neovim ripgrep tmux k9s lazydocker git-delta fzf fd bat codex w3m awscli e1s
brew tap browsh-org/homebrew-browsh
brew install browsh
npm install -g carbonyl
brew install --cask font-hack-nerd-font wezterm firefox
```

### 1a. Install e2s (AWS EC2 Browser)

e2s is a custom-built tool for browsing AWS EC2 instances with interactive fzf menus:

```bash
# Clone and install e2s
git clone https://github.com/christophermanahan/e2s.git
cd e2s
chmod +x install.sh
./install.sh
```

This installs the `e2s` binary to `~/.local/bin/e2s` (PATH automatically configured in zsh config).

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

#### Terminal Management (11 Integrated Floating Terminals)

All terminals use cascading window positions (0.02 to 0.12 offset) for visual clarity:

| Shortcut | Tool | Action |
|----------|------|--------|
| `ALT+k` | Claude Code | Toggle AI pair programmer (auto-starts) |
| `ALT+i` | Tmux | Toggle terminal multiplexer (unique session per nvim) |
| `ALT+j` | k9s | Toggle Kubernetes browser (cluster → namespace selection) |
| `ALT+h` | Lazygit | Toggle Git TUI |
| `ALT+o` | Codex | Toggle OpenAI CLI (auto-starts) |
| `ALT+b` | Browsh | Toggle Firefox-based browser |
| `ALT+d` | Lazydocker | Toggle Docker TUI |
| `ALT+e` | w3m | Toggle lightweight browser (vim keys) |
| `ALT+s` | w3m Search | Search DuckDuckGo in w3m |
| `ALT+c` | Carbonyl | Toggle Chromium browser (opens ChatGPT) |
| `ALT+1` | e1s | Toggle AWS ECS browser (profile → region selection) |
| `ALT+2` | e2s | Toggle AWS EC2 browser (interactive instance selector) |
| `ALT+a` | Avante | Ask AI assistant (Cursor-like AI coding) |
| `ALT+p` | Kill Terminal | Kill any floating terminal (restarts on reopen) |
| `Ctrl+q` | Normal Mode | Exit terminal mode (allows scrolling) |

**Intelligent Auto-Start Features:**
- **k9s**: Two-step fzf menu (cluster → namespace or "all")
- **e1s**: Two-step fzf menu (AWS profile → region → ECS clusters)
- **e2s**: Multi-step fzf menu (AWS profile → region → EC2 instance → actions)
- **Claude Code** & **Codex**: Launch immediately on first open
- **Browsers**: w3m opens DuckDuckGo Lite, Carbonyl opens ChatGPT

**Terminal Session Management:**
- Each Neovim instance creates a unique tmux session
- Sessions auto-cleanup on Neovim exit (prevents orphans)
- ALT+p resets all terminal start flags for clean restart
- To kill a running app: Press `Ctrl+q` first, then `ALT+p`

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

#### macOS Clipboard Integration

Seamless integration between Neovim and the macOS system clipboard:

| Shortcut | Mode | Action |
|----------|------|--------|
| `y` | Normal/Visual | Yank to macOS clipboard |
| `yy` | Normal | Yank line to macOS clipboard |
| `CMD+c` | Visual | Copy to macOS clipboard |
| `CMD+v` | Visual | Paste from clipboard & save replaced text to clipboard |

**How CMD+v Works:**
1. Select text you want to replace
2. Press CMD+v
3. Clipboard content pastes over selection
4. Replaced text is saved to clipboard (for swapping content)

**System Clipboard Integration:**
- All yank operations (`y`, `yy`, `yw`, etc.) copy to macOS clipboard
- Paste in any macOS app with CMD+v or Ctrl+v
- Copy from any app, paste in Neovim with `p` or CMD+v
- Enabled via `clipboard=unnamedplus` setting

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

### Neovim Configuration Highlights

**CLI Tool Integration (11 Floating Terminals):**
- Each terminal with auto-start and intelligent defaults
- Cascading window positions (0.02 to 0.12 offset) for visual clarity
- Session management: unique tmux sessions per nvim instance, auto-cleanup on exit
- Seamless context switching without leaving editor
- Tools: Claude Code, Tmux, k9s, Lazygit, Codex, Browsh, Lazydocker, w3m, Carbonyl, e1s (AWS ECS), e2s (AWS EC2)

**macOS System Integration:**
- Full clipboard integration via `clipboard=unnamedplus`
- All yank operations copy to system clipboard
- CMD+c/CMD+v support in visual mode
- CMD+v special behavior: paste & swap (replaced text → clipboard)

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
  - `ALT+a` or `<leader>aa`: Ask AI
  - `<leader>ae`: Edit selection with AI
  - `<leader>at`: Toggle sidebar
  - `<leader>ar`: Refresh
  - `<leader>af`: Focus sidebar
- CopilotChat.nvim for GitHub Copilot integration

**Navigation:**
- smart-splits.nvim (seamless pane navigation with wezterm)
- flash.nvim (quick jumps with `s` and `S`)
- telescope.nvim with fzf extension
- Custom `<leader>cd`: fuzzy directory change with live preview

**Git:**
- lazygit (via floating terminal with `ALT+h`)
- diffview.nvim for enhanced diff viewing
- gitsigns disabled (using lazygit for all git operations)

**UI Enhancements:**
- noice.nvim (command line UI)
- nvim-notify (notifications)
- trouble.nvim (diagnostics)
- rainbow-delimiters (bracket colorization)
- catppuccin theme (Mocha flavor, transparent background)
- Transparent nvim-tree

**Other:**
- nvim-surround (surround text objects)
- grug-far.nvim (search and replace with `<leader>S`)
- goto-preview (preview definitions without jumping)
- todo-comments (highlight TODO/FIXME/etc)
- markdown-preview.nvim (live markdown preview in browser)

### Wezterm Features

- Smart-splits integration for Ctrl+hjkl navigation
- Custom tab formatting: tab index, process icon, current directory
- Per-directory unique tab colors (derived from cwd path)
- Status bar with hostname, date/time, battery
- Quick launch menu for common tools (Leader+m)
- Catppuccin Mocha theme with background image overlay
- Process-aware tab icons (nvim, docker, git, etc.)

### tmux Configuration

- Dracula theme with custom status bar
- Status bar at top
- Custom left status: pane count
- Custom right status: current directory, current command, PREFIX indicator
- Window zoom indicator
- Catppuccin-inspired colors

## Workflow Philosophy

### Why CLI Tools as First-Class Citizens?

Traditional IDEs hide terminal tools in sidebars or require context switching to separate windows. This development environment takes a different approach:

**Instant Access:** Every tool is one keystroke away (ALT+key), not buried in menus.

**Smart Defaults:** Tools auto-start with intelligent configuration:
- k9s knows to ask which cluster/namespace
- e1s/e2s prompt for AWS profile/region
- Browsers open to useful defaults
- No repetitive setup on each launch

**Visual Clarity:** 11 cascading windows (0.02–0.12 offset) prevent disorientation when toggling between tools.

**Seamless Integration:**
- Copy from Neovim → paste anywhere on macOS
- Navigate between editor and terminal panes with the same keys
- All context stays within one application

**Zero Cleanup:** Terminal sessions auto-cleanup when you exit Neovim. No orphaned processes.

### Example Workflows

**Kubernetes Development:**
1. Write code in Neovim
2. `ALT+j` → select cluster/namespace → check pod status in k9s
3. `ALT+h` → commit changes in lazygit
4. `ALT+p` → kill terminals when done

**AWS Infrastructure Work:**
1. `ALT+1` → select AWS profile/region → browse ECS clusters in e1s
2. `ALT+2` → browse EC2 instances in e2s
3. `ALT+k` → ask Claude Code about infrastructure code
4. Never leave your editor

**Research & Documentation:**
1. Select unfamiliar function in code
2. `ALT+e` → look up documentation in w3m
3. `ALT+s` → search for more details
4. Yank example code → paste directly into editor
5. `ALT+p` → close browser when done

**The Result:** A development environment where context switching is measured in milliseconds, not seconds. Where terminals are not separate apps, but integrated tools at your fingertips.

### Deprecated

 - `kitty` (replaced by wezterm)
 - `ohmyzsh` (using minimal zsh config)
 - `powerlevel10k` (replaced by starship)

