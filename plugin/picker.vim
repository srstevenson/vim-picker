" nvim-picker: a fuzzy file picker for Neovim
" Maintainer: Scott Stevenson <scott@stevenson.io>
" Source:     https://github.com/srstevenson/nvim-picker

if exists('g:loaded_picker')
  finish
elseif !exists('*termopen')
  echomsg "nvim-picker requires Neovim's termopen function"
  finish
endif

let g:loaded_picker = 1

if !exists('g:picker_selector')
  let g:picker_selector = 'pick -X'
endif

command -bar PickerEdit call picker#Edit()
command -bar PickerSplit call picker#Split()
command -bar PickerTabedit call picker#Tabedit()
command -bar PickerVsplit call picker#Vsplit()
