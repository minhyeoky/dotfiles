if empty($VIMWIKI_PATH)
  finish
endif

Plug 'mhinz/vim-startify'
Plug 'vimwiki/vimwiki', {'branch': 'dev'}
Plug 'djoshea/vim-autoread'
Plug 'ferrine/md-img-paste.vim'

let g:vimwiki_ext2syntax = {'.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
let g:vimwiki_autowriteall = 1
let g:vimwiki_folding = 'syntax'
let g:vimwiki_conceallevel = 0
let g:vimwiki_global_ext = 0

autocmd TextChanged,TextChangedI *.md silent write
autocmd FileType vimwiki :set foldmethod=syntax

let vimwiki_path = $VIMWIKI_PATH

let g:vimwiki_list = [
    \{
    \   'path': vimwiki_path,
    \   'ext' : '.md',
    \   'syntax': 'markdown',
    \   'diary_rel_path': './diary',
    \   'index': 'index',
    \},
\]

command! WikiIndex :VimwikiIndex
command! -bang Todo
  \ call fzf#vim#grep(
  \ 'rg --vimgrep --color=always --smart-case -e ' . shellescape('[ ]*^\- \[ \]') . ' -- ' . shellescape($VIMWIKI_PATH),
  \ 1,
  \ fzf#vim#with_preview({'options': ['--delimiter=/', '--with-nth=9..']}),
  \ <bang>0
  \)
nmap <Leader>t :Todo<CR>
nmap <Leader>T :Todo!<CR>
nmap <Leader>ww <Plug>VimwikiIndex
nmap <Leader>wi <Plug>VimwikiDiaryIndex
nmap <Leader>wt :VimwikiTable<CR>

autocmd FileType markdown nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>
autocmd FileType vimwiki,markdown set foldlevel=1
let g:mdip_imgdir = 'img'
