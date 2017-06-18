" vim-picker: a fuzzy picker for Neovim and Vim
" Maintainer: Scott Stevenson <scott@stevenson.io>
" Source:     https://github.com/srstevenson/vim-picker

function! s:InGitRepository() abort
    " Determine if the current directory is a Git repository.
    "
    " Returns
    " -------
    " Number
    "     1 inside a Git repository, 0 otherwise.
    let l:_ = system('git rev-parse --is-inside-work-tree')
    return v:shell_error == 0
endfunction

function! s:ListFilesCommand() abort
    " Return a shell command suitable for listing the files in the
    " current directory, based on whether the current directory is a Git
    " repository and if ripgrep is installed.
    "
    " Returns
    " -------
    " String
    "     Shell command to list files in the current directory.
    if s:InGitRepository()
        return 'git ls-files --cached --exclude-standard --others'
    elseif executable('rg')
        return 'rg --files'
    else
        return 'find . -type f'
    endif
endfunction

function! s:ListBuffersCommand() abort
    " Return a shell command which will list current listed buffers.
    "
    " Returns
    " -------
    " String
    "     Shell command to list current listed buffers.
    let l:buffers = range(1, bufnr('$'))
    let l:listed = filter(l:buffers, 'buflisted(v:val)')
    let l:names = map(l:listed, 'bufname(v:val)')
    return 'echo "' . join(l:names, "\n"). '"'
endfunction

function! s:ListTagsCommand() abort
    " Return a shell command which will list known tags.
    "
    " Returns
    " -------
    " String
    "     Shell command to list known tags.
    return 'grep -v "^!_TAG_" ' . join(tagfiles()) . ' | cut -f 1 | sort -u'
endfunction

function! s:ListBufferTagsCommand(filename) abort
    " Return a shell command which will list known tags in the current
    " file.
    "
    " Returns
    " -------
    " String
    "     Shell command to list known tags in the current file.
    return 'ctags -f - ' . a:filename . ' | cut -f 1 | sort -u'
endfunction

function! s:ListHelpTagsCommand() abort
    " Return a shell command which will list known help topics.
    "
    " Returns
    " -------
    " String
    "     Shell command to list known help topics.
    return 'cut -f 1 ' . join(findfile('doc/tags', &runtimepath, -1))
endfunction

function! s:PickerTermopen(list_command, vim_command, callback) abort
    " Open a terminal emulator buffer in a new window, execute
    " list_command piping its output to the fuzzy selector, and call
    " callback.on_select with the item selected by the user as the first
    " argument.
    "
    " Parameters
    " ----------
    " list_command : String
    "     Shell command to generate list user will choose from.
    " vim_command : String
    "     Readable representation of the Vim command which will be
    "     invoked against the user's selection, for display in the
    "     statusline.
    " callback.on_select : String -> Void
    "     Function executed with the item selected by the user as the
    "     first argument.
    let l:callback = {
                \ 'window_id': win_getid(),
                \ 'filename': tempname(),
                \ 'callback': a:callback
                \ }

    function! l:callback.on_exit(job_id, data, event) abort
        bdelete!
        call win_gotoid(self.window_id)
        if filereadable(self.filename)
            try
                call self.callback.on_select(readfile(self.filename)[0])
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

function! s:PickerSystemlist(list_command, callback) abort
    " Execute list_command in a shell, piping its output to the fuzzy
    " selector, and call callback.on_select with the line selected by
    " the user as the first argument.
    "
    " Parameters
    " ----------
    " list_command : String
    "     Shell command to generate list user will choose from.
    " callback.on_select : String -> Void
    "     Function executed with the item selected by the user as the
    "     first argument.
    try
        call a:callback.on_select(systemlist(a:list_command . '|' . g:picker_selector)[0])
    catch /E684/
    endtry
    redraw!
endfunction

