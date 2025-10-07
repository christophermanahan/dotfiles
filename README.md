# Requirements

 - eza
 - zoxide
 - stow
 - wezterm
 - starship
 - neovim
 - nvchad
 - font-hack-nerd-font
 - ripgrep
 - zsh
 - zsh-vi-mode
 - zsh-autosuggestions
 - zsh-syntax-highlighting


## Installation

 - `brew install eza`
 - `brew install zoxide`
 - `brew install stow`
 - `brew install --cask font-hack-nerd-font`
 - `brew install --cask wezterm`
 - `brew install zsh`
 - `brew install zsh-vi-mode`
 - `brew install zsh-autosuggestions`
 - `brew install zsh-syntax-highlighting`
 - `brew install starship`
 - `brew install nvim`
 - `brew install ripgrep`
 - `rm ~/.zshrc`
 - `git clone https://github.com/christophermanahan/dotfiles`
 - `cd ~/dotfiles`
 - `stow wezterm`
 - `stow zsh`
 - `stow starship`
 - `stow nvim`
 - `source ~/.zshrc`

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

