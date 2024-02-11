
" Disabling Vim trying to behave like Vi
set nocompatible

" Enabling file type recognition and syntax highlighting
filetype on
syntax on

" Line numbers
set number

" Do not jump to matching bracket when inserting matching one
set noshowmatch

" Wrap long lines
set wrap

" Keep cursor at least 10 lines away from screen end if possible
set scrolloff=10

" Show confirmation when closing unsaved files
set confirm

" Disable error bells
set noerrorbells

" Use select menu for TAB completions
set wildmenu

" Increase undo history to 1000
set history=1000

" Search

    " Dynamic search and highlighting while typing
    set incsearch
    set hlsearch

    " By default search case-insensitive...
    set ignorecase
    " ...but when using upper case letters change to case-sensitive
    set smartcase

" Tabs

    "Use spaces instead of tabs
    set expandtab

    " Delete multiple spaces when hitting backspace
    set smarttab

    " Keep indentation level from previous line
    set smartindent

    " Use that many spaces for indentation, if 0 use tabstop
    set shiftwidth=0

    " Number of spaces that a <Tab> in the file counts for.
    set tabstop=4

" Status line

    " Always show status line
    set laststatus=2

    function! ModifiedIndicator()
        return &modified ? '*' : ' '
    endfunction

    function! FileSize(bytes)
        let l:bytes = a:bytes | let l:sizes = ['B', 'KB', 'MB', 'GB'] | let l:i = 0
        while l:bytes >= 1024 | let l:bytes = l:bytes / 1024.0 | let l:i += 1 | endwhile
        return l:bytes > 0 ? printf(' %.2f%s ', l:bytes, l:sizes[l:i]) : ''
    endfunction

    " Left side

        " File name
        set statusline=%F

        " Update your statusline to include the modified indicator
        set statusline+=%{ModifiedIndicator()}

        " File size
        set statusline+=\ %{FileSize(line2byte('$')+len(getline('$')))}

    " Change sides
    set statusline+=%=

    " Right side

        " Line and column number
        set statusline+=%l,%c\ \ \ %P\ of\ %L\ lines

        " File encoding
        set statusline+=\ [%{&fileencoding}] " File encoding

" Mapppings

    " Ctrl+s to save file
    noremap <silent> <C-S>          :update<CR>
    vnoremap <silent> <C-S>         <C-C>:update<CR>
    inoremap <silent> <C-S>         <C-O>:update<CR>

    " Ctrl+x to quit
    nnoremap <silent> <C-x> :quit<CR>
    vnoremap <silent> <C-x> <C-C>:quit<CR>
    inoremap <silent> <C-x> <C-O>:quit<CR>

    " Ctrl+l to clear highlights
    nnoremap <silent> <C-l> :nohl<CR>

    " Fix for Ctrl+arrow keys in tmux
    execute "silent! set <xUp>=\<Esc>[@;*A"
    execute "silent! set <xDown>=\<Esc>[@;*B"
    execute "silent! set <xRight>=\<Esc>[@;*C"
    execute "silent! set <xLeft>=\<Esc>[@;*D"

    " Up/Down move visual lines instead of logical lines
    nnoremap <Up> gk
    nnoremap <Down> gj

    " Ctrl+Down/Up to move down/up 6 lines
    nnoremap <C-Down> 6<Down>
    nnoremap <C-Up> 6<Up>

    " rr to reload configuration
    nnoremap rr :source $MYVIMRC<CR>

    " F2/F3 to change buffer to previous/next, F4 to open select menu
    map <F2> :bprev<CR>
    map <F3> :bnext<CR>
    map <F4> :call feedkeys(':buffer<space><tab>','t')<cr>

    function! ToggleCursorHighlight()
        " Use the & operator to check if cursorline and cursorcolumn are enabled
        if &cursorline && &cursorcolumn
            " If both are enabled, disable them
            set nocursorline nocursorcolumn
        else
            " If either is disabled, enable both
            set cursorline cursorcolumn
        endif
    endfunction

    " Map F5 to the toggle function
    nnoremap <F5> :call ToggleCursorHighlight()<CR>


" Theme

