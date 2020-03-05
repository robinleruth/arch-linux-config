filetype plugin on
set omnifunc=syntaxcomplete#Complete


call plug#begin('~/.vim/plugged')
Plug 'ycm-core/YouCompleteMe'
Plug 'ludovicchabant/vim-gutentags'
Plug 'kien/ctrlp.vim'
Plug 'google/vim-codefmt'
Plug 'google/vim-maktaba'
Plug 'google/vim-glaive'
call plug#end()
call glaive#Install()

augroup autoformat_settings
  "autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType c,cpp,proto,javascript AutoFormatBuffer clang-format
  "autocmd FileType dart AutoFormatBuffer dartfmt
  "autocmd FileType go AutoFormatBuffer gofmt
  "autocmd FileType gn AutoFormatBuffer gn
  "autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer js-beautify
  "autocmd FileType java AutoFormatBuffer google-java-format
  "autocmd FileType python AutoFormatBuffer yapf
  " Alternative: autocmd FileType python AutoFormatBuffer autopep8
  autocmd FileType vue AutoFormatBuffer prettier
augroup END

syntax enable
set tabstop=4
set shiftwidth=4
set expandtab
set number
filetype indent on
set autoindent

let g:ycm_global_ycm_extra_conf = "/home/robin/.vim/plugged/YouCompleteMe/.ycm_extra_conf.py"

let g:gutentags_modules = ['ctags']
let g:gutentags_cache_dir = '~/.vim/gutentags'

map <F10>    :!make<CR>
map <C-F10>  :!make clean<CR>

nmap _i I<C-m><Esc>4Go#include ""<Esc>$i
nmap _I I<C-m><Esc>4Go#include <><Esc>$i
