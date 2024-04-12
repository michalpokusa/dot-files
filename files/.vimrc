
" Disabling Vim trying to behave like Vi
set nocompatible

" Enabling file type recognition and syntax highlighting
filetype on
syntax on

" Relative line numbers and line number on current line
set number
set relativenumber

" Enable mouse for all modes
set mouse=a

" Do not jump to matching bracket when inserting matching one
set noshowmatch

" Wrap long lines
set wrap

" Keep cursor at least 10 lines away from borders end if possible
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

" Complete menu

    " Show the complete menu even if there is only one match
    set completeopt=menu,preview,noinsert,noselect

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
    nnoremap <silent> <C-l> :nohlsearch<CR>

    " Up/Down move visual lines instead of logical lines
    nnoremap <Up> gk
    nnoremap <Down> gj

    " rr to reload configuration
    nnoremap rr :source $MYVIMRC<CR>

    function! MoveLineDown(count)
        let i = 0
        while i < a:count
            execute ":m .+1"
            let i += 1
        endwhile
    endfunction

    function! MoveLineUp(count)
        let i = 0
        while i < a:count
            execute ":m .-2"
            let i += 1
        endwhile
    endfunction

    " Swap current line with the line above/below
    nnoremap <expr> md ':<C-U>call MoveLineDown('.v:count1.')<CR>'
    nnoremap <expr> mu ':<C-U>call MoveLineUp('.v:count1.')<CR>'
    nnoremap <expr> <C-Down> ':<C-U>call MoveLineDown('.v:count1.')<CR>'
    nnoremap <expr> <C-Up> ':<C-U>call MoveLineUp('.v:count1.')<CR>'

    function! ToggleLineNumbering()
        " Only absolute line numbering
        if !&number && !&relativenumber
            set number

        " Only relative line numbering
        elseif &number && !&relativenumber
            set nonumber relativenumber

        " Both absolute and relative line numbering
        elseif !&number && &relativenumber
            set number

        " No line numbering
        else
            set norelativenumber nonumber
        endif
    endfunction

    " Map Ctrl+n to the toggle relative line numbering function
    nnoremap <silent> <C-n> :call ToggleLineNumbering()<CR>
    vnoremap <silent> <C-n> <C-C>:call ToggleLineNumbering()<CR>
    inoremap <silent> <C-n> <C-O>:call ToggleLineNumbering()<CR>

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

    " Map Ctrl+h to the toggle cursor highlight
    nnoremap <silent> <C-h> :call ToggleCursorHighlight()<CR>
    vnoremap <silent> <C-h> <C-C>:call ToggleCursorHighlight()<CR>
    inoremap <silent> <C-h> <C-O>:call ToggleCursorHighlight()<CR>

" Fixes

    " Fix for Ctrl+arrow keys in tmux
    execute "silent! set <xUp>=\<Esc>[@;*A"
    execute "silent! set <xDown>=\<Esc>[@;*B"
    execute "silent! set <xRight>=\<Esc>[@;*C"
    execute "silent! set <xLeft>=\<Esc>[@;*D"

    " Fix for tmux and vim mouse support
    if exists('$TMUX')
        let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"
        let &t_EI = "\<Esc>Ptmux;\<Esc>\e[2 q\<Esc>\\"
    else
        let &t_SI = "\e[5 q"
        let &t_EI = "\e[2 q"
    endif

" Theme

