set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
"Plugin 'altercation/vim-colors-solarized'
"Plugin 'chriskempson/base16-vim'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-syntastic/syntastic'
Plugin 'sjl/gundo.vim'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'lervag/vimtex'
Plugin 'vimwiki/vimwiki'
Plugin 'leafgarland/typescript-vim'
Plugin 'MaxMEllon/vim-jsx-pretty'

call vundle#end()            " required

" ========================================
" Basic Settings
" ========================================
syntax on                           " syntax highlighting
filetype on                         " try to dectect filetypes
filetype plugin indent on           " enable loading indent file for filetype
set encoding=utf-8                  " default encoding
set title                           " show title in titlebar
set ruler                           " show ruler

" Relative numbers in active buffer, absolute numbers in all others
autocmd BufLeave * : setlocal norelativenumber number
autocmd BufEnter * : setlocal relativenumber number

set background=light
"let g:solarized_termtrans=1
"colorscheme solarized
"let base16colorspace=256
"colorscheme base16-default
"set t_Co=256


" dont bell or blink
set noerrorbells
set vb t_vb=

set cursorline                      " have a line indicate the cursor location
set scrolloff=3                     " keep 4 context lines above and below cursor

" ========================================
" Behaviour
" ========================================


" General
set wildmenu

set hidden " switch buffers without saving

" Indention
set smartindent
set cindent " Using cindent over smartindent fixes jumping python comments to begin of line for example. Use only one or the other (smartindent/cindent)
set tabstop=8
set shiftwidth=4
set softtabstop=4
set expandtab " spaces instead of tabs
set autoindent " auto indention
set pastetoggle=<F2>
autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType css,scss setlocal tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType html,xhtml,htmldjango setlocal tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType javascript setlocal tabstop=2 shiftwidth=2 softtabstop=2

autocmd FileType rst setlocal makeprg=/usr/bin/rst2pdf

autocmd Filetype java set makeprg=javac\ %
set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
map <F9> :make<Return>:copen<Return>
map <F10> :cprevious<Return>
map <F11> :cnext<Return>


" Searching
set incsearch " incremental (live) searching
set nohlsearch " highlight search results
set ignorecase " enable non case sensitive searching
set scs " overwrite ignorecase when searchpattern contains uppers


" Remove all trailing whitespaces when saving
autocmd BufWritePre * :%s/\s\+$//e


" ========================================
" Bindings
"
" ========================================
cmap w!! %!sudo tee > /dev/null %


" ========================================
"
" Various
" ========================================

" Highlight Characters in lines with overlength (PEP8)
if exists('+colorcolumn')
    set colorcolumn=80
else
    highlight OverLength ctermbg=red ctermfg=white guibg=#843737
    match OverLength /\%81v.\+/
endif


" Set text width to 72 chars (automatically create new lines when
" writing comments)
set tw=72
set fo=cq

" Disable autowrapping for textfiles
autocmd FileType text,markdown,rst setlocal tw=0


" ========================================
" Plugins
" ========================================
"

set tags=~/.tags

" Sparkup
let g:sparkupDoubleQuote = 1 " Double quotes for html attribute tags
autocmd FileType htmldjango runtime! ftplugin/html/sparkup.vim


" ========================================
" Syntastic
" ========================================
augroup mine
    au BufWinEnter * sign define dummy
    au BufWinEnter * exe "sign place 1337 line=1 name=dummy buffer=" . bufnr('%')
augroup END


function! DoPrettyXML()
  " save the filetype so we can restore it later
  let l:origft = &ft
  set ft=
  " delete the xml header if it exists. This will
  " permit us to surround the document with fake tags
  " without creating invalid xml.
  1s/<?xml .*?>//e
  " insert fake tags around the entire document.
  " This will permit us to pretty-format excerpts of
  " XML that may contain multiple top-level elements.
  0put ='<PrettyXML>'
  $put ='</PrettyXML>'
  silent %!xmllint --format -
  " xmllint will insert an <?xml?> header. it's easy enough to delete
  " if you don't want it.
  " delete the fake tags
  2d
  $d
  " restore the 'normal' indentation, which is one extra level
  " too deep due to the extra tags we wrapped around the document.
  silent %<
  " back to home
  1
  " restore the filetype
  exe "set ft=" . l:origft
endfunction
command! PrettyXML call DoPrettyXML()

set backupcopy=yes

