# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

**Paradiddle** is a CLI-first IDE where terminal tools are first-class citizens. Built on NvChad v2.5, it integrates 8 CLI tools as floating terminals with intelligent auto-start behavior, plus 6 fuzzy command search terminals for discovering executables. All keybindings are optimized for left-hand access to work seamlessly with tiling window managers.

Configuration files managed with GNU Stow:
- **nvim**: CLI-first IDE with 14 integrated floating terminals:
  - 8 tool terminals (ALT+a/s/d/f/g/w/e/r) - left-hand optimized
  - 6 command search terminals (ALT+q, ALT+Shift+G/D/A/X/B)
- **zsh**: Shell configuration with vi-mode, autosuggestions, and syntax highlighting
- **starship**: Custom prompt with Catppuccin Mocha theme
- **wezterm**: Terminal emulator with custom tab formatting and smart-splits integration

Deprecated configurations (kitty, tmux, ohmyzsh, powerlevel10k) are retained but no longer maintained.

## Documentation

All technical documentation is organized in the `docs/` directory:

- **[docs/README.md](docs/README.md)** - Documentation index and navigation guide
- **[docs/implementation/](docs/implementation/)** - Technical docs for implemented features
  - [floating-terminal-focus.md](docs/implementation/floating-terminal-focus.md) - Smart terminal switching system
  - [command-creator-log.md](docs/implementation/command-creator-log.md) - Command search development log
- **[docs/architecture/](docs/architecture/)** - Architecture and design plans
  - [architecture.md](docs/architecture/architecture.md) - Core architecture (v1.0)
  - [architecture-enhanced.md](docs/architecture/architecture-enhanced.md) - Enhanced architecture (v2.0)
  - [tiling-window-manager.md](docs/architecture/tiling-window-manager.md) - Future tiling WM vision
  - [rust-ide-plans.md](docs/architecture/rust-ide-plans.md) - Rust rewrite architecture
- **[docs/feature-extension-ideas.md](docs/feature-extension-ideas.md)** - Feature ideas and quick notes

## Setup and Installation

All dependencies are installed via Homebrew. Required packages are listed in README.md:1-15.

To deploy configurations:
```bash
stow <config-name>  # e.g., stow nvim, stow zsh
```

Stow creates symlinks from the repo to home directory following the directory structure inside each config folder.

## Configuration Architecture

### Shell (zsh)

- Single configuration file: `zsh/.zshrc`
- Key customizations:
  - Custom `ls` alias using eza with tree view (L1 depth)
  - zoxide integration for enhanced cd
  - Vi mode with Ctrl+Space for autosuggestion acceptance
  - Starship prompt configured at `~/.config/starship/starship.toml`
  - **Fuzzy Command Search**: Comprehensive command discovery system with fzf integration

**Fuzzy Command Search Keybindings:**
- `Alt+Q`: **Two-stage command builder** - searches commands, then interactively select flags
  - **Stage 1**: Select command (e.g., "docker build", "git commit", "kubectl apply")
  - **Stage 2**: Auto-opens flag picker if flags available (21 flags for docker build, 21 for git commit, 21 for kubectl apply)
  - Example: Type "docker build" → Select flags like `--tag`, `--file`, `--no-cache` → Get `docker build --tag <string> --file <string> --no-cache`
  - Searches ~500+ commands across 13 CLIs (git, docker, kubectl, aws, npm, cargo, terraform, helm, ssh, jq, sed, kill, docker-compose)
  - Auto-updates cache every 7 days
- `Alt+Shift+G`: Filter to Git commands only (git, git-*)
- `Alt+Shift+D`: Filter to Docker/K8s commands (docker, kubectl, k9s, lazydocker)
- `Alt+Shift+A`: Filter to AWS/Cloud commands (aws, e1s, terraform, tf)
- `Alt+Shift+J`: e1s AWS ECS cluster browser with interactive profile/region selection
- `Alt+Shift+X`: Search aliases and custom functions
- `Alt+Shift+B`: Search installed Homebrew packages

