" put this line first in ~/.vimrc
set nocompatible | filetype indent plugin on | syn on

fun! EnsureVamIsOnDisk(plugin_root_dir)
  " windows users may want to use http://mawercer.de/~marc/vam/index.php
  " to fetch VAM, VAM-known-repositories and the listed plugins
  " without having to install curl, 7-zip and git tools first
  " -> BUG [4] (git-less installation)
  let vam_autoload_dir = a:plugin_root_dir.'/vim-addon-manager/autoload'
  if isdirectory(vam_autoload_dir)
    return 1
  else
    if 1 == confirm("Clone VAM into ".a:plugin_root_dir."?","&Y\n&N")
      " I'm sorry having to add this reminder. Eventually it'll pay off.
      call confirm("Remind yourself that most plugins ship with ".
            \"documentation (README*, doc/*.txt). It is your ".
            \"first source of knowledge. If you can't find ".
            \"the info you're looking for in reasonable ".
            \"time ask maintainers to improve documentation")
      call mkdir(a:plugin_root_dir, 'p')
      execute '!git clone --depth=1 git://github.com/MarcWeber/vim-addon-manager '.
            \       shellescape(a:plugin_root_dir, 1).'/vim-addon-manager'
      " VAM runs helptags automatically when you install or update 
      " plugins
      exec 'helptags '.fnameescape(a:plugin_root_dir.'/vim-addon-manager/doc')
    endif
    return isdirectory(vam_autoload_dir)
  endif
endfun

fun! SetupVAM()
  " Set advanced options like this:
  " let g:vim_addon_manager = {}
  " let g:vim_addon_manager.key = value
  "     Pipe all output into a buffer which gets written to disk
  " let g:vim_addon_manager.log_to_buf =1

  " Example: drop git sources unless git is in PATH. Same plugins can
  " be installed from www.vim.org. Lookup MergeSources to get more control
  " let g:vim_addon_manager.drop_git_sources = !executable('git')
  " let g:vim_addon_manager.debug_activation = 1

  " VAM install location:
  let c = get(g:, 'vim_addon_manager', {})
  let g:vim_addon_manager = c
  let c.plugin_root_dir = expand('$HOME/.vim/vim-addons', 1)
  if !EnsureVamIsOnDisk(c.plugin_root_dir)
    echohl ErrorMsg | echomsg "No VAM found!" | echohl NONE
    return
  endif
  let &rtp.=(empty(&rtp)?'':',').c.plugin_root_dir.'/vim-addon-manager'

  " Tell VAM which plugins to fetch & load:
  call vam#ActivateAddons([], {'auto_install' : 0})
  " sample: call vam#ActivateAddons(['pluginA','pluginB', ...], {'auto_install' : 0})
  " Also See "plugins-per-line" below

  " Addons are put into plugin_root_dir/plugin-name directory
  " unless those directories exist. Then they are activated.
  " Activating means adding addon dirs to rtp and do some additional
  " magic

  " How to find addon names?
  " - look up source from pool
  " - (<c-x><c-p> complete plugin names):
  " You can use name rewritings to point to sources:
  "    ..ActivateAddons(["github:foo", .. => github://foo/vim-addon-foo
  "    ..ActivateAddons(["github:user/repo", .. => github://user/repo
  " Also see section "2.2. names of addons and addon sources" in VAM's documentation
endfun
call SetupVAM()
" experimental [E1]: load plugins lazily depending on filetype, See
" NOTES
" experimental [E2]: run after gui has been started (gvim) [3]
" option1:  au VimEnter * call SetupVAM()
" option2:  au GUIEnter * call SetupVAM()
" See BUGS sections below [*]
" Vim 7.0 users see BUGS section [3]

