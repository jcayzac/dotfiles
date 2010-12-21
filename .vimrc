set nocompatible
set backspace=indent,eol,start
set paste
set number
set ruler
set hlsearch
" Grrr... autovisual mode messes with macos copy
" set mouse=a
" ...and disabling it disables selection in the terminal either!
" set mouse=nicr
:map Q <Nop>
syntax enable
set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
set list
"nnoremap <silent> <C-c> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>
"				"x            

"set lcs=tab:__,trail:░,extends:>,precedes:<,nbsp:&
set lcs=tab:\ \ ,trail:░
set t_Co=256
set background=dark
:colorscheme ir_black

