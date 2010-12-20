set backspace=indent,eol,start
set paste
set number
set ruler
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
