" Bash fixes
:silent! unmap $
:silent! vunmap $
:silent! iunmap $

:silent! vunmap $1
:silent! vunmap $2
:silent! vunmap $3
:silent! vunmap $$ 
:silent! vunmap $q
:silent! vunmap $e

:silent! iunmap $1
:silent! iunmap $2
:silent! iunmap $3
:silent! iunmap $q
:silent! iunmap $e

filetype indent off

" Fix filetypes from vim-runtime
:silent! au FileType python iunmap <buffer> $r
:silent! au FileType python iunmap <buffer> $i
:silent! au FileType python iunmap <buffer> $p
:silent! au FileType python iunmap <buffer> $f

:silent! au FileType javascript,typescript :silent! iunmap <buffer> $r
:silent! au FileType javascript,typescript iunmap <buffer> $f

" Hotkeys
:set timeoutlen=10000
noremap <silent> <C-w>L :vertical resize -5<CR>
noremap <silent> <C-w>H :vertical resize +5<CR>
noremap <silent> <C-w>J :vertical resize -5<CR>
noremap <silent> <C-w>K :vertical resize +5<CR>
noremap <silent> <C-w><Bar> :vsplit<CR>
noremap <silent> <C-w>- :split<CR>
noremap <silent> <C-w>x :q<CR>

" Status mode
:set showcmd

" Delete is not cut
nnoremap d "_d
nnoremap D "_D
vnoremap d "_d

" Delete autocompletion
let b:AutoPairs={}
let g:AutoPairs={}

