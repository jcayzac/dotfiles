" vi sucks
set nocompatible

" makes the backspace key work as expected
set backspace=indent,eol,start

" fuck insert, I want to paste!
set paste

" defaults to UTF-8
set fileencoding=utf-8
set encoding=utf-8

" visual hints: line numbers, ruler and highlighted search results
set number
set ruler
set hlsearch

" enable mouse support
" if you want to select text, in iTerm2, press Alt (or fn+option) before selecting it
set mouse=nicr

" disable visual mode
:map Q <Nop>

" remove trailing spaces with the space key
:noremap <Space> mkHmlgg:let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>G‛lzt‛k

" syntax highlighting
syntax enable

" fuck spaces, we want tabs!
set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab

" persistent undo
set undodir=~/.vim/undodir
set undofile
set undolevels=1000 "maximum number of changes that can be undone
set undoreload=10000 "maximum number lines to save for undo on a buffer reload

" display control characters
set list
set lcs=tab:\ \ ,trail:\ 

" enable nice color scheme
:colorscheme ir_black

" display trailing spaces in dark grey
:hi ExtraWhitespace ctermbg=237 guibg=#3a3a3a
:match ExtraWhitespace /\s\+\%#\@<!$/

autocmd BufWinLeave * call clearmatches()
