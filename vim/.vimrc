" Name: My vimrc configuration
" Author: Minhyeok Lee
" Email: minhyeok.lee95@gmail.csm

" ------------------------------------------------
" General
" ------------------------------------------------
lang en_US.UTF-8
filetype plugin indent on
syntax on

" ------------------------------------------------
" Options
" ------------------------------------------------
set encoding=utf-8 
set fileencoding=utf-8
set number
set relativenumber

" Tab Options
set expandtab " escape: CTRL+V<Tab>
set tabstop=2
set softtabstop=2
set shiftwidth=2  " when using `>`
set smartindent

" Fold Options
set foldlevel=3
set foldmethod=indent

" ETC
set nobackup
set noswapfile
set smartcase
set cursorline
set colorcolumn=80
set mouse=a
set virtualedit=block                                     
set splitbelow                                    
set splitright                                    
set scrolloff=5
set lazyredraw

if !has('nvim')
  set ttymouse=xterm2
endif

" ------------------------------------------------
" Variables
" ------------------------------------------------
let g:mapleader=',' 

" ------------------------------------------------
" Maps
" ------------------------------------------------
" Tab
noremap <leader>tn :tabnew<cr>
noremap <leader>to :tabonly<cr>

" Reload .vimrc
map <silent> <leader>sv :source ${VIMRC}<CR> 

" Switch conceallevel
noremap <Leader>c :let &cole=(&cole == 2) ? 0 : 2 <bar> echo 'conceallevel ' . &cole <CR>

" Execute current file
noremap <leader>r :!./%<CR>

" Move to current buffer directory
noremap <leader>cd :lcd %:h<CR>

" ------------------------------------------------
" vim-plug
"
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
" ------------------------------------------------
function SourceIfExistsInVimDir(name)
  let l:file_path = $HOME . "/.vim/" . a:name
  if !empty(glob(l:file_path))
    execute "source" l:file_path
  endif
endfunction

call plug#begin('~/.vim/plugged')
call SourceIfExistsInVimDir(".vimwiki.vim")
call SourceIfExistsInVimDir(".coc_nvim.vim")

" Search
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Tags
Plug 'preservim/tagbar'

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" File explorer
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" session & start screen
Plug 'mhinz/vim-startify'

" ETC
Plug 'vim-airline/vim-airline'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'ryanoasis/vim-devicons'
call plug#end()

" --------------------------------------------------
" colorscheme
" --------------------------------------------------
let g:dracula_colorterm = 0
colorscheme dracula
highlight VimwikiLink cterm=underline ctermfg=111

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
" fzf-vim
" --------------------------------------------------
nnoremap <silent> <leader>ff :Files<CR>
nnoremap <silent> <leader>fb :Buffers<CR>

let g:fzf_preview_window = ['up:35%', 'ctrl-/']

" --------------------------------------------------
" tagbar
" --------------------------------------------------
nmap <C-t> :TagbarToggle<CR>
let g:tagbar_left=1
let g:tagbar_width=50
let g:tagbar_autopreview=0
let g:tagbar_autofocus=1
let g:tagbar_show_linenumbers=1

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
    \ 'ctagstype': 'markdown',
    \ 'ctagsbin' : '~/scripts/markdown2ctags.py',
    \ 'ctagsargs' : '-f - --sort=yes --sro=»',
    \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro' : '»',
    \ 'kind2scope' : {
        \ 's' : 'section',
    \ },
    \ 'sort': 0,
\ }

let g:tagbar_type_vimwiki = g:tagbar_type_markdown
let g:tagbar_type_vimwiki.ctagstype = 'vimwiki'

" --------------------------------------------------
" Vim-fugitive
" --------------------------------------------------

" Run Git command in the new tab.
noremap <leader>gs :tab Git<cr>


" --------------------------------------------------
" ETC
" --------------------------------------------------
let g:webdevicons_enable_startify = 0
