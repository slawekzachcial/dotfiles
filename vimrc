:scriptencoding utf-8

set nocompatible              " be iMproved

let s:full_config = filereadable(expand($MYVIMRC))

if s:full_config
    " Auto-install Plug
    if empty(glob('~/.vim/autoload/plug.vim'))
        silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif

    " Plug {{{
    call plug#begin('~/.vim/bundle')

    Plug 'airblade/vim-gitgutter'
    Plug 'chriskempson/base16-vim'
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'itchyny/lightline.vim'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'sheerun/vim-polyglot'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-unimpaired'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'zxqfl/tabnine-vim'
    Plug 'mg979/vim-visual-multi', {'branch': 'master'}
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
    " Plug 'ludovicchabant/vim-gutentags'

    call plug#end()
    " }}}
endif

" Configurations that follow are based on http://nvie.com/posts/how-i-boosted-my-vim/

" change the mapleader from \ to ,
let mapleader=","

" VIM behavior {{{
set hidden                              " allow to switch buffer with unwritten changes
set nowrap                              " don't wrap lines
set tabstop=4                           " a tab is 4 spaces
set expandtab                           " use spaces instead of tabs
set backspace=indent,eol,start          " allow backspacing over everything in insert mode
set autoindent                          " always set autoindenting to on
set copyindent                          " copy the previous indentation on autoindentin
set shiftwidth=4                        " number of spaces to use for autoindenting
set shiftround                          " use multiple of shiftwidth when indenting with '<' and '>'
set showmatch                           " set show matching parenthesis
set ignorecase                          " ignore case when searching
set smartcase                           " ignore case if search pattern is all lowercase, case-sensitive otherwise
set smarttab                            " insert tabs on the start of a line according to shiftwidth not tabstop
set hlsearch                            " highlight search terms
set incsearch                           " show search matches as you type
set history=10000                       " remember more commands and search history
set undolevels=10000                    " use many muchos levels of undo
set wildignore=*.swp,*.bak,*.pyc,*.class
set title                               " change the terminal's title
set visualbell                          " don't beep
set noerrorbells                        " don't beep
set nobackup
set noswapfile
syntax on
set list                                " highlight whitespaces
set listchars=tab:→\ ,trail:·,precedes:«,extends:» " highlight whitespaces
set wildmenu                            " show command completion matches highlights
set virtualedit=all                     " allow the cursor to go in to "invalid" places
set clipboard=unnamed                   " alias unnamed register to the + register, which is the X Window clipboard
set cpoptions+=$                        " show dollar sign when changing
set cursorline                          " highlight current line
set colorcolumn=80                      " show margin at 80 characters
set laststatus=2                        " status line always visible
set spelllang=en_us                     " set the locale for spell check
set number relativenumber               " turn on hybrid line numbers

set t_ut=

" CTRL-B to switch to alternative buffer as CTRL-^ does not work on all
" terminals (e.g. Microsoft Terminal)
nnoremap <C-b> :edit #<CR>

if s:full_config
    " Base16 Color Scheme {{{
    set encoding=utf8
    let base16colorspace=256
    set t_Co=256
    colorscheme base16-default-dark
    highlight CursorLineNr cterm=none ctermfg=20
    " }}}

    " Lightline {{{
    set noshowmode
    " }}}

    " FZF {{{
    nnoremap <Leader><Leader> :Buffers<CR>
    nnoremap <Leader>f :Files<CR>
    " Search for the word under cursor
    nnoremap <Leader>s :Ag<Space><C-R>=expand('<cword>')<CR><CR>
    " Search for the visually selected text
    vnoremap <Leader>s y:Ag<Space><C-R>=escape(@", '"*?()[]{}.')<CR><CR>
    " Run Ag
    nnoremap <Leader>a :Ag<Space>
    " }}}
else
    colorscheme darkblue
endif
