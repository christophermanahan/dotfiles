# Paradiddle

A CLI-first development environment where terminal tools are first-class citizens.

## Why "Paradiddle"?

A **paradiddle** is a fundamental drumming rudiment—a rhythmic pattern (RLRR LRLL) that drummers practice until it becomes second nature. The name captures the essence of this development environment:

- **Rhythm and Flow**: Like a drum pattern, working with CLI tools should feel natural and rhythmic
- **Muscle Memory**: The keybindings (ALT+k, ALT+i, ALT+j...) become instinctive through repetition
- **Alternating Patterns**: Seamlessly switching between tools mirrors the alternating hand pattern of a paradiddle
- **Foundation for Complexity**: Master the basics (terminal integration) to enable advanced workflows

Just as drummers build speed and creativity on fundamental rudiments, developers achieve flow state through well-integrated CLI tools.

## Philosophy: CLI Tools as First-Class Citizens

This isn't just NvChad with plugins. It's a complete development environment built around the idea that **CLI tools should be instantly accessible** without breaking your flow. Every tool you need—from Kubernetes dashboards to AI assistants to web browsers—is one keystroke away, launching with intelligent defaults and auto-configuration.

### What Makes This Different from Stock NvChad?

**8 Integrated Floating Terminals** with left-hand optimized keybindings (ALT+a/s/d/f/g/e/r/x):
- Each terminal auto-starts its tool with smart defaults
- Seamless context switching without leaving your editor
- Visual window stacking with diagonal offsets prevents disorientation
- Kill currently focused terminal instantly (ALT+z)

**Intelligent Auto-Start Behavior:**
- **k9s** prompts for Kubernetes cluster → namespace selection
- **e1s** prompts for AWS profile → region selection (ECS)
- **Claude Code** offers to continue previous session or start fresh
- **Codex** and **Posting** CLI ready immediately
- **tmux** creates unique session per nvim instance

The result: A development environment where CLI tools aren't separate apps—they're integrated, context-aware, and instantly available.

## Features

- **Neovim**: CLI-first IDE built on NvChad v2.5 with 8 integrated floating terminals
- **AeroSpace**: Tiling window manager for macOS with i3-inspired keybindings
- **SketchyBar**: Custom macOS menu bar with Aerospace workspace integration
- **Alfred**: Productivity app with custom preferences and workflows
- **Wezterm**: Smart terminal with custom tab formatting, smart-splits integration, and per-directory tab colors
- **ZSH**: Vi-mode, autosuggestions, syntax highlighting, FZF integration, and secure secrets management
- **Git**: Version control with comprehensive aliases and modern defaults
- **Starship**: Custom prompt with Catppuccin Mocha theme

### Integrated CLI Tools (First-Class Citizens)

**Left-Hand Optimized Keybindings:**
- **Claude Code** (ALT+a): AI pair programmer with session continuation prompt
- **Tmux** (ALT+s): Terminal multiplexer with unique session per nvim instance
- **Lazydocker** (ALT+d): Docker TUI for container management
- **Lazygit** (ALT+f): TUI for git operations
- **k9s** (ALT+g): Kubernetes manager with cluster/namespace selection
- **e1s** (ALT+e): AWS ECS cluster browser with profile/region selection
- **Posting** (ALT+r): HTTP API client (Postman/Insomnia alternative)
- **OpenAI Codex** (ALT+x): OpenAI assistant with auto-launch

## Requirements

 - git
 - git-delta (optional but recommended for enhanced diffs)
 - eza
 - zoxide
 - stow
 - aerospace (tiling window manager)
 - sketchybar (custom menu bar)
 - alfred (productivity app with Powerpack)
 - wezterm
 - starship
 - neovim
 - font-hack-nerd-font
 - ripgrep
 - tmux
 - k9s
 - lazygit (Git TUI)
 - lazydocker (Docker TUI)
 - fzf (fuzzy finder)
 - fd (find alternative)
 - bat (cat alternative with syntax highlighting)
 - claude (Claude Code CLI - installed via npm)
 - codex (OpenAI Codex CLI)
 - posting (HTTP API client TUI)
 - e1s (AWS ECS terminal UI)
 - aws-cli (required for e1s)
 - zsh
 - zsh-vi-mode
 - zsh-autosuggestions
 - zsh-syntax-highlighting

