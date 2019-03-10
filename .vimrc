call plug#begin('~/.vim/plugged')

" General Plugins
Plug 'joshdick/onedark.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'itchyny/lightline.vim'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'junegunn/fzf'

" Language Packs
Plug 'elixir-lang/vim-elixir'
Plug 'hdima/python-syntax'
Plug 'vim-ruby/vim-ruby'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'rust-lang/rust.vim'
Plug 'fatih/vim-go'

call plug#end()

colorscheme onedark
filetype plugin indent on
syntax on
set number
set backspace=2
set laststatus=2
set noshowmode
set splitbelow
set splitright
set list

" Lightline
let g:lightline = {'colorscheme': 'one'}

set rtp+=/usr/local/opt/fzf
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:·

" Keybindings

" window hopping
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" plugins
map ; :FZF<CR>
map <C-P> :NERDTreeToggle<CR>

