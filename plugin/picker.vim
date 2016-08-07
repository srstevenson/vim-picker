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

function! s:InGitRepository() abort
  let tmp = system('git rev-parse --is-inside-work-tree')
  return v:shell_error == 0
endfunction

function! s:FileListingCommand() abort
  if s:InGitRepository()
    return 'git ls-files --cached --exclude-standard --others'
  elseif executable('ag')
    return 'ag --files-with-matches --nocolor -g ""'
  else
    return 'find . -type f'
  endif
endfunction

function! s:ExecuteCommand(vim_cmd) abort
  let callback = {'vim_cmd': a:vim_cmd, 'filename': tempname()}

  function! callback.on_exit() abort
    bdelete!
    if filereadable(self.filename)
      try
        exec self.vim_cmd . ' ' . readfile(self.filename)[0]
      catch /E684/
      endtry
      call delete(self.filename)
    endif
  endfunction

  botright new
  let list_cmd = s:FileListingCommand() . '|' . g:picker_selector . '>' . callback.filename
  call termopen(list_cmd, callback)
  startinsert
endfunction

function! PickerEdit() abort
  call s:ExecuteCommand('edit')
endfunction

function! PickerSplit() abort
  call s:ExecuteCommand('split')
endfunction

function! PickerTabedit() abort
  call s:ExecuteCommand('tabedit')
endfunction

function! PickerVsplit() abort
  call s:ExecuteCommand('vsplit')
endfunction

command! -bar PickerEdit call PickerEdit()
command! -bar PickerSplit call PickerSplit()
command! -bar PickerTabedit call PickerTabedit()
command! -bar PickerVsplit call PickerVsplit()