function! s:Picker(list_command, vim_command, callback) abort
    " Invoke callback.on_select on the line of output of list_command
    " selected by the user, using PickerTermopen() in Neovim and
    " PickerSystemlist() otherwise.
    "
    " Parameters
    " ----------
    " list_command : String
    "     Shell command to generate list user will choose from.
    " vim_command : String
    "     Readable representation of the Vim command which will be
    "     invoked against the user's selection, for display in the
    "     statusline.
    " callback.on_select : String -> Void
    "     Function executed with the item selected by the user as the
    "     first argument.
    if !executable(split(g:picker_selector)[0])
        echomsg 'Error:' split(g:picker_selector)[0] 'executable not found'
        return
    endif

    if exists('*termopen')
        call s:PickerTermopen(a:list_command, a:vim_command, a:callback)
    else
        call s:PickerSystemlist(a:list_command, a:callback)
    endif
endfunction

function! s:PickString(list_command, vim_command) abort
    " Create a callback that executes a Vim command against the user's
    " unadulterated selection, and invoke Picker() with that callback.
    "
    " Parameters
    " ----------
    " list_command : String
    "     Shell command to generate list user will choose from.
    " vim_command : String
    "     Readable representation of the Vim command which will be
    "     invoked against the user's selection, for display in the
    "     statusline.
    let l:callback = {'vim_command': a:vim_command}

    function! l:callback.on_select(selection) abort
        exec self.vim_command a:selection
    endfunction

    call s:Picker(a:list_command, a:vim_command, l:callback)
endfunction

function! s:PickFile(list_command, vim_command) abort
    " Create a callback that executes a Vim command against the user's
    " selection escaped for use as a filename, and invoke Picker() with
    " that callback.
    "
    " Parameters
    " ----------
    " list_command : String
    "     Shell command to generate list user will choose from.
    " vim_command : String
    "     Readable representation of the Vim command which will be
    "     invoked against the user's selection, for display in the
    "     statusline.
    let l:callback = {'vim_command': a:vim_command}

    function! l:callback.on_select(selection) abort
        exec self.vim_command fnameescape(a:selection)
    endfunction

    call s:Picker(a:list_command, a:vim_command, l:callback)
endfunction

function! picker#CheckIsNumber(variable, name) abort
    " Print an error message if variable is not of type Number.
    "
    " Parameters
    " ----------
    " variable : Any
    "     Value of the variable.
    " name : String
    "     Name of the variable.
    if type(a:variable) != type(0)
        echomsg 'Error:' a:name 'must be a number'
    endif
endfunction

function! picker#CheckIsString(variable, name) abort
    " Print an error message if variable is not of type String.
    "
    " Parameters
    " ----------
    " variable : Any
    "     Value of the variable.
    " name : String
    "     Name of the variable.
    if type(a:variable) != type('')
        echomsg 'Error:' a:name 'must be a string'
    endif
endfunction

function! picker#Edit() abort
    " Run fuzzy selector to choose a file and call edit on it.
    call s:PickFile(s:ListFilesCommand(), 'edit')
endfunction

function! picker#Split() abort
    " Run fuzzy selector to choose a file and call split on it.
    call s:PickFile(s:ListFilesCommand(), 'split')
endfunction

function! picker#Tabedit() abort
    " Run fuzzy selector to choose a file and call tabedit on it.
    call s:PickFile(s:ListFilesCommand(), 'tabedit')
endfunction

function! picker#Vsplit() abort
    " Run fuzzy selector to choose a file and call vsplit on it.
    call s:PickFile(s:ListFilesCommand(), 'vsplit')
endfunction

function! picker#Buffer() abort
    " Run fuzzy selector to choose a buffer and call buffer on it.
    call s:PickFile(s:ListBuffersCommand(), 'buffer')
endfunction

function! picker#Tag() abort
    " Run fuzzy selector to choose a tag and call tag on it.
    call s:PickString(s:ListTagsCommand(), 'tag')
endfunction

function! picker#BufferTag() abort
    " Run fuzzy selector to choose a tag from the current file and call
    " tag on it.
    call s:PickString(s:ListBufferTagsCommand(expand('%:p')), 'tag')
endfunction

function! picker#Help() abort
    " Run fuzzy selector to choose a help topic and call help on it.
    call s:PickString(s:ListHelpTagsCommand(), 'help')
endfunction

function! picker#Close() abort
    " Send SIGTERM to the currently running fuzzy selector process.
    call jobstop(s:picker_job_id)
endfunction
