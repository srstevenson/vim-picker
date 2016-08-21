" nvim-picker: a fuzzy file picker for Neovim
" Maintainer: Scott Stevenson <scott@stevenson.io>
" Source:     https://github.com/srstevenson/nvim-picker

function! s:InGitRepository() abort
  let l:result = system('git rev-parse --is-inside-work-tree')
  return v:shell_error == 0
endfunction

function! s:ListFilesCommand() abort
  if s:InGitRepository()
    return 'git ls-files --cached --exclude-standard --others'
  elseif executable('ag')
    return 'ag --files-with-matches --nocolor -g ""'
  else
    return 'find . -type f'
  endif
endfunction

function! s:Picker(list_command, vim_command) abort
  let l:callback = {'vim_command': a:vim_command, 'filename': tempname()}

  function! l:callback.on_exit() abort
    bdelete!
    if filereadable(self.filename)
      try
        exec self.vim_command . ' ' . readfile(self.filename)[0]
      catch /E684/
      endtry
      call delete(self.filename)
    endif
  endfunction

  botright new
  let l:term_command = a:list_command . '|' . g:picker_selector . '>' . l:callback.filename
  call termopen(l:term_command, l:callback)
  startinsert
endfunction

function! picker#CheckIsString(variable, name) abort
  if type(a:variable) != type('')
    echomsg 'Error:' a:name 'must be a string'
  endif
endfunction

function! picker#Edit() abort
  call s:Picker(s:ListFilesCommand(), 'edit')
endfunction

function! picker#Split() abort
  call s:Picker(s:ListFilesCommand(), 'split')
endfunction

function! picker#Tabedit() abort
  call s:Picker(s:ListFilesCommand(), 'tabedit')
endfunction

function! picker#Vsplit() abort
  call s:Picker(s:ListFilesCommand(), 'vsplit')
endfunction
