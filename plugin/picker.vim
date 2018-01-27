" vim-picker: a fuzzy picker for Neovim and Vim
" Maintainer: Scott Stevenson <scott@stevenson.io>
" Source:     https://github.com/srstevenson/vim-picker

if exists('g:loaded_picker')
    finish
endif

let g:loaded_picker = 1

if exists('g:picker_selector')
    echomsg 'Error: g:picker_selector is deprecated; see :help'
                \ 'picker-configuration.'
endif

if exists('g:picker_find_executable')
    call picker#CheckIsString(g:picker_find_executable,
                \ 'g:picker_find_executable')
else
    let g:picker_find_executable = 'fd'
endif

if exists('g:picker_find_flags')
    call picker#CheckIsString(g:picker_find_flags, 'g:picker_find_flags')
else
    let g:picker_find_flags = '--color never --type f'
endif

if exists('g:picker_selector_executable')
    call picker#CheckIsString(g:picker_selector_executable,
                \ 'g:picker_selector_executable')
else
    let g:picker_selector_executable = 'fzy'
endif

if exists('g:picker_selector_flags')
    call picker#CheckIsString(g:picker_selector_flags,
                \ 'g:picker_selector_flags')
else
    let g:picker_selector_flags = '--lines=' . &lines
endif

if exists('g:picker_split')
    call picker#CheckIsString(g:picker_split, 'g:picker_split')
else
    let g:picker_split = 'botright'
endif

if exists('g:picker_height')
    call picker#CheckIsNumber(g:picker_height, 'g:picker_height')
else
    let g:picker_height = 10
endif

command -bar PickerEdit call picker#Edit()
command -bar PickerSplit call picker#Split()
command -bar PickerTabedit call picker#Tabedit()
command -bar PickerVsplit call picker#Vsplit()
command -bar PickerBuffer call picker#Buffer()
command -bar PickerTag call picker#Tag()
command -bar PickerStag call picker#Stag()
command -bar PickerBufferTag call picker#BufferTag()
command -bar PickerHelp call picker#Help()

nnoremap <silent> <Plug>PickerEdit :PickerEdit<CR>
nnoremap <silent> <Plug>PickerSplit :PickerSplit<CR>
nnoremap <silent> <Plug>PickerTabedit :PickerTabedit<CR>
nnoremap <silent> <Plug>PickerVsplit :PickerVsplit<CR>
nnoremap <silent> <Plug>PickerBuffer :PickerBuffer<CR>
nnoremap <silent> <Plug>PickerTag :PickerTag<CR>
nnoremap <silent> <Plug>PickerStag :PickerStag<CR>
nnoremap <silent> <Plug>PickerBufferTag :PickerBufferTag<CR>
nnoremap <silent> <Plug>PickerHelp :PickerHelp<CR>
