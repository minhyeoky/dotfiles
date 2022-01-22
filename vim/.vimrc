" Name: My vimrc configuration
" Author: Minhyeok Lee
" Email: minhyeok.lee95@gmail.csm

" ------------------------------------------------
" General
" ------------------------------------------------
" Options
lang en_US.UTF-8
set encoding=utf-8 
set fileencoding=utf-8
set number
set relativenumber

 
" Tab options
set expandtab " escape: CTRL+V<Tab>
set tabstop=2
set softtabstop=2
set shiftwidth=2  " when using `>`
set smartindent
set nobackup
set noswapfile
set smartcase
set pastetoggle=<F10>
set cursorline
set colorcolumn=80
set mouse=a
set ve=all                                        
set splitbelow                                    
set splitright                                    
set foldlevel=3
set so=5
set lazyredraw
if !has('nvim')
  set ttymouse=xterm2
endif

filetype plugin indent on
syntax on

let g:mapleader=',' 

" Reload .vimrc
map <leader>sv :source ${MYVIMRC}<CR> 

" Execute current file
map <leader>r :!./%<CR>

map! <C-h> <left>
map! <C-j> <down>
map! <C-k> <up>
map! <C-l> <right>
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>

syntax on
set foldmethod=indent
" Copy to clipboard

autocmd TextChanged,TextChangedI *.md silent write

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')
""""""""""""""""""""""vim-plug""""""""""""""""""""""""""""
function SourceWhenExistsInVimDir(name)
  let l:file_path = $HOME . "/.vim/" . a:name
  if !empty(glob(l:file_path))
    execute "source" l:file_path
  endif
endfunction

call SourceWhenExistsInVimDir(".vimwiki.vim")
call SourceWhenExistsInVimDir(".coc_nvim.vim")

Plug 'preservim/nerdtree'
Plug 'godlygeek/tabular'
Plug 'djoshea/vim-autoread'
Plug 'ferrine/md-img-paste.vim'
Plug 'preservim/tagbar'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'mhinz/vim-startify'
Plug 'airblade/vim-gitgutter'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'junegunn/vim-emoji'
Plug 'wookayin/vim-typora'
Plug 'psf/black', { 'branch': 'stable' }
Plug 'chr4/nginx.vim'
Plug 'Yggdroot/indentLine'
Plug 'preservim/tagbar'
Plug 'edkolev/tmuxline.vim'
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#end()

" Set conceallevel after loading plugins.
set conceallevel=0

set completefunc=emoji#complete
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" --------------------------------------------------
" NerdTree
" --------------------------------------------------
map <C-n> :NERDTreeToggle<CR>

let NERDTreeShowLineNumbers=1
autocmd FileType nerdtree setlocal relativenumber

" Close if the only window is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let NERDTreeIgnore=['\.pyc$', '\~$', '__pycache__'] " ignore files in NERD Tree

" --------------------------------------------------
" vim-typora
" --------------------------------------------------
map <leader>T :Typora<cr>

" --------------------------------------------------
" fzf-vim
" --------------------------------------------------
nnoremap <silent> <leader>ff :Files<CR>
nnoremap <silent> <leader>fb :Buffers<CR>

" --------------------------------------------------
" auto save
" https://stackoverflow.com/questions/17365324/auto-save-in-vim-as-you-type
" --------------------------------------------------
" autocmd TextChanged,TextChangedI *.md silent write

" --------------------------------------------------
" tagbar
" --------------------------------------------------
nmap <C-t> :TagbarToggle<CR>
let g:tagbar_left=1
let g:tagbar_width=50
let g:tagbar_autofocus=1
let g:tagbar_autoclose=1
let g:tagbar_autopreview=0
let g:tagbar_show_linenumbers=1
" let g:tagbar_ctags_bin='/usr/local/bin/ctags'

let g:tagbar_type_json = {
    \ 'ctagstype' : 'json',
    \ 'kinds' : [
      \ 'o:objects',
      \ 'a:arrays',
      \ 'n:numbers',
      \ 's:strings',
      \ 'b:booleans',
      \ 'z:nulls'
    \ ],
  \ 'sro' : '.',
    \ 'scope2kind': {
    \ 'object': 'o',
      \ 'array': 'a',
      \ 'number': 'n',
      \ 'string': 's',
      \ 'boolean': 'b',
      \ 'null': 'z'
    \ },
    \ 'kind2scope': {
    \ 'o': 'object',
      \ 'a': 'array',
      \ 'n': 'number',
      \ 's': 'string',
      \ 'b': 'boolean',
      \ 'z': 'null'
    \ },
    \ 'sort' : 0
    \ }

let g:tagbar_type_markdown = {
    \ 'ctagstype' : 'markdown',
    \ 'kinds' : [
        \ 'h:Heading_L1',
        \ 'i:Heading_L2',
        \ 'k:Heading_L3'
    \ ]
\ }

let g:tagbar_type_vimwiki = {
    \ 'ctagstype' : 'vimwiki',
    \ 'sort': 0,
    \ 'kinds' : [
        \ 'h:Heading_L1',
        \ 'i:Heading_L2',
        \ 'k:Heading_L3'
    \ ]
\ }


" --------------------------------------------------
" Ultisnips
" --------------------------------------------------
let g:UltiSnipsExpandTrigger = '<nop>'
let g:UltiSnipsJumpForwardTrigger = '<c-j>'
let g:UltiSnipsJumpBackwardTrigger = '<c-k>'
let g:UltiSnipsRemoveSelectModeMappings = 0

nnoremap <leader>es :UltiSnipsEdit!<cr>

" --------------------------------------------------
" Black
" --------------------------------------------------
" autocmd BufWritePre *.py silent execute ':Black'


" --------------------------------------------------
" Vim-fugitive
" --------------------------------------------------
nnoremap <leader>gs :tab Git<cr>


