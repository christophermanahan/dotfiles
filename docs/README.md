# Paradiddle Documentation

Welcome to the Paradiddle documentation! This directory contains all technical documentation, architecture plans, implementation notes, and development logs.

## Quick Start

- **New to Paradiddle?** Start with the [main README](../README.md) in the project root
- **Setting up for development?** See [CLAUDE.md](../CLAUDE.md) for AI-assisted development instructions
- **Understanding the terminal system?** Check out [Floating Terminal Focus](implementation/floating-terminal-focus.md)

## Documentation Structure

### Implementation Guides

Technical documentation for features that are currently implemented in Paradiddle.

| Document | Description |
|----------|-------------|
| [Floating Terminal Focus](implementation/floating-terminal-focus.md) | How the smart terminal switching system works - manages stacked floating terminals with intelligent focus and reveal behavior |
| [Command Creator Log](implementation/command-creator-log.md) | Development log tracking the command search system, tmux scrolling fixes, and keybinding evolution |

**Key Topics:**
- **Terminal Management**: How `prepare_toggle()` handles 4 cases (open, close, reveal, normal)
- **Buffer Tracking**: Why buffer persistence is critical for terminal state
- **CTRL+q Scrolling**: Tmux-aware scrolling with copy mode integration
- **Keybinding Conflicts**: Resolution of ALT+key conflicts with tmux and wezterm

### Architecture & Planning

Forward-looking architecture documents and design plans for future development.

| Document | Description |
|----------|-------------|
| [Tiling Window Manager](architecture/tiling-window-manager.md) | Vision for integrated tiling WM with i3/sway-inspired layouts, workspaces, and aesthetic design inspired by Omarchy |
| [Rust IDE Plans](architecture/rust-ide-plans.md) | Architecture context for potential Rust-based CLI IDE rewrite with LLM integration, security-by-design, and shared context layer |

**Key Concepts:**
- **Tiling Layouts**: hsplit, vsplit, tabbed, stacked, floating
- **Window Abstraction**: Treating buffers, terminals, and tools as unified windows
- **Multi-Context Workspaces**: Virtual desktops for diverse project setups
- **Shared LLM Context**: Persistent AI context across all tools
- **Security Architecture**: STRIDE analysis, zero-trust, secret redaction

### Notes

| Document | Description |
|----------|-------------|
| [Feature Ideas](notes.md) | Quick notes and feature ideas for future development |

## Current Implementation Status

**Paradiddle v2.5** (NvChad-based)
- ✅ 8 integrated CLI tool terminals with left-hand keybindings
- ✅ 6 fuzzy command search terminals
- ✅ Smart terminal focus management with stacking
- ✅ Auto-start behavior for all tools
- ✅ Shortcuts cheatsheet (ALT+Shift+?)
- ✅ Catppuccin Mocha theme throughout

**Terminal Keybindings:**
- Home Row: ALT+a/s/d/f/g (Claude, Tmux, Lazydocker, Lazygit, k9s)
- Top Row: ALT+e/r (e1s, Posting)
- Bottom Row: ALT+x/z (OpenAI, Kill)
- Command Search: ALT+q, ALT+Shift+G/D/A/X/B

## Key Technologies

- **Base**: NvChad v2.5 + Neovim
- **Shell**: zsh with vi-mode, starship prompt
- **Terminal**: wezterm with smart-splits integration
- **Tools**: lazygit, k9s, lazydocker, posting, e1s, tmux
- **Command Search**: fzf with 500+ hierarchical commands

## Contributing to Documentation

When adding new documentation:

1. **Implementation docs** → `implementation/` - For features that exist in the codebase
2. **Architecture docs** → `architecture/` - For design plans and future visions
3. **Quick notes** → `notes.md` - For ideas and TODOs
4. **Update this README** - Add your document to the appropriate table above

## Related Files

- [`../CLAUDE.md`](../CLAUDE.md) - Instructions for Claude Code AI assistant
- [`../README.md`](../README.md) - User-facing project README
- [`../nvim/.config/nvim/lua/mappings.lua`](../nvim/.config/nvim/lua/mappings.lua) - Core keybinding implementations