**Search features:**
- **Hierarchical search**: Find subcommands (e.g., "git stash pop", "docker container ls")
- Real-time fuzzy filtering as you type
- Preview window showing command-specific help
- `Ctrl+/`: Toggle preview window
- `Enter`: Insert command at cursor (safe, doesn't execute)
- `Ctrl+E`: Execute command immediately
- `Ctrl+U`: Force update command cache
- Works in both shell and Neovim terminal contexts

**Command Cache System:**
- Static database: 13 CLIs with 500+ subcommands (curated)
- Discovery system: Auto-discovers additional commands from installed CLIs
- Custom commands: Add your own via `~/.config/paradiddle/custom.yaml`
- Cache location: `~/.cache/paradiddle/commands.db`
- Helper scripts: `paradiddle-update-commands`, `paradiddle-add-command`

### Neovim

Built on NvChad v2.5 with Lazy.nvim plugin manager.

**Entry point:** `nvim/.config/nvim/init.lua`

**Plugin management:**
- Primary plugins: `nvim/.config/nvim/lua/plugins/init.lua`
- DAP configuration: `nvim/.config/nvim/lua/plugins/dap.lua`
- Custom mappings: `nvim/.config/nvim/lua/mappings.lua`
- Options: `nvim/.config/nvim/lua/options.lua`

**Key integrations:**
- LSP: mason-lspconfig with auto-install for html, cssls, tsserver, vtsls, marksman, dockerls, prismals, rust_analyzer, terraformls
- TypeScript: typescript-tools.nvim (root detection via .npmrc)
- Formatting: conform.nvim with prettierd (JS/TS/CSS/HTML) and stylua (Lua), auto-format on save
- Completion: nvim-cmp with Copilot integration, LSP signature help
- Navigation: smart-splits.nvim for seamless pane navigation with wezterm, flash.nvim for quick jumps
- Git: lazygit (floating terminal via `ALT+f`) with diffview integration (gitsigns disabled)
- Kubernetes: k9s (floating terminal via `ALT+g`) with cluster selection menu on first open
- AI Assistant: avante.nvim (Cursor-like AI coding assistant) with Claude integration
- UI enhancements: noice.nvim, nvim-notify, trouble.nvim, rainbow-delimiters

**Important notes:**
- Leader key: Space (` `)
- Local leader: `,`
- gitsigns explicitly disabled (line 2 of plugins/init.lua)
- Telescope uses fzf extension for performance
- TypeScript servers (tsserver, vtsls) and lua_ls have custom handler logic
- Fuzzy command search available via `Alt+Q` (and variants) opens floating terminals with fzf search

**Floating Terminal Keybindings (Left-Hand Optimized):**

All terminal shortcuts use the left hand for easy access with tiling window managers:

*Home Row (Most Used):*
- `ALT+a`: Claude Code AI assistant
- `ALT+s`: Tmux multiplexer terminal
- `ALT+d`: Lazydocker (Docker TUI)
- `ALT+f`: Lazygit (Git TUI)
- `ALT+g`: k9s (Kubernetes browser)

*Top Row (Secondary Tools):*
- `ALT+e`: e1s (AWS ECS browser)
- `ALT+r`: Posting (HTTP API client)

*Bottom Row:*
- `ALT+x`: OpenAI Codex CLI
- `ALT+z`: Kill/close current floating terminal

*Help:*
- `ALT+Shift+?`: Show terminal shortcuts cheatsheet

*Command Search (Unchanged):*
- `ALT+q`: Search all commands
- `ALT+Shift+G`: Git commands
- `ALT+Shift+D`: Docker/K8s commands
- `ALT+Shift+A`: AWS commands
- `ALT+Shift+X`: Aliases/functions
- `ALT+Shift+B`: Homebrew packages

### Wezterm

**Main config:** `wezterm/.config/wezterm/config.lua`

**Features:**
- Smart-splits integration for Ctrl+hjkl navigation between nvim/wezterm panes
- Custom tab formatting showing: tab index, process icon, current directory
- Per-directory unique tab colors (derived from cwd path)
- Status bar with hostname, date/time, battery
- Leader key: Ctrl+A
- Catppuccin Mocha theme with background image overlay
- Process-aware tab icons (nvim, docker, git, etc.)

**Key bindings:**
- Ctrl+': Split vertical
- Ctrl+b: Split horizontal
- Ctrl+z: Zoom pane
- Ctrl+x or Leader+[: Copy mode
- CMD+w: Close current tab
- Leader+hjkl: Resize panes
- Leader+w: Tab navigator
- Leader+f: Toggle fullscreen

### Starship Prompt

**Config:** `starship/.config/starship/starship.toml`

- Catppuccin Mocha color palette
- Shows directory (truncated to 3 levels), git branch, git status
- Custom directory substitutions (Documents, Downloads, dotfiles with icons)
- Two-line format with character prompt on second line
