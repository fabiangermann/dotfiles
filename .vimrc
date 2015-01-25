set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
"Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
"Plugin 'L9'
" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Avoid a name conflict with L9
"Plugin 'user/L9', {'name': 'newL9'}
Plugin 'altercation/vim-colors-solarized'
Plugin 'vimlatex'
Plugin 'Rykka/InstantRst'
Plugin 'Rykka/riv.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
" Use vim settings rather than vi settings

" ========================================
" Styling
" ========================================

" General styling
syntax enable
set background=dark
colorscheme solarized
"let g:solarized_termcolors=256
set number
set ruler

" ========================================
" Behaviour
" ========================================

" Encoding
set encoding=utf-8

" General
set wildmenu
set noerrorbells " no noise

" Backup/Swap
"set backupdir=/home/fg/.vim/backup/
"set directory=/home/fg/.vim/swap/
"set hidden " switch buffers without saving

" Indention
set smartindent
set tabstop=8
set shiftwidth=4
set softtabstop=4
set expandtab " spaces instead of tabs
set autoindent " auto indention
set pastetoggle=<F2>

" Searching
set incsearch " incremental (live) searching
"set hlsearch " highlight search results
set ignorecase " enable non case sensitive searching
set scs " overwrite ignorecase when searchpattern contains uppers

" Remove all trailing whitespaces when saving
autocmd BufWritePre * :%s/\s\+$//e


" ========================================
" Bindings
" ========================================
nmap <F4> :NERDTreeToggle:NERDTreeToggle<CR>
nmap <F3> :TlistToggle<CR>
cmap w!! %!sudo tee > /dev/null %

if has("gui_running")
    nmap <C-V> "+gP
    vmap <C-V> d<ESC><C-V>
    vmap <C-C> "+y
    vmap <C-X> "+x
endif


" ========================================
" Various
" ========================================

" Highlight Characters in lines with overlength (PEP8)
if exists('+colorcolumn')
    set colorcolumn=80
else
    highlight OverLength ctermbg=red ctermfg=white guibg=#843737
    match OverLength /\%81v.\+/
    "let w:m1=matchadd('OverLength', '\%>79v.\+', -1)
endif

"highlight ColorColumn ctermbg=233


" ========================================
" Plugins
" ========================================

" Pathogen
"filetype off
"call pathogen#infect()
"call pathogen#helptags()

" Filetype
filetype plugin indent on " required for python-mode

" Python-Mode
let g:pymode_folding = 0
"let g:pymode_lint_write = 0 " Disable pylint checking every save
let g:pymode_run_key = "<F5>"
let g:pymode_lint_checker = "pyflakes,pep8,mccabe" " Add pep257 for docstrings
"let g:pymode_lint_ignore = "E123,E124,E126,E128"
let g:pymode_lint_cwindow = 0 " Dont auto open cwindow if errors were found
let g:pymode_lint_onfly = 0 " Run linter on the fly

"snipMate

"taglist
let Tlist_Ctags_Cmd = '/usr/local/bin/ctags'

"InstantRst
let g:instant_rst_browser = 'chromium'

"riv
let g:riv_disable_folding = 1

" ========================================
" Various
" ========================================
autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType css,scss setlocal tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType html,xhtml,htmldjango setlocal tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType javascript setlocal tabstop=4 shiftwidth=2 softtabstop=2