## Installation

### 1. Install Homebrew dependencies

```bash
brew install eza zoxide stow zsh zsh-vi-mode zsh-autosuggestions zsh-syntax-highlighting starship neovim ripgrep tmux k9s lazygit lazydocker git-delta fzf fd bat codex posting awscli e1s
brew install --cask font-hack-nerd-font wezterm nikitabobko/tap/aerospace alfred
brew install sketchybar

# Install Claude Code CLI via npm
npm install -g @anthropic-ai/claude-code
```

### 2. Clone repository

```bash
git clone https://github.com/christophermanahan/paradiddle.git ~/paradiddle
cd ~/paradiddle
```

### 3. Deploy configurations with Stow

```bash
# Remove existing configs if present
rm -f ~/.zshrc

# Stow configurations (creates symlinks from repo to home directory)
stow git        # Deploys to ~/.gitconfig
stow aerospace  # Tiling window manager
stow sketchybar # Menu bar customization
stow wezterm
stow zsh
stow starship
stow nvim
stow tmux
stow k9s        # Cross-platform: deploys to ~/.config/k9s/ (K9S_CONFIG_DIR enforces XDG)

# Alfred uses native sync (not stow) - see alfred/README.md
# Open Alfred Preferences → Advanced → Set preferences folder to ~/paradiddle/alfred/Alfred.alfredpreferences
```

### 4. Set up secrets (API keys)

For AI-powered tools like Avante (Claude) and OpenAI Codex, you'll need API keys:

```bash
# Copy the secrets template to your home directory
cp zsh/.zshrc.secrets.template ~/.zshrc.secrets
chmod 600 ~/.zshrc.secrets

# Edit the file and add your actual API keys
vim ~/.zshrc.secrets
# Replace placeholder with: export ANTHROPIC_API_KEY="sk-ant-your-key-here"
```

**Get your API keys:**
- Anthropic Claude: https://console.anthropic.com/
- OpenAI: https://platform.openai.com/api-keys

**Security Note:** The `~/.zshrc.secrets` file is gitignored and will never be committed to version control.

### 5. Reload shell configuration

```bash
source ~/.zshrc
```

### 6. Launch Neovim to install plugins

On first launch, Neovim will automatically:
- Install NvChad (v2.5)
- Install all plugins via Lazy.nvim
- Install LSP servers via Mason (HTML, CSS, TypeScript, Python, Rust, Terraform, Docker, Prisma, Markdown)

```bash
nvim
```

Wait for all installations to complete, then restart Neovim.

## Getting Started

Once you've installed Paradiddle, here's a quick workflow to get you coding:

1. **Open Wezterm** - Your terminal will auto-launch Neovim
2. **Navigate to a project** - Press `<leader>cd` (Space+cd) to fuzzy find and jump to any directory
3. **Browse files** - Press `Ctrl+n` to open the file tree
4. **Find code** - Press `<leader>fw` to fuzzy search for function calls or any text
5. **Get AI help** - Press `ALT+a` to open Claude Code for pair programming
6. **Context-aware assistance** - Highlight some code and press `<leader>aa` to bring up Avante (Cursor-like AI with Claude Sonnet 4)
7. **Happy coding!** - All your CLI tools are one keystroke away (ALT+f for git, ALT+g for k8s, ALT+s for tmux, etc.)

**Pro tip:** Use `ALT+z` to kill the currently focused floating terminal, then press the same shortcut again to restart it fresh.

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

#### Terminal Management (8 Integrated Floating Terminals)

**Left-Hand Optimized Layout** - All terminals use left-hand keys for seamless use with tiling window managers:

**Home Row (Most Used):**
| Shortcut | Tool | Action |
|----------|------|--------|
| `ALT+a` | Claude Code | Toggle AI pair programmer (offers session continuation) |
| `ALT+s` | Tmux | Toggle terminal multiplexer (unique session per nvim) |
| `ALT+d` | Lazydocker | Toggle Docker TUI |
| `ALT+f` | Lazygit | Toggle Git TUI |
| `ALT+g` | k9s | Toggle Kubernetes browser (cluster → namespace selection) |

