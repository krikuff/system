set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

set exrc secure
set backspace=indent,eol,start

set ruler expandtab nu rnu
set splitbelow splitright

set tabstop=4 shiftwidth=4 so=5
set noexpandtab autoindent smartindent

set colorcolumn=120
highlight ColorColumn ctermbg=darkgray

set termguicolors
set t_ut=""
colorscheme NeoSolarized

let g:airline_left_sep = ''
let g:airline_right_sep = ''

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#close_symbol = ''
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''

let g:ycm_auto_hover = ''
let g:ycm_language_server =
\ [
\   {
\     'name': 'rust',
\     'cmdline': ['rust-analyzer'],
\     'filetypes': ['rust'],
\     'project_root_files': ['Cargo.toml']
\   }
\ ]
