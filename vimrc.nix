''
set backspace=indent,eol,start

set number ruler expandtab nu rnu autoindent smartindent
set splitbelow splitright

set tabstop=4 shiftwidth=4 so=5

let g:ycm_language_server =
\ [
\   {
\     'name': 'rust',
\     'cmdline': ['rust-analyzer'],
\     'filetypes': ['rust'],
\     'project_root_files': ['Cargo.toml']
\   }
\ ]
''
