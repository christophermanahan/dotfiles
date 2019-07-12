call plug#begin('~/.vim/plugged')
Plug 'elixir-editors/vim-elixir'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
call plug#end()

syntax on

set tabstop=2
set shiftwidth=0
set expandtab
set number
set clipboard=unnamed
set backupdir=.backup/,~/.backup/,/tmp//
set directory=.swp/,~/.swp/,/tmp//
set undodir=.undo/,~/.undo/,/tmp//
set timeoutlen=1000 ttimeoutlen=0

let g:ale_elixir_elixir_ls_release = '/Users/christophermanahan/git/elixir-ls/rel'
let mapleader= "\<Space>"
nnoremap <leader>fr :Files <cr>
nnoremap <silent> <leader>* :Rg! <C-R><C-W><CR>
nnoremap <leader>e :Explore <cr>
noremap <leader>/ :Commentary<cr>

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

