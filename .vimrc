execute pathogen#infect()

" vi sucks
set nocompatible
"set ttyfast " causes weird background bugs

" makes the backspace key work as expected
set backspace=indent,eol,start

" fuck insert, I want to paste!
set paste

" defaults to UTF-8
set fileencoding=utf-8
set encoding=utf-8

" visual hints: line numbers, ruler and highlighted search results
set number
"set ruler
set hlsearch
set laststatus=2
set statusline=%<%f\ %w%h%m%r%{fugitive\#statusline()}\ [%{&ff}/%Y]%=%-18.(%l/%L,%c%V%)\ %p%%

" reload modified files
set autoread

" enable mouse support
" if you want to select text, in iTerm2, press Alt (or fn+option) before selecting it
set mouse=a
set ttymouse=xterm2

" disable visual mode
:map Q <Nop>

" remove trailing spaces with the space key
:noremap <Space> mkHmlgg:let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>G‛lzt‛k

" syntax highlighting
syntax enable
filetype plugin indent on

" fuck spaces, we want tabs!
set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
set autoindent
set smartindent
set smarttab

" folding
set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "don't fold by default

" persistent undo
set undodir=~/.vim/undodir
set undofile
set undolevels=1000 "maximum number of changes that can be undone
set undoreload=10000 "maximum number lines to save for undo on a buffer reload

" display control characters
set list
set lcs=tab:\ \ ,trail:\ 

" enable nice color scheme
set background=dark
:colorscheme ir_black
highlight ColorColumn ctermbg=7
highlight ColorColumn guibg=Gray

" display trailing spaces in dark grey
:hi ExtraWhitespace ctermbg=237 guibg=#3a3a3a
:match ExtraWhitespace /\s\+\%#\@<!$/

" prevent obj-c blocks' curly brackets to show up as errors
let c_no_curly_error = 1

" vim-airline
let g:airline_powerline_fonts = 1
let g:airline_theme='dark'

au BufWinLeave * call clearmatches()
au BufNewFile,BufRead *.md setlocal filetype=markdown nospell

