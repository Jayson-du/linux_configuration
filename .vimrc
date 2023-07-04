""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 显示相关
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" 设置编码格式为utf-8
set enc=utf-8

" 设置文件编码格式为utf-8
set fencs=utf-8

" 显示行号
set number

" 设置字体
" set guifont=Courier_New:h10:cANSI

" 设置tab为4个空格
set ts=4

" 表示将 TAB 键替换为空格
set expandtab

" 表示重置 TAB 键配置，就是让上面的配置生效，最后的 ! 表示处理非空白字符后的 TAB，否则只对行首的 TAB 键生效
%retab!

" 让空格可见
set list

" TAB会被显示成 ">—" 而行尾多余的空白字符显示成 "-"
set listchars=tab:>-,trail:-

" 设置自动缩进
set autoindent

" C自动缩进
set cindent

" 自动缩进空白字符个数
set shiftwidth=4

" tab键的一个制表符, 如果softtabstop=5, tabstop=4, 则tab是由1个制表符+1空格的混合
set softtabstop=4

" tab键的空格数
set tabstop=4

" 边输入边高亮
set incsearch

" 一开始不运行'hlsearch'功能
exec "nohlsearch"

" 高亮显示搜索
set hlsearch

" 忽略大小写查找
" set ignorecase

" 智能搜索
" set smartcase

" 代码可以被收起来
set foldmethod=indent

set foldlevel=99

set smartindent

" 设置每行最大字符数
if exists('+colorcolumn')
  set colorcolumn=80
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif

" 去除vi一致性
set nocompatible

" 必须
filetype off

" 显示当前行
set cursorline

" 启动时不显示援助乌干达
set shortmess=atI

set wrap

set showcmd

set wildmenu

" 将前缀键定义为','
let mapleader = ","

let &t_SI = "\<Esc>]50;CursorShape=1\x7"

let &t_SR = "\<Esc>]50;CursorShape=2\x7"

let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" 插件列表
call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'connorholyday/vim-snazzy'
Plug 'preservim/nerdtree'

" 缩进提示
Plug 'Yggdroot/indentLine'

" 代码补全
Plug 'ycm-core/YouCompleteMe'

Plug 'szw/vim-tags'

call plug#end()

color snazzy
let g:SnazzyTransparent = 1

map si : set splitright<CR>:vsplit<CR>
map se : set splitbelow<CR>:split<CR>
map sn : set nosplitright<CR>:vsplit<CR>
map su : set nosplitbelow<CR>:split<CR>

nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>


if has("cscope")
    set csprg=/usr/bin/cscope
    set csto=0
    set cst
    set csverb
    set cspc=3
    "add any database in current dir
    if filereadable("cscope.out")
        cs add cscope.out
    "else search cscope.out elsewhere
    else
       let cscope_file=findfile("cscope.out", ".;")
       let cscope_pre=matchstr(cscope_file, ".*/")
       if !empty(cscope_file) && filereadable(cscope_file)
           exe "cs add" cscope_file cscope_pre
       endif
     endif
endif

