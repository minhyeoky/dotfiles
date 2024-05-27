" --------------------------------------------------
" [Vim Tip: Paste Markdown Link with Automatic Title Fetching | Ben Congdon](https://benjamincongdon.me/blog/2020/06/27/Vim-Tip-Paste-Markdown-Link-with-Automatic-Title-Fetching/)
" Requires Python3 with beautifulsoup4, lxml and requests
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

function PasteMDLink(placeholder)
    let url = getreg("*")  " Get the URL from the clipboard.
    let title = GetURLTitle(url)
    let mdLink = printf(a:placeholder, title, url)
    execute "normal! a" . mdLink . "\<Esc>"
endfunction

" Make a keybinding (mnemonic: "mark down paste")
nmap <Leader>mdp :call PasteMDLink("[%s](%s)")<cr>

" Navigate between markdown links
nmap <buffer><silent> <Tab> /\[[^]]*\](\S\+)<CR>:set nohlsearch<CR>
nmap <buffer><silent> <S-Tab> ?\[[^]]*\](\S\+)<CR>:set nohlsearch<CR>
