" Name: My vimrc configuration
" Author: Minhyeok Lee
" Email: minhyeok.lee95@gmail.csm

" ------------------------------------------------
" General
" ------------------------------------------------
lang en_US.UTF-8
filetype plugin indent on
syntax on
let g:mapleader=','

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
"set termguicolors

" Fold Options
set foldlevel=99
set foldmethod=indent

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

" Reload .vimrc
map <silent> <leader>sc :lua unload_packages()<CR>
map <silent> <leader>sv :source ~/.config/nvim/init.vim<CR>

" Switch conceallevel
noremap <Leader>c :let &cole=(&cole == 2) ? 0 : 2 <bar> echo 'conceallevel ' . &cole <CR>

" Move to current buffer directory
noremap <leader>cd :tcd %:h<CR>

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
Plug 'williamboman/nvim-lsp-installer'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" snippet
Plug 'SirVer/ultisnips'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'nvim-telescope/telescope.nvim'

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
Plug 'dense-analysis/ale'

" Status bar
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'

" Colorscheme
Plug 'ryanoasis/vim-devicons'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }

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
Plug 'ellisonleao/glow.nvim', { 'branch': 'main' }

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-neorg/neorg'

call plug#end()

" --------------------------------------------------
" colorscheme
" --------------------------------------------------
let g:tokyonight_transparent = 1
let g:tokyonight_style = "night"
let g:tokyonight_lualine_bold = "true"
colorscheme tokyonight


" --------------------------------------------------
" fzf-vim
" --------------------------------------------------
let g:fzf_preview_window = ['right:45%', 'ctrl-/']

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

" Set foldmethod for git
autocmd FileType gitcommit set foldmethod=syntax

" --------------------------------------------------
" ALE
" --------------------------------------------------
let g:ale_fix_on_save = 1
"let g:ale_completion_enabled = 1
"highlight ALEWarning ctermbg=DarkMagenta
"highlight ALEError ctermbg=DarkBlue
let g:ale_disable_lsp = 1
let g:ale_linters = {
      \ 'python': ['pyright', 'pylint'],
      \ }
let g:ale_linters_ignore = {
      \ '*': ['cspell'],
      \ 'java': ['javac'],
      \ }

" brew install shfmt, jq
" pip install black, isort
" npm i -g prettier
let g:ale_fixers = {
      \ '*': ['remove_trailing_lines', 'trim_whitespace'],
      \ 'sh': ['shfmt'],
      \ 'javascript': ['eslint', 'prettier'],
      \ 'typescript': ['eslint', 'prettier'],
      \ 'html': ['prettier'],
      \ 'xml': ['xmllint'],
      \ 'json': ['jq'],
      \ 'python': ['black', 'isort'],
      \ 'dart': ['dart-format'],
      \ }

let g:ale_xml_xmllint_indentsize = 4
" --------------------------------------------------
" ultisnips
" --------------------------------------------------
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" --------------------------------------------------
" Telescope
" --------------------------------------------------
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fr <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers({sort_mru = true, sort_lastused = true})<cr>
nnoremap <leader>ft <cmd>lua require('telescope.builtin').tags()<cr>
nnoremap <leader>fq <cmd>lua require('telescope.builtin').quickfix()<cr>
nnoremap <leader>fl <cmd>lua require('telescope.builtin').loclist()<cr>

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
" Lua
" --------------------------------------------------
lua require("plugins.lsp")
lua require("plugins.gitsigns")
lua require("plugins.telescope")

lua << END
require("nvim-treesitter.configs").setup {
  ensure_installed = "all",
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
  },
  textobjects = {
    enable = true,
  },
}

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
