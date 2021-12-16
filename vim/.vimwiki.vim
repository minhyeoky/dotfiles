if empty($VIMWIKI_PATH)
  finish
endif

Plug 'vimwiki/vimwiki', {'branch': 'dev'}
Plug 'tools-life/taskwiki'

let g:vimwiki_ext2syntax = {'.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
let g:vimwiki_autowriteall = 1
let g:vimwiki_folding = 'syntax'
let g:vimwiki_conceallevel = 0

let vimwiki_path = $VIMWIKI_PATH

let g:vimwiki_list = [
    \{
    \   'path': vimwiki_path,
    \   'ext' : '.md',
    \   'syntax': 'markdown',
    \   'diary_rel_path': './diary',
    \   'index': 'index_',
    \},
\]

command! WikiIndex :VimwikiIndex
nmap <Leader>ww <Plug>VimwikiIndex
nmap <Leader>wi <Plug>VimwikiDiaryIndex
nmap <Leader>wt :VimwikiTable<CR>

" 커서가 놓인 단어를 위키에서 검색한다.
nnoremap <F4> :execute "VWS /" . expand("<cword>") . "/" <Bar> :lopen<CR>

" 현재 문서를 링크한 모든 문서를 검색한다
nnoremap <leader>wb :execute "VWB" <Bar> :lopen<CR>

function! NewTemplate()
  let l:wiki_directory = v:false
  let l:draft = 'true'
  let l:is_diary = v:false

  for wiki in g:vimwiki_list
      if expand('%:p:h') == wiki.path
          let l:wiki_directory = v:true
          break
      endif
      if expand('%:p:h') == wiki.path . '/diary'
          let l:wiki_directory = v:true
          let l:is_diary = v:true
          break
      endif
  endfor

  if !l:wiki_directory
      return
  endif

  if line("$") > 1
      return
  endif

  let l:template = []
  let l:filename = expand('%:t:r')
  call add(l:template, '---')
  call add(l:template, '')
  call add(l:template, 'title      : ' . filename )
  call add(l:template, 'date       : ' . strftime('%Y-%m-%d %H:%M:%S +0900'))
  call add(l:template, 'tags       : ')
  if l:is_diary
    call add(l:template, '  - diary')
  endif
  call add(l:template, 'categories : ')
  if l:is_diary
    call add(l:template, '  - diary')
  endif
  call add(l:template, 'draft      : ' . draft)
  call add(l:template, '')
  call add(l:template, '---')
  call add(l:template, '')
  call add(l:template, '## ')
  call setline(1, l:template)
  execute 'normal! G'
  execute 'normal! $'
endfunction


function! LastModified()
  let save_cursor = getpos(".")
  let n = min([10, line("$")])
  keepjumps exe '1,' . n . 's#^\(.\{,10}lastmod\s*: \).*#\1' .
        \ strftime('%Y-%m-%d %H:%M:%S +0900') . '#e'
  call histdel('search', -1)
  call setpos('.', save_cursor)
endfunction

function! ReplaceEmoji()
  let save_cursor = getpos(".")
  exe 'silent! %s/:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/g'
  call setpos('.', save_cursor)
endfunction


augroup vimwikiauto
  autocmd BufRead,BufNewFile *.md silent call NewTemplate()
  autocmd BufWrite,FileWritePre *.md silent call LastModified()
  autocmd BufWrite,FileWritePre *.md silent call ReplaceEmoji()
augroup END

autocmd FileType markdown nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>
autocmd FileType vimwiki,markdown set foldlevel=3                                 
" autocmd FileType vimwiki,markdown set nowrap                               
let g:mdip_imgdir = 'img'
