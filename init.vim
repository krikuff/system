call plug#begin()

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'overcache/NeoSolarized'
Plug 'navarasu/onedark.nvim'

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'sbdchd/neoformat'
Plug 'mhinz/vim-signify'

call plug#end()

" General settings
set langmap=ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;QWERTYUIOP{}ASDFGHJKL:\"ZXCVBNM<>,йцукенгшщзхъфывапролджэячсмитью;qwertyuiop[]asdfghjkl\;'zxcvbnm.
",б;, " <-  can't langmap this!

set exrc secure

set backspace=indent,eol,start

set tabstop=4 shiftwidth=4 so=2
set expandtab autoindent smartindent

set noincsearch nohlsearch

set splitbelow splitright

set ruler nu rnu

" Graphics
set termguicolors
set t_ut=""
let g:onedark_config = {
    \ 'style': 'warm',
\}
colorscheme onedark

set colorcolumn=120
highlight ColorColumn ctermbg=darkgray

" Hard to find symbols:      
let g:airline_left_sep = ''
let g:airline_right_sep = ''

let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_close_button = 0

" Remaps

" " Set tab key to iterate over the completion options (stolen from the example :h coc-completion)
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ?
          \ coc#pum#next(1)
          \ :
          \ CheckBackspace() ?
              \ "\<Tab>"
              \ :
              \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <c-space> coc#refresh()

nnoremap <silent> <C-p> :FzfGitFiles<CR>
nnoremap <silent> <C-[> :FzfFiles<CR>
nmap <silent> gd :call CocAction('jumpDefinition')<CR>
nmap <silent> gr :call CocAction('jumpReferences')<CR>
nmap <silent> gi :call CocAction('jumpImplementation')<CR>
nmap <silent> gR :call CocAction('refactor')<CR>
nmap <silent> <C-h> :SignifyHunkUndo<CR>
nmap <silent> <C-j> :Neoformat<CR>

let g:netrw_winsize = 30
let g:netrw_banner = 0

let g:fzf_command_prefix = 'Fzf'

let g:neoformat_enabled_cpp = ['clangformat']
let g:neoformat_enabled_c = ['clangformat']
let g:neoformat_cpp_clangformat = {
    \ 'exe': 'clang-format-14',
    \ 'args': ['--style=file'],
    \ 'stdin': 1
\}
let g:neoformat_enabled_go = ['gofmt']
let g:neoformat_go_gofmt = {
            \'exe': 'gofmt'
\}
