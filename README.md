# Dotfiles

Personal development environment configuration using GNU Stow.

## Screenshots

### Wezterm with Split Terminals
![Wezterm Split Terminal](screenshots/wezterm-split-terminal-env.png)

### Neovim with Split Editor
![Neovim Split Editor](screenshots/nvim-split-editor.png)

### Neovim with Ripgrep Search
![Neovim Ripgrep Example](screenshots/nvim-ripgrep-example.png)

## Requirements

 - eza
 - zoxide
 - stow
 - wezterm
 - starship
 - neovim
 - font-hack-nerd-font
 - ripgrep
 - zsh
 - zsh-vi-mode
 - zsh-autosuggestions
 - zsh-syntax-highlighting

## Installation

### 1. Install Homebrew dependencies

```bash
brew install eza zoxide stow zsh zsh-vi-mode zsh-autosuggestions zsh-syntax-highlighting starship neovim ripgrep
brew install --cask font-hack-nerd-font wezterm
```

### 2. Clone dotfiles repository

```bash
git clone https://github.com/christophermanahan/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Deploy configurations with Stow

```bash
# Remove existing zsh config if present
rm -f ~/.zshrc

# Stow configurations (creates symlinks)
stow wezterm
stow zsh
stow starship
stow nvim
```

### 4. Reload shell configuration

```bash
source ~/.zshrc
```

### 5. Launch Neovim to install plugins

On first launch, Neovim will automatically:
- Install NvChad (v2.5)
- Install all plugins via Lazy.nvim
- Install LSP servers via Mason

```bash
nvim
```

Wait for all installations to complete, then restart Neovim.

## Shortcuts

### Wezterm

**Leader Key:** `Ctrl+A`

| Shortcut | Action |
|----------|--------|
| `Ctrl+'` | Split vertical |
| `Ctrl+b` | Split horizontal |
| `Ctrl+h/j/k/l` | Navigate between panes (nvim/wezterm) |
| `Ctrl+z` | Zoom pane |
| `Ctrl+x` | Copy mode |
| `CMD+w` | Close current tab |
| `Leader+h/j/k/l` | Resize panes |
| `Leader+w` | Tab navigator |
| `Leader+f` | Toggle fullscreen |

### Neovim

**Leader Key:** `Space`

#### File Navigation
| Shortcut | Action |
|----------|--------|
| `<leader>e` | Focus current file in tree |
| `Ctrl+h/j/k/l` | Navigate between splits |
| `s` + motion | Flash jump (quick navigation) |

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

#### Git
| Shortcut | Action |
|----------|--------|
| `<leader>gh` | Open Neogit |

#### General
| Shortcut | Action |
|----------|--------|
| `<leader>w` | Write (save) |
| `<leader>q` | Quit |
| `<leader>Q` | Quit all |

### ZSH

| Shortcut | Action |
|----------|--------|
| `Ctrl+Space` | Accept autosuggestion |
| `ls` | Enhanced tree view (eza) with git-ignore |
| `cd` → `z` | Smart directory jumping (zoxide) |

### Deprecated

 - `kitty`
 - `tmux`
 - `ohmyzsh`
 - `powerlevel10k`

