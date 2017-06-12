set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" required
Plugin 'gmarik/Vundle.vim'

" essentials
Plugin 'mileszs/ack.vim'
Plugin 'scrooloose/syntastic'
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'tpope/vim-unimpaired'
Plugin 'majutsushi/tagbar'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'chrisbra/NrrwRgn'
Plugin 'vim-scripts/ZoomWin'
Plugin 'jeetsukumaran/vim-buffergator'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-surround'

" tab completion
Plugin 'ervandew/supertab'

" comments
Plugin 'tomtom/tcomment_vim'
map ,c <c-_><c-_>

" fuzzy search
Plugin 'ctrlpvim/ctrlp.vim'

" git
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'

" colors
Plugin 'altercation/vim-colors-solarized'
Plugin 'lifepillar/vim-solarized8'
Plugin 'ajh17/Spacegray.vim'

" jvm
Plugin 'vim-scripts/log4j.vim'
Plugin 'tfnico/vim-gradle'
Plugin 'derekwyatt/vim-scala'
Plugin 'gurpreetatwal/vim-avro'
Plugin 'GEverding/vim-hocon'
Plugin 'neo4j-contrib/cypher-vim-syntax'

" javascript/json
Plugin 'mustache/vim-mustache-handlebars'
Plugin 'moll/vim-node'
Plugin 'tpope/vim-jdaddy'
Plugin 'leshill/vim-json'
Plugin 'pangloss/vim-javascript'
let g:javascript_plugin_flow = 1
Plugin 'mxw/vim-jsx'
let g:jsx_ext_required = 0
Plugin 'leafgarland/typescript-vim'
Plugin 'peitalin/vim-jsx-typescript'

" python
Plugin 'Glench/Vim-Jinja2-Syntax'
Plugin 'nvie/vim-flake8'

" build tools
Plugin 'google/vim-maktaba'
Plugin 'bazelbuild/vim-bazel'

call vundle#end()            " required
filetype plugin indent on    " required

" powerline specific
" seems to work best with macvim/gvim
" NOTE: this could also be thrown into .gvimrc
if has('gui_running')
    Bundle 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}
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

"Escape
imap jj <esc>

"mimic macvim
imap <D-]> <C-O>:tabn<cr>
imap <D-[> <C-O>:tabp<cr>

""Alt+j and Alt+k to move between tabs
nnoremap <A-j> gT
nnoremap <A-k> gt

" Source the vimrc file after saving it. This way, you don't have to reload
" Vim to see the changes.
if has("autocmd")
   autocmd bufwritepost .vimrc source $MYVIMRC
endif

syntax enable
let g:solarized_termtrans = 1

set background=dark
try
    " colorscheme solarized
    " colorscheme solarized8_dark
    " colorscheme solarized8_dark_low
    colorscheme solarized8_dark_high
    " colorscheme solarized8_dark_flat
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme desert
endtry

" sudo trick
cmap w!! %!sudo tee > /dev/null %

let g:jedi#auto_initialization = 0

let g:syntastic_python_checkers = ['flake8']
autocmd BufRead,BufNewFile *.html setlocal filetype=htmldjango
autocmd BufRead,BufNewFile *.json.j2 setlocal filetype=json

" nerdtree
let NERDTreeIgnore = ['^\.DS_Store$', '\.pyc$', '\.swp$', '^bazel\-.*']
map <Leader>n :NERDTreeToggle<CR>

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