**Top Row (Secondary Tools):**
| Shortcut | Tool | Action |
|----------|------|--------|
| `ALT+e` | e1s | Toggle AWS ECS browser (profile → region selection) |
| `ALT+r` | Posting | Toggle HTTP API client (Postman alternative) |

**Bottom Row:**
| Shortcut | Tool | Action |
|----------|------|--------|
| `ALT+x` | OpenAI Codex | Toggle OpenAI CLI (auto-starts) |
| `ALT+z` | Kill Terminal | Kill currently focused floating terminal |

**Command Search:**
| Shortcut | Action |
|----------|--------|
| `ALT+q` | Search all commands (~500 commands) |
| `ALT+Shift+G` | Filter to Git commands |
| `ALT+Shift+D` | Filter to Docker/K8s commands |
| `ALT+Shift+A` | Filter to AWS commands |
| `ALT+Shift+X` | Search aliases/functions |
| `ALT+Shift+B` | Search Homebrew packages |

**Other:**
| Shortcut | Action |
|----------|--------|
| `ALT+Shift+?` | Show terminal shortcuts cheatsheet |
| `Ctrl+q` | Exit terminal mode (allows scrolling) |

**Intelligent Auto-Start Features:**
- **Claude Code**: Prompts to continue previous session or start fresh
- **k9s**: Two-step fzf menu (cluster → namespace or "all")
- **e1s**: Two-step fzf menu (AWS profile → region → ECS clusters)
- **Codex** & **Posting**: Launch immediately on first open
- **tmux**: Creates unique session per nvim instance

**Terminal Session Management:**
- Each Neovim instance creates a unique tmux session
- Sessions auto-cleanup on Neovim exit (prevents orphans)
- All terminals have diagonal stacking offsets for visual clarity
- To kill a running app: Press `Ctrl+q` first, then `ALT+z`

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

**CLI Tool Integration (8 Floating Terminals):**
- Left-hand optimized keybindings (ALT+a/s/d/f/g/e/r/x)
- Each terminal with auto-start and intelligent defaults
- Diagonal stacking offsets for visual clarity
- Session management: unique tmux sessions per nvim instance, auto-cleanup on exit
- Seamless context switching without leaving editor
- Tools: Claude Code, Tmux, Lazydocker, Lazygit, k9s, e1s (AWS ECS), Posting (HTTP client), OpenAI Codex

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
- avante.nvim (Cursor-like AI coding assistant with **Claude Sonnet 4** integration)
  - `<leader>aa`: Ask AI about selected code
  - `<leader>ae`: Edit selection with AI
  - `<leader>at`: Toggle sidebar
  - `<leader>ar`: Refresh
  - `<leader>af`: Focus sidebar
  - Requires `ANTHROPIC_API_KEY` in `~/.zshrc.secrets`
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

**Visual Clarity:** 8 terminals with diagonal stacking offsets prevent disorientation when toggling between tools.

**Seamless Integration:**
- Copy from Neovim → paste anywhere on macOS
- Navigate between editor and terminal panes with the same keys
- All context stays within one application

**Zero Cleanup:** Terminal sessions auto-cleanup when you exit Neovim. No orphaned processes.

### Example Workflows

**Kubernetes Development:**
1. Write code in Neovim
2. `ALT+g` → select cluster/namespace → check pod status in k9s
3. `ALT+f` → commit changes in lazygit
4. `ALT+z` → close terminals when done

**AWS Infrastructure Work:**
1. `ALT+e` → select AWS profile/region → browse ECS clusters in e1s
2. `ALT+a` → ask Claude Code about infrastructure code
3. Select code → `<leader>aa` → get AI suggestions with Avante
4. Never leave your editor

**API Testing:**
1. Write API endpoint code
2. `ALT+r` → open Posting HTTP client
3. Test requests interactively with TUI
4. Copy response → paste into code
5. `ALT+z` → close when done

**The Result:** A development environment where context switching is measured in milliseconds, not seconds. Where terminals are not separate apps, but integrated tools at your fingertips.

### Deprecated

 - `kitty` (replaced by wezterm)
 - `ohmyzsh` (using minimal zsh config)
 - `powerlevel10k` (replaced by starship)

