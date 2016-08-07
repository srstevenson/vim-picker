" nvim-picker: a fuzzy file picker for Neovim
" Maintainer: Scott Stevenson <scott@stevenson.io>
" Source:     https://github.com/srstevenson/nvim-picker

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

function! picker#Edit() abort
  call s:ExecuteCommand('edit')
endfunction

function! picker#Split() abort
  call s:ExecuteCommand('split')
endfunction

function! picker#Tabedit() abort
  call s:ExecuteCommand('tabedit')
endfunction

function! picker#Vsplit() abort
  call s:ExecuteCommand('vsplit')
endfunction
