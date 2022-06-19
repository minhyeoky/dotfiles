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
let g:vimwiki_conceallevel = 2
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
  \ 'rg --column --line-number --no-heading --color=always --smart-case -e ' . shellescape('[ ]*\- \[ \]'),
  \ 1,
  \ fzf#vim#with_preview({'dir': $VIMWIKI_PATH}),
  \ <bang>0
  \)

command! -bang VimwikiRg
  \ call fzf#vim#grep(
  \ 'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>),
  \ 1,
  \ fzf#vim#with_preview({'dir': $VIMWIKI_PATH}),
  \ <bang>0
  \)

command! -bang VimwikiFiles
  \ call fzf#vim#files(
  \ $VIMWIKI_PATH,
  \ <bang>0
  \)

" TODO: Move to other config
command! -bang -nargs=* DotSearch
  \ call fzf#vim#grep(
  \ 'rg --column --line-number --no-heading --color=always --smart-case -- '. shellescape(<q-args>),
  \ 1,
  \ fzf#vim#with_preview({'dir': $DOTFILES_PATH}),
  \ <bang>0
  \)

command! -bang DotFiles
  \ call fzf#vim#files(
  \ $DOTFILES_PATH,
  \ <bang>0
  \)

nmap <Leader>dr :DotSearch<CR>
nmap <Leader>dR :DotSearch!<CR>
nmap <Leader>df :DotFiles<CR>
nmap <Leader>dF :DotFiles!<CR>

command! -bang VimwikiFiles
  \ call fzf#vim#files(
  \ $VIMWIKI_PATH,
  \ <bang>0
  \)

nmap <Leader>wt :Todo<CR>
nmap <Leader>wT :Todo!<CR>
nmap <Leader>ww <Plug>VimwikiIndex
nmap <Leader>wi <Plug>VimwikiDiaryIndex
nmap <Leader>ws :VimwikiRg<CR>
nmap <Leader>wS :VimwikiRg!<CR>
nmap <Leader>wf :VimwikiFiles<CR>
nmap <Leader>wF :VimwikiFiles!<CR>

autocmd FileType markdown,vimwiki nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>
let g:mdip_imgdir = 'img'
