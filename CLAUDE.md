# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed with GNU Stow. It contains configuration files for:
- **zsh**: Shell configuration with vi-mode, autosuggestions, and syntax highlighting
- **nvim**: Neovim setup based on NvChad v2.5 with extensive plugin configuration
- **starship**: Custom prompt with Catppuccin Mocha theme
- **wezterm**: Terminal emulator with custom tab formatting and smart-splits integration

Deprecated configurations (kitty, tmux, ohmyzsh, powerlevel10k) are retained but no longer maintained.

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
- Git: lazygit (floating terminal via `<leader>gh`) with diffview integration (gitsigns disabled)
- UI enhancements: noice.nvim, nvim-notify, trouble.nvim, rainbow-delimiters

**Important notes:**
- Leader key: Space (` `)
- Local leader: `,`
- gitsigns explicitly disabled (line 2 of plugins/init.lua)
- Telescope uses fzf extension for performance
- TypeScript servers (tsserver, vtsls) and lua_ls have custom handler logic

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
- Ctrl+x: Copy mode
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
