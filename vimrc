set shiftwidth=4
set tabstop=4
set autoindent
set number

"source ~/.vim/test.vim

map! <F5> <ESC>:w<CR>:!python3 %<CR>
map <F5> :w<CR>:!python3 %<CR>


" Go lang 
map! <F6> <ESC>:w<CR>:!go run %<CR>
map <F6> :w<CR>:!go run %<CR>

map! <C-A> <ESC>I

map! <C-E> <ESC>A

"echo "这是一个vim echo 语句"

"set foldmethod=indent
"manual           手工定义折叠
"indent             更多的缩进表示更高级别的折叠
"expr                用表达式来定义折叠
"syntax             用语法高亮来定义折叠
"diff                  对没有更改的文本进行折叠
"marker            对文中的标志折叠



"autocmd BufReadPost *.py,*.c,*.go :set tabstop=4 sw=4


function File_sh()
	call setline(1,"#!/bin/bash")
	call setline(2,'# date ' . strftime("%Y-%m-%d %H:%M:%S"))
	call setline(3,'# author calllivecn <c-all@qq.com>')
endfunction

autocmd BufNewFile *.sh :call File_sh()

function File_py()
	call setline(1,"#!/usr/bin/env python3")
	call setline(2,"#coding=utf-8")
	call setline(3,'# date ' . strftime("%Y-%m-%d %H:%M:%S"))
	call setline(4,'# author calllivecn <c-all@qq.com>')
endfunction
autocmd BufNewFile *.py :call File_py()

