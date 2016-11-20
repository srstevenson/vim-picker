" vim-picker: a fuzzy picker for Neovim and Vim
" Maintainer: Scott Stevenson <scott@stevenson.io>
" Source:     https://github.com/srstevenson/vim-picker

function! s:InGitRepository() abort
  let l:_ = system('git rev-parse --is-inside-work-tree')
  return v:shell_error == 0
endfunction

function! s:ListFilesCommand() abort
  if s:InGitRepository()
    return 'git ls-files --cached --exclude-standard --others'
  elseif executable('rg')
    return 'rg --files'
  else
    return 'find . -type f'
  endif
endfunction

function! s:ListBuffersCommand() abort
  let l:buffers = range(1, bufnr('$'))
  let l:listed = filter(l:buffers, 'buflisted(v:val)')
  let l:names = map(l:listed, 'bufname(v:val)')
  return 'echo ' . join(l:names, '\n')
endfunction

function! s:ListTagsCommand() abort
  return 'grep -v "^!_TAG_" ' . join(tagfiles()) . ' | cut -f 1 | sort -u'
endfunction

function! s:ListHelpTagsCommand() abort
  return 'cut -f 1 ' . join(findfile('doc/tags', &runtimepath, -1))
endfunction

function! s:PickerTermopen(list_command, vim_command) abort
  let l:callback = {'vim_command': a:vim_command, 'filename': tempname()}

  function! l:callback.on_exit() abort
    bdelete!
    if filereadable(self.filename)
      try
        exec self.vim_command readfile(self.filename)[0]
      catch /E684/
      endtry
      call delete(self.filename)
    endif
  endfunction

  botright new
  let l:term_command = a:list_command . '|' . g:picker_selector . '>' .
        \ l:callback.filename
  call termopen(l:term_command, l:callback)
  startinsert
endfunction

function! s:PickerSystemlist(list_command, vim_command) abort
  try
    exec a:vim_command systemlist(a:list_command . '|' .
          \ g:picker_selector)[0]
  catch /E684/
  endtry
  redraw!
endfunction

function! s:Picker(list_command, vim_command) abort
  if exists('*termopen')
    call s:PickerTermopen(a:list_command, a:vim_command)
  else
    call s:PickerSystemlist(a:list_command, a:vim_command)
  endif
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

function! picker#Buffer() abort
  call s:Picker(s:ListBuffersCommand(), 'buffer')
endfunction

function! picker#Tag() abort
  call s:Picker(s:ListTagsCommand(), 'tag')
endfunction

function! picker#Help() abort
  call s:Picker(s:ListHelpTagsCommand(), 'help')
endfunction
