set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tpope/vim-fugitive'
Plugin 'mileszs/ack.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'tomtom/tcomment_vim'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/syntastic'
Plugin 'tpope/vim-unimpaired'
Plugin 'ervandew/supertab'
Plugin 'majutsushi/tagbar'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'chrisbra/NrrwRgn'
Plugin 'airblade/vim-gitgutter'
Plugin 'vim-scripts/ZoomWin'
Plugin 'jeetsukumaran/vim-buffergator'
Plugin 'skalnik/vim-vroom'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'powerline/powerline'
Plugin 'nvie/vim-flake8'
Plugin 'tpope/vim-eunuch'
Plugin 'altercation/vim-colors-solarized'
Plugin 'tpope/vim-surround'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'vim-scripts/log4j.vim'
Plugin 'tfnico/vim-gradle'
call vundle#end()

filetype plugin indent on

"Write the old file out when switching between files.
set autowrite

"Display current cursor position in lower right corner.
set ruler

"Tab stuff
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

"Show command in bottom right portion of the screen
set showcmd

"Show lines numbers
set number

"Indent stuff
set smartindent
set autoindent

"Always show the status line
set laststatus=2

"Prefer a slightly higher line height
set linespace=3

"Better line wrapping 
set wrap
set textwidth=79
set formatoptions=qrn1

"Set incremental searching"
set incsearch

""Highlight searching
set hlsearch

" case insensitive search
set ignorecase
set smartcase

"Hide MacVim toolbar by default
set go-=T

"Hard-wrap paragraphs of text
nnoremap <leader>q gqip

"Enable code folding
set foldenable

"Hide mouse when typing
set mousehide

"Faster shortcut for commenting. Requires T-Comment plugin
map ,c <c-_><c-_>

"Map code completion to , + tab
imap ,<tab> <C-x><C-o>

"Map escape key to jj -- much faster
imap jj <esc>

"mimic macvim
imap <D-]> <C-O>:tabn<cr>
imap <D-[> <C-O>:tabp<cr>

" Source the vimrc file after saving it. This way, you don't have to reload
" Vim to see the changes.
if has("autocmd")
   autocmd bufwritepost .vimrc source $MYVIMRC
endif

" Scrollbar junk
set guioptions=aAce

" Colors and fonts
syntax enable
let g:solarized_termtrans = 1

try
    colorscheme solarized
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme desert
endtry

if has('gui_running')
  "Using a cool patched font for powerline
  set guifont=Menlo:h14
  "set background transparency and solarized style 
  set background=dark
  "autopen NERDTree and focus cursor in new document
  autocmd VimEnter * NERDTree
  autocmd vimenter * wincmd p
  let NERDTreeShowHidden=1
else
  set background=dark
  set mouse=a
endif

" A fancy status bar
let g:Powerline_symbols = 'fancy'

map <Leader>n :NERDTreeToggle<CR>

" Rspec.vim mappings
map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>

""Alt+j and Alt+k to move between tabs
nnoremap <A-j> gT
nnoremap <A-k> gt

" bang bang bang
cmap w!! %!sudo tee > /dev/null %

let g:jedi#auto_initialization = 0

let g:syntastic_python_checkers = ['flake8']
autocmd BufRead,BufNewFile *.html setlocal filetype=htmldjango
