" General settings
set langmap=ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;QWERTYUIOP{}ASDFGHJKL:\"ZXCVBNM<>,йцукенгшщзхъфывапролджэячсмитью;qwertyuiop[]asdfghjkl\;'zxcvbnm.
",б;, " <=  can't langmap this!

set exrc secure

set backspace=indent,eol,start

set tabstop=4 shiftwidth=4 so=2
set expandtab autoindent smartindent

set noincsearch hlsearch

set splitbelow splitright

set ruler nu rnu

" Graphics
set termguicolors
set t_ut=""
colorscheme NeoSolarized

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

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" Set tab key to iterate over the completion options (stolen from first example :h coc-completion)
inoremap <silent><expr> <TAB> 
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
