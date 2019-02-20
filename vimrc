call plug#begin('~/.vim/vimplug-plugins')
" essentials
Plug 'mileszs/ack.vim'
Plug 'scrooloose/syntastic'
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'tpope/vim-unimpaired'
Plug 'majutsushi/tagbar'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'garbas/vim-snipmate'
Plug 'Lokaltog/vim-easymotion'
Plug 'chrisbra/NrrwRgn'
Plug 'vim-scripts/ZoomWin'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'bronson/vim-trailing-whitespace'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-surround'
Plug 'vito-c/jq.vim'

" tab completion
Plug 'ervandew/supertab'

" comments
Plug 'tomtom/tcomment_vim'

" fuzzy search
Plug 'ctrlpvim/ctrlp.vim'

" git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" colors
Plug 'lifepillar/vim-solarized8'
Plug 'ajh17/Spacegray.vim'

" jvm
Plug 'vim-scripts/log4j.vim'
Plug 'tfnico/vim-gradle'
Plug 'gurpreetatwal/vim-avro', {'as': 'vim-avro-avdl'}  "only avdl support
Plug 'AoLab/vim-avro', {'as': 'vim-avro-avsc'}          "only avsc support
Plug 'GEverding/vim-hocon'
Plug 'neo4j-contrib/cypher-vim-syntax'

" scala/metals support
Plug 'derekwyatt/vim-scala'
Plug 'natebosch/vim-lsc'

" Configuration for vim-scala
au BufRead,BufNewFile *.sbt set filetype=scala

" Configuration for vim-lsc
let g:lsc_enable_autocomplete = v:false
let g:lsc_server_commands = {
  \  'scala': {
  \    'command': 'metals-vim',
  \    'log_level': 'Log'
  \  }
  \}
let g:lsc_auto_map = {
  \  'GoToDefinition': 'gd',
  \}

" javascript/json
Plug 'mustache/vim-mustache-handlebars'
Plug 'moll/vim-node'
Plug 'tpope/vim-jdaddy'
Plug 'leshill/vim-json'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'raichoo/purescript-vim'
Plug 'FrigoEU/psc-ide-vim'

" python
Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'nvie/vim-flake8'

" build tools
Plug 'google/vim-maktaba'
Plug 'bazelbuild/vim-bazel'

call plug#end()

syntax on
syntax enable

filetype on
filetype plugin indent on

set nocompatible

" comments
map ,c <c-_><c-_>

" javascript/json
let g:javascript_plugin_flow = 1
let g:jsx_ext_required = 0

" powerline specific
" seems to work best with macvim/gvim
" NOTE: this could also be thrown into .gvimrc
if has('gui_running')
    Plug 'powerline/powerline', { 'rtp': 'powerline/bindings/vim/' }
    set guifont=Meslo\ LG\ M\ for\ Powerline:h15
    " set guifont=Inconsolata\ for\ Powerline:h15
    let g:Powerline_symbols = 'fancy'
    set encoding=utf-8
    set t_Co=256
    set fillchars+=stl:\ ,stlnc:\
    set term=xterm-256color
    set termencoding=utf-8
endif

"Write the old file out when switching between files.
set autowrite

"Display current cursor position in lower right corner.
set ruler

"Tab stuff
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

autocmd BufRead,BufNewFile *.rb setlocal tabstop=2
autocmd BufRead,BufNewFile *.rb setlocal shiftwidth=2
autocmd BufRead,BufNewFile *.rb setlocal softtabstop=2
au FileType ruby setl sw=2 sts=2 et

autocmd BufRead,BufNewFile *.js setlocal tabstop=2
autocmd BufRead,BufNewFile *.js setlocal shiftwidth=2
autocmd BufRead,BufNewFile *.js setlocal softtabstop=2
au FileType javascript setl sw=2 sts=2 et
au FileType javascript.jsx setl sw=2 sts=2 et

autocmd BufRead,BufNewFile *.yml setlocal tabstop=2
autocmd BufRead,BufNewFile *.yml setlocal shiftwidth=2
autocmd BufRead,BufNewFile *.yml setlocal softtabstop=2
au FileType yaml setl sw=2 sts=2 et

set showcmd
set number
set smartindent
set autoindent
set laststatus=2
set linespace=3
set wrap
set textwidth=79
set formatoptions=qrn1
set hlsearch
set ignorecase
set smartcase
set foldenable
set mousehide
set guioptions=aAce

"Set incremental searching"
set incsearch

"Hide MacVim toolbar by default
set go-=T

"Hard-wrap paragraphs of text
nnoremap <leader>q gqip

"Code completion
imap ,<tab> <C-x><C-o>
set omnifunc=syntaxcomplete#Complete

"Set EOL
set endofline

"Escape
imap jj <esc>

"mimic macvim
imap <D-]> <C-O>:tabn<cr>
imap <D-[> <C-O>:tabp<cr>

" Source the vimrc file after saving it. This way, you don't have to reload
" Vim to see the changes.
if has("autocmd")
   autocmd bufwritepost .vimrc source $MYVIMRC
endif

let g:solarized_termtrans = 1

set background=dark
try
    " colorscheme solarized8
    " colorscheme solarized8_low
    " colorscheme solarized8_flat
    colorscheme solarized8_high
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme desert
endtry

" sudo trick
cmap w!! %!sudo tee > /dev/null %

let g:jedi#auto_initialization = 0

let g:syntastic_python_checkers = ['flake8', 'pylint']
autocmd BufRead,BufNewFile *.html setlocal filetype=htmldjango
autocmd BufRead,BufNewFile *.json.j2 setlocal filetype=json

" nerdtree
let NERDTreeIgnore = ['^\.DS_Store$', '\.pyc$', '\.swp$', '^bazel\-.*']
map <Leader>n :NERDTreeToggle<CR>

" jvm specific
set wildignore+=*/target/*

function! StartUp()
    if has('gui_running')
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

