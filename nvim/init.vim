" Name: My vimrc configuration
" Author: Minhyeok Lee
" Email: minhyeok.lee95@gmail.csm

" ------------------------------------------------
" General
" ------------------------------------------------
filetype plugin indent on
syntax on
let g:mapleader=','
let g:python3_host_prog = '/usr/bin/python3'

autocmd FileType help,man setlocal relativenumber

autocmd FileType markdown nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>
autocmd TextChanged,TextChangedI *.md silent write

" jq formatter compatible
autocmd FileType json set foldmethod=indent
autocmd FileType mermaid set foldmethod=indent
autocmd FileType dart set foldmethod=indent
autocmd FileType markdown set foldlevel=1
autocmd FileType markdown set shiftwidth=2

function ZkAutoCommit()
  let date = system("date")
  let path = expand('%:p:h')
  if path =~ "^" . $ZK_NOTEBOOK_DIR
    call system("cd " . $ZK_NOTEBOOK_DIR . " && git add " . expand('%:p') . " && git commit -m " . shellescape(date))
  endif
endfunction

autocmd BufWritePost *.md :call ZkAutoCommit()

autocmd BufRead .localrc set filetype=bash

" ------------------------------------------------
" Options
" ------------------------------------------------
set completeopt=menu,menuone,noselect  " nvim-cmp
set encoding=utf-8
set fileencoding=utf-8
set number
set relativenumber
set concealcursor=nc

" Tab Options
set expandtab " escape: CTRL+V<Tab>
set tabstop=2
set softtabstop=2
set shiftwidth=2  " when using `>`
set smartindent
set termguicolors

" Fold Options
set foldlevel=2
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
" Force re-compute folds because i'm using nvim_treesitter#foldexpr as primary foldmethod for markdown.
"autocmd InsertLeave *.md normal zx

" ETC
set nobackup
set noswapfile
set ignorecase smartcase
set cursorline
set colorcolumn=120
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
" Maps
" ------------------------------------------------
" Tab
noremap <leader>tn :tabnew<cr>
noremap <leader>to :tabonly<cr>

" Moving Lines: https://vimtricks.com/p/vimtrick-moving-lines/
" Ctrl + J or K
nnoremap <c-j> :m .+1<CR>==
nnoremap <c-k> :m .-2<CR>==
inoremap <c-j> <Esc>:m .+1<CR>==gi
inoremap <c-k> <Esc>:m .-2<CR>==gi
vnoremap <c-j> :m '>+1<CR>gv=gv
vnoremap <c-k> :m '<-2<CR>gv=gv

" Use Snippets instead. (UltiSnips, etc)
noremap <leader>mt :r!echo "\#\# \c" && date "+\%Y-\%m-\%d (\%a)"<CR>
noremap <leader>mr :r!echo "\#\# References"<CR>


" Reload .vimrc
map <silent> <leader>sc :lua unload_packages()<CR>
map <silent> <leader>sv :source ~/.config/nvim/init.vim<CR>

" Switch conceallevel
noremap <Leader>c :let &cole=(&cole == 2) ? 0 : 2 <bar> echo 'conceallevel ' . &cole <CR>

" Move to current buffer directory
noremap <leader>cd :tcd %:h<CR>

vnoremap <C-C> "*y

" Terminal
tnoremap <c-w> <c-\><c-n>

" command! Scratch lua require'tools'.makeScratch()
call plug#begin('~/.vim/plugged')
" ------------------------------------------------
" Plugins
" ------------------------------------------------
" Session & Startup
Plug 'mhinz/vim-startify'
Plug 'ferrine/md-img-paste.vim'
let g:mdip_imgdir = 'img'

" Utilities
Plug 'nvim-lua/plenary.nvim'
Plug 'djoshea/vim-autoread'

" lsp
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'onsails/lspkind-nvim'

Plug 'github/copilot.vim'
let g:copilot_enabled = 1

" snippet
Plug 'SirVer/ultisnips'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'

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
Plug 'lewis6991/gitsigns.nvim'
" File explorer

Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Session manager
Plug 'mhinz/vim-startify'

" Linter
Plug 'jose-elias-alvarez/null-ls.nvim'
Plug 'ThePrimeagen/refactoring.nvim'

" Status bar
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'

" Colorscheme
Plug 'ryanoasis/vim-devicons'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
Plug 'chrisbra/Colorizer'

" Language
Plug 'dart-lang/dart-vim-plugin'
Plug 'martinda/Jenkinsfile-vim-syntax'

" Flutter
Plug 'akinsho/flutter-tools.nvim'

Plug 'tpope/vim-commentary'
Plug 'ap/vim-css-color'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'

" Markdown Preview
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install ' }

let g:markdown_fenced_languages = ['mermaid']
let g:mkdp_theme = 'light'
let g:mkdp_auto_close = 0
let g:mkdp_preview_options = {
    \ 'maid': {'theme': 'base'},
    \ 'disable_sync_scroll': 1,
    \ }

" Note
Plug 'mickael-menu/zk-nvim'
Plug 'AndrewRadev/inline_edit.vim'
Plug 'jkramer/vim-checkbox'
Plug 'mracos/mermaid.vim'
Plug 'aklt/plantuml-syntax'
Plug 'junegunn/vim-emoji'
Plug 'lukas-reineke/headlines.nvim'
nnoremap <silent> <space> :call checkbox#ToggleCB()<cr>

