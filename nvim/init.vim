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
set completeopt=menu,menuone,noselect  " nvim-cmp
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

set wildmode=longest,list,full
set wildmenu
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/android/*
set wildignore+=**/ios/*
set wildignore+=**/.git/*
set wildignore+=**/venv/*
set wildignore+=**/.venv/*

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
map <silent> <leader>sv :source ~/.config/nvim/init.vim<CR>

" Switch conceallevel
noremap <Leader>c :let &cole=(&cole == 2) ? 0 : 2 <bar> echo 'conceallevel ' . &cole <CR>

" Move to current buffer directory
noremap <leader>cd :lcd %:h<CR>

" command! Scratch lua require'tools'.makeScratch()
call plug#begin('~/.vim/plugged')

" ------------------------------------------------
" Plugins
" ------------------------------------------------
function SourceIfExistsInVimDir(name)
  let l:file_path = $HOME . "/.vim/" . a:name
  if !empty(glob(l:file_path))
    execute "source" l:file_path
  endif
endfunction

call SourceIfExistsInVimDir(".vimwiki.vim")

" lsp
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Tags
Plug 'preservim/tagbar'
Plug 'ludovicchabant/vim-gutentags'

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" File explorer
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Session manager
Plug 'mhinz/vim-startify'

" Linter
Plug 'dense-analysis/ale'

" Status bar
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Colorscheme
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'ryanoasis/vim-devicons'

" Language
Plug 'dart-lang/dart-vim-plugin'
Plug 'martinda/Jenkinsfile-vim-syntax'

call plug#end()

" --------------------------------------------------
" colorscheme
" --------------------------------------------------
let g:dracula_colorterm = 0
colorscheme dracula
highlight VimwikiLink cterm=underline ctermfg=111

" --------------------------------------------------
" fzf-vim
" --------------------------------------------------
nnoremap <silent> <leader>ff :Files<CR>
nnoremap <silent> <leader>ft :Tags!<CR>
nnoremap <silent> <leader>fr :Rg!<CR>
nnoremap <silent> <leader>fb :Buffers<CR>

let g:fzf_preview_window = ['right:45%', 'ctrl-/']

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --iglob !.git --iglob !pylint-ignore.md
  \   --hidden --column --line-number --no-heading --color=always --smart-case
  \ -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

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
" tagbar
" --------------------------------------------------
nmap <C-t> :TagbarToggle<CR>
let g:tagbar_left=1
let g:tagbar_width=50
let g:tagbar_autoclose=1
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
    \ 'ctagsbin' : '$HOME/scripts/markdown-to-ctags.py',
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
" ALE
" --------------------------------------------------
let g:ale_fix_on_save = 1
"let g:ale_completion_enabled = 1
"highlight ALEWarning ctermbg=DarkMagenta
"highlight ALEError ctermbg=DarkBlue
let g:ale_disable_lsp = 1
let g:ale_linters = {
      \ 'python': ['pylint', 'pydocstyle'],
      \ }
let g:ale_fixers = {
      \ '*': ['remove_trailing_lines', 'trim_whitespace'],
      \ 'sh': ['shfmt'],
      \ 'typescript': ['eslint'],
      \ 'xml': ['xmllint'],
      \ 'json': ['jq'],
      \ 'python': ['black', 'isort'],
      \ 'dart': ['dart-format'],
      \ }


" --------------------------------------------------
" ETC
" --------------------------------------------------
let g:webdevicons_enable_startify = 0
let g:airline_theme = 'dracula'
let g:airline#extensions#hunks#enabled=0
let g:airline#extensions#branch#enabled=1

" --------------------------------------------------
" Lua
" --------------------------------------------------
lua require'nvim-treesitter.configs'.setup { highlight = { enable = true }, incremental_selection = { enable = true }, textobjects = { enable = true }}
lua require('lsp')
