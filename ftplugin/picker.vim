" vim-picker: a fuzzy picker for Neovim and Vim
" Maintainer: Scott Stevenson <scott@stevenson.io>
" Source:     https://github.com/srstevenson/vim-picker

if exists(':tnoremap') == 2
    tnoremap <buffer> <silent> <Esc> <C-\><C-n>:call picker#Close()<CR>
endif
