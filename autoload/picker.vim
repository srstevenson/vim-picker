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
  return 'echo ' . join(l:names, '\\n')
endfunction

function! s:ListTagsCommand() abort
  return 'grep -v "^!_TAG_" ' . join(tagfiles()) . ' | cut -f 1 | sort -u'
endfunction

function! s:ListHelpTagsCommand() abort
  return 'cut -f 1 ' . join(findfile('doc/tags', &runtimepath, -1))
endfunction

function! s:PickerTermopen(list_command, vim_command) abort
  let l:callback = {'window_id': win_getid(), 'vim_command': a:vim_command,
              \ 'filename': tempname()}

  function! l:callback.on_exit(job_id, data, event) abort
    bdelete!
    call win_gotoid(self.window_id)
    if filereadable(self.filename)
      try
        exec self.vim_command readfile(self.filename)[0]
      catch /E684/
      endtry
      call delete(self.filename)
    endif
  endfunction

  execute 'botright' g:picker_height . 'new'
  let l:term_command = a:list_command . '|' . g:picker_selector . '>' .
        \ l:callback.filename
  let s:picker_job_id = termopen(l:term_command, l:callback)
  setfiletype picker
  let b:picker_statusline = 'Picker [command: ' . a:vim_command .
              \ ', directory: ' . getcwd() . ']'
  setlocal statusline=%{b:picker_statusline}
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
  if !executable(split(g:picker_selector)[0])
    echomsg 'Error:' split(g:picker_selector)[0] 'executable not found'
    return
  endif

  if exists('*termopen')
    call s:PickerTermopen(a:list_command, a:vim_command)
  else
    call s:PickerSystemlist(a:list_command, a:vim_command)
  endif
endfunction

function! picker#CheckIsNumber(variable, name) abort
  if type(a:variable) != type(0)
    echomsg 'Error:' a:name 'must be a number'
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

function! picker#Close() abort
  call jobstop(s:picker_job_id)
endfunction
