### Requirements

 - eza
 - stow
 - kitty 
 - neovim
 - nvchad
 - font-hack-nerd-font
 - ripgrep
 - tmux
 - zsh
 - ohmyzsh

### Installation

 - `brew install eza`
 - `brew install stow`
 - `brew install --cask kitty`
 - `brew install zsh`
 - `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
 - `brew install powerlevel10k`
 - `brew install tmux`
 - `brew install nvim`
 - `brew install ripgrep`
 - `brew install --cask font-hack-nerd-font`
 - `rm ~/.zshrc`
 - `git clone https://github.com/christophermanahan/dotfiles`
 - `git clone https://github.com/tmux-plugins/tpm ~/dotfiles/tmux/.config/tmux/plugins/tpm`
 - `cd ~/dotfiles`
 - `stow nvim`
 - `stow tmux`
 - `stow zsh`
 - `stow kitty`
 - `source ~/.zshrc`
 - `tmux`
 - `tmux source ~/.config/tmux/tmux.conf`
 - `e ~/path/to/repo`
