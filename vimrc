set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
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
Plugin 'Glench/Vim-Jinja2-Syntax'
Plugin 'derekwyatt/vim-scala'
Plugin 'drmingdrmer/xptemplate'
Plugin 'gurpreetatwal/vim-avro'
Plugin 'GEverding/vim-hocon'
Plugin 'kien/rainbow_parentheses.vim'
Plugin 'tpope/vim-jdaddy'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

"Write the old file out when switching between files.
set autowrite

"Display current cursor position in lower right corner.
set ruler

" if (&ft=='yaml')
"     autocmd BufRead,BufNewFile *.yml setlocal tabstop=2
"     autocmd BufRead,BufNewFile *.yml setlocal shiftwidth=2
"     autocmd BufRead,BufNewFile *.yml setlocal softtabstop=2
" else
"     "Tab stuff
"     set tabstop=4
"     set shiftwidth=4
"     set softtabstop=4
"     set expandtab
" endif

"Tab stuff
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

autocmd BufRead,BufNewFile *.yml setlocal tabstop=2
autocmd BufRead,BufNewFile *.yml setlocal shiftwidth=2
autocmd BufRead,BufNewFile *.yml setlocal softtabstop=2
au FileType yaml setl sw=2 sts=2 et

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

" A fancy status bar
let g:Powerline_symbols = 'fancy'

map <Leader>n :NERDTreeToggle<CR>
if has('gui_running')
endif

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
autocmd BufRead,BufNewFile *.json.j2 setlocal filetype=json

" ignore specific files
let NERDTreeIgnore = ['\.pyc$', '\.swp$']

function! StartUp()
    if has('gui_running')
      "Using a cool patched font for powerline
      set guifont=Menlo:h14
      "set background transparency and solarized style
      set background=dark

      if 0 == argc()
          NERDTree ~/dev
      else
          if argv(0) == '.'
              " execute 'NERDTree' getcwd()
              execute 'NERDTreeToggle'

              "autopen NERDTree and focus cursor in new document
              autocmd VimEnter * NERDTree
              autocmd vimenter * wincmd p
              let NERDTreeShowHidden=1
          else
              execute 'NERDTree' getcwd() . '/' . argv(0)
          endif
      endif

    else
      set background=dark
      set mouse=a
    endif
endfunction

autocmd VimEnter * call StartUp()
autocmd VimEnter * wincmd p

augroup myvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END

function Add(list, item)
   call add(a:list, a:item)
   return a:item
endfunction

" Rainbow parentheses
let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkgray',    'DarkOrchid3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['gray',        'RoyalBlue3'],
    \ ['black',       'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['red',         'firebrick3'],
    \ ]
let g:rbpt_max = 16
let g:rbpt_loadcmd_toggle = 0
" au VimEnter * RainbowParenthesesToggle
" au Syntax * RainbowParenthesesLoadRound
" au Syntax * RainbowParenthesesLoadSquare
" au Syntax * RainbowParenthesesLoadBraces
