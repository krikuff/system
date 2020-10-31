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

let g:ycm_language_server =
\ [
\   {
\     'name': 'rust',
\     'cmdline': ['rust-analyzer'],
\     'filetypes': ['rust'],
\     'project_root_files': ['Cargo.toml']
\   }
\ ]