" Quickfix & Loclist
Plug 'folke/trouble.nvim'

call plug#end()
set completefunc=emoji#complete

fun! <SID>Sub_movend(lineno)
	if (match(getline(a:lineno), ':\([^:]\+\):') != -1) " There is a match
		exe a:lineno . 'su /:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/g'
		star!
	endif
endfun

autocmd! CompleteDone * call <SID>Sub_movend(line('.'))

" --------------------------------------------------
" fzf-vim
" --------------------------------------------------
let g:fzf_preview_window = ['right:45%', 'ctrl-/']

nnoremap <silent> <leader>ff :Files!<CR>
nnoremap <silent> <leader>ft :Tags!<CR>
nnoremap <silent> <leader>fr :Rg!<CR>
nnoremap <silent> <leader>fb :Buffers!<CR>

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --iglob !.git --iglob !pylint-ignore.md --iglob !elasticsearch-HQ
  \   --hidden --column --line-number --no-heading --color=always --smart-case
  \ -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

command! -bang DotFiles
  \ call fzf#vim#files(
  \ $DOTFILES_PATH,
  \ <bang>0
  \)

command! -bang -nargs=* DotSearch
  \ call fzf#vim#grep(
  \ 'rg --column --line-number --no-heading --color=always --smart-case -- '. shellescape(<q-args>),
  \ 1,
  \ fzf#vim#with_preview({'dir': $DOTFILES_PATH}),
  \ <bang>0
  \)

command! -bang -nargs=* ZkGrep
  \ call fzf#vim#grep(
  \ 'rg --column --line-number --no-heading --color=always --smart-case -- '. shellescape(<q-args>),
  \ 1,
  \ fzf#vim#with_preview({'dir': $ZK_NOTEBOOK_DIR}),
  \ <bang>0
  \)

nmap <Leader>dr :DotSearch!<CR>
nmap <Leader>df :DotFiles!<CR>
nmap <Leader>zr :ZkGrep!<CR>

command! -bang Todo
  \ call fzf#vim#grep(
  \ 'rg --column --line-number --no-heading --color=always --smart-case -e ' . shellescape('^[ ]*\- \[ \]'),
  \ 1,
  \ fzf#vim#with_preview({'dir': $ZK_NOTEBOOK_DIR}),
  \ <bang>0
  \)
nmap <leader>td :Todo<cr>
nmap <leader>tD :Todo!<cr>

" --------------------------------------------------
" NerdTree
" --------------------------------------------------
map <C-n> :NERDTreeToggle<CR>

let NERDTreeShowLineNumbers=1
autocmd FileType nerdtree setlocal relativenumber

" Close if the only window is a NERDTree
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
    \ 'ctagsbin' : '$DOTFILES_PATH/scripts/markdown-to-ctags.py',
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

" --------------------------------------------------
" Vim-fugitive
" --------------------------------------------------

" Run Git command in the new tab.
noremap <leader>gs :Git<cr>
noremap <leader>gS :tab Git<cr>

" Set foldmethod for git
autocmd FileType gitcommit,git set foldmethod=syntax
autocmd FileType gitcommit,git set foldlevel=0

" --------------------------------------------------
" ultisnips
" --------------------------------------------------
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" --------------------------------------------------
" ETC
" --------------------------------------------------
let g:webdevicons_enable_startify = 0

lua << EOF
function _G.unload_packages()
  for name,_ in pairs(package.loaded) do
    if name:match('^core') or name:match('^lsp') or name:match('^plugins') then
      package.loaded[name] = nil
    end
  end
end
EOF


" --------------------------------------------------
" [Vim Tip: Paste Markdown Link with Automatic Title Fetching | Ben Congdon](https://benjamincongdon.me/blog/2020/06/27/Vim-Tip-Paste-Markdown-Link-with-Automatic-Title-Fetching/)
" --------------------------------------------------
function GetURLTitle(url)
    " Bail early if the url obviously isn't a URL.
    if a:url !~ '^https\?://'
        return ""
    endif

    " Use Python/BeautifulSoup to get link's page title.
    let title = system("python3 -c \"import bs4, requests; print(bs4.BeautifulSoup(requests.get('" . a:url . "').content, 'lxml').title.text.strip())\"")

    " Echo the error if getting title failed.
    if v:shell_error != 0
        echom title
        return ""
    endif

    " Strip trailing newline
    return substitute(title, '\n', '', 'g')
endfunction

function PasteMDLink()
    let url = getreg("*")  " Get the URL from the clipboard.
    let title = GetURLTitle(url)
    let mdLink = printf("[%s](%s)", title, url)
    execute "normal! a" . mdLink . "\<Esc>"
endfunction

" Make a keybinding (mnemonic: "mark down paste")
nmap <Leader>mdp :call PasteMDLink()<cr>

" --------------------------------------------------
" Lua
" --------------------------------------------------
lua require("init")

lua << END
-- 1: relative, 2: absolute.
local filename_path = 2
require('lualine').setup{
  options = {
    theme = "tokyonight",
    globalstatus = false,
    always_divide_middle = true,
    icons_enabled = true,
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {{'filename', file_status = true, path = filename_path}},
    lualine_x = {'encoding', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {{'filename', file_status = true, path = filename_path}},
    lualine_b = {'diagnostics'},
    lualine_c = {},
    lualine_x = {'encoding', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
}
END