" vim plugins
call vam#ActivateAddons('github:scrooloose/nerdtree')
call vam#ActivateAddons('github:kchmck/vim-coffee-script')
call vam#ActivateAddons('github:tpope/vim-endwise')
call vam#ActivateAddons('github:tpope/vim-fugitive')
call vam#ActivateAddons('github:Lokaltog/vim-powerline')
call vam#ActivateAddons('github:scrooloose/nerdcommenter')
call vam#ActivateAddons('github:slim-template/vim-slim')
call vam#ActivateAddons('github:vim-scripts/plist.vim')
call vam#ActivateAddons('github:wincent/Command-T')
"call vam#ActivateAddons('github:changx/vim-as-man-page-viewer')
call vam#ActivateAddons('github:rking/ag.vim')
"call vam#ActivateAddons('github:Valloric/YouCompleteMe')
"call vam#ActivateAddons('github:tpope/vim-rails')
call vam#ActivateAddons('github:tpope/vim-surround')
call vam#ActivateAddons('github:majutsushi/tagbar')
"call vam#ActivateAddons('github:aaronbieber/vim-quicktask')
call vam#ActivateAddons('github:Yggdroot/indentLine')
"call vam#ActivateAddons('github:jlxz/TaskVim')
call vam#ActivateAddons('github:vimwiki/vimwiki')
call vam#ActivateAddons('github:scrooloose/syntastic')
call vam#ActivateAddons('github:dart-lang/dart-vim-plugin')

" go
if exists("g:did_load_filetypes")
  filetype off
  filetype plugin indent off
endif

set runtimepath+=/usr/local/Cellar/go/1.3.3/libexec/misc/vim
filetype plugin indent on
filetype on
autocmd FileType go autocmd BufWritePre <buffer> Fmt

syntax on
set ts=2 sts=2 sw=2 expandtab
set bs=2
set ruler
set autoread
set nu
set dir=/tmp/
set guitablabel=%M%N\ %f
set hlsearch

"filetype on
"filetype indent on
"filetype plugin on

" auto reload vimrc when editing it
autocmd! bufwritepost .vimrc source ~/.vimrc

if has("gui_running")
  set guifont=Consolas\ for\ Powerline:h12
  "set guifont=Menlo\ Regular\ for\ Powerline:h11
  "set guifontwide=Hiragino\ Sans\ GB\ W3:h12
  set guioptions-=T
  set cursorline
  set linespace=3
  "colors railscasts
  "colors xcode
  colors macvim
  set background=light
else
  colors desert
end

set clipboard=unnamed   " yank to the system register (*) by default
set showmatch       " Cursor shows matching ) and }
set showmode        " Show current mode
set wildchar=<TAB>  " start wild expansion in the command line using <TAB>
set wildmenu            " wild char completion menu
set wildmode=list:full
set backspace=indent,eol,start

" ignore these files while expanding wild chars
set wildignore=*.o,*.class,*.pyc

set autoindent      " auto indentation
set incsearch       " incremental search
set nobackup        " no *~ backup files
set copyindent      " copy the previous indentation on autoindenting
set undofile
set undodir=$HOME/.tmp/undofile
set noswf
set wrap
set ignorecase      " ignore case when searching
set smartcase       " ignore case if search pattern is all lowercase,case-sensitive otherwise
" set smarttab      " insert tabs on the start of a line according to context

" disable sound on errors
set noerrorbells
set visualbell
set t_vb=
set tm=500

set laststatus=2

set foldlevelstart=99
set foldmethod=marker

let mapleader=","
let g:mapleader=","

" move around tabs
map <S-H> gT
map <S-L> gt

nmap <leader>/ :nohls<CR>
nmap <leader>p :set paste!<BAR>set paste?<CR>

vnoremap < <gv
vnoremap > >gv

" :cd. change working dir to pwd
cmap cd. lcd %:p:h


" encoding 
set encoding=utf-8
set termencoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,latin1

fun! UTF8()
  set encoding=utf-8                                  
  set termencoding=gb18030
  set fileencoding=utf-8
  set fileencodings=ucs-bom,gb18030,utf-8,latin1
endfun

fun! Gb18030()
  set encoding=gb18030
  set fileencoding=gb18030
endfun


" Command-T
let g:CommandTMaxHeight = 15
map ,f :CommandTFlush<CR>

" NerdTree
map <C-n> :NERDTreeToggle<CR>
let g:NERDTreeQuitOnOpen = 1

let g:Powerline_symbols = "fancy"

" YCM
let g:ycm_global_ycm_extra_conf = "~/.vim/ycm_global_conf.py"
let g:ycm_min_num_identifier_candidate_chars = 2

" TagBar
" nmap <C-\> :TagbarToggle<CR>

" Quicktask
autocmd BufNewFile,BufRead *.quicktask setf quicktask

let g:indentLine_char = '|'
let g:indentLine_color_gui = '#DDDDDD'


