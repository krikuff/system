call plug#begin()

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'luochen1990/rainbow'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-context'

Plug 'nvim-lua/plenary.nvim' " WTF?
Plug 'nvim-telescope/telescope.nvim'
Plug 'natecraddock/telescope-zf-native.nvim'

Plug 'tpope/vim-fugitive'

Plug 'sbdchd/neoformat'
" Plug 'mhinz/vim-signify'
Plug 'airblade/vim-gitgutter'
Plug 'ThePrimeagen/harpoon'
Plug 'mbbill/undotree'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
" List of coc plugins:
" coc-clangd
" coc-cmake
" coc-go
" coc-python TODO
" coc-bash TODO

call plug#end()

" General settings
set langmap=ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;QWERTYUIOP{}ASDFGHJKL:\"ZXCVBNM<>,йцукенгшщзхъфывапролджэячсмитью;qwertyuiop[]asdfghjkl\;'zxcvbnm.
",б;, " <-  can't langmap this!

set exrc secure

set backspace=indent,eol,start

set tabstop=2 shiftwidth=2 so=2
set expandtab autoindent smartindent

set noincsearch nohlsearch

set splitbelow splitright

set ruler nu rnu

"set spell " TODO: make spell work with treesitter
set spelllang=ru_ru,en

" Graphics
set termguicolors
set t_ut=""

colorscheme catppuccin-frappe

set colorcolumn=120
highlight ColorColumn ctermbg=darkgray

let g:airline_left_sep = '🭀'
let g:airline_right_sep = '🭋'
let g:airline#extensions#tabline#left_sep = '🭛'
let g:airline#extensions#tabline#right_sep = '🭦'
let g:airline#extensions#tabline#left_alt_sep = '/' " FIXME: slashes do not perfectly align with other seps :)
let g:airline#extensions#tabline#right_alt_sep = '\'

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_close_button = 0

" Remaps

let mapleader = "\<Space>"

" Set tab key to iterate over the completion options (copy-pasted from the example :h coc-completion)
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

nnoremap <silent> <C-n> <cmd>Telescope find_files<cr>
nnoremap <silent> <C-k> <cmd>Telescope buffers<cr>
nnoremap <silent> <C-p> <cmd>Telescope git_files<cr>
nnoremap <silent> <Leader>g <cmd>Telescope live_grep<cr>
nnoremap <silent> <Leader>r <cmd>Telescope resume<cr>
nnoremap <silent> <Leader>s <cmd>Telescope git_status<cr>
nnoremap <silent> <Leader>b <cmd>Telescope git_branches<cr>

nnoremap <silent> <Leader>a :lua require("harpoon.mark").add_file()<CR>
nnoremap <silent> <Leader>m :lua require("harpoon.ui").toggle_quick_menu()<CR>

nnoremap <silent> <Leader>j :lua require("harpoon.ui").nav_next()<CR>
nnoremap <silent> <Leader>k :lua require("harpoon.ui").nav_prev()<CR>

nnoremap <silent> <Leader>u :lua require("harpoon.ui").nav_file(1)<CR>
nnoremap <silent> <Leader>i :lua require("harpoon.ui").nav_file(2)<CR>
nnoremap <silent> <Leader>o :lua require("harpoon.ui").nav_file(3)<CR>
nnoremap <silent> <Leader>p :lua require("harpoon.ui").nav_file(4)<CR>

" FIXME: does not work (with clangd fixes? TODO: read more)
nnoremap <silent> <Leader>q <cmd>Telescope quickfix<cr>

nmap <silent> gd :call CocAction('jumpDefinition')<CR>
nmap <silent> gr :call CocAction('jumpReferences')<CR>
nmap <silent> gi :call CocAction('jumpImplementation')<CR>
nmap <silent> gR :call CocAction('refactor')<CR>
nmap <silent> gl :CocCommand clangd.switchSourceHeader<CR>
nmap <silent> <Leader>h <Plug>(GitGutterUndoHunk)
nmap <silent> <C-j> :Neoformat<CR>

let g:netrw_winsize = 30 " WTF?
let g:netrw_banner = 0

" let g:fzf_command_prefix = 'Fzf'

let g:neoformat_enabled_cpp = ['clangformat']
let g:neoformat_enabled_c = ['clangformat']

let g:neoformat_cpp_clangformat = {
    \ 'exe': 'clang-format',
    \ 'args': ['--style=file'],
    \ 'stdin': 1
\}

let g:neoformat_enabled_go = ['gofmt']
let g:neoformat_go_gofmt = {
            \'exe': 'gofmt'
\}

let g:rainbow_active = 1
let g:rainbow_conf = {
\	'guifgs': ['#297EE3', '#E34334', '#1EE1E3', '#12E371'],
\}

autocmd User CocStatusChange redraws

source ~/.config/nvim/initialize_script.lua
