" vim-picker: a fuzzy picker for Neovim and Vim
" Maintainer: Scott Stevenson <scott@stevenson.io>
" Source:     https://github.com/srstevenson/vim-picker

if !exists('s:user_command_registry')
    let s:user_command_registry = {}
endif

function! s:IsString(variable) abort
    " Determine if a variable is a string.
    "
    " Parameters
    " ----------
    " variable : Any
    "     Value of the variable.
    "
    " Returns
    " -------
    " Boolean
    "     v:true if the variable is a string, v:false otherwise.
    return type(a:variable) ==# type('')
endfunction

function! s:RightPadText(text, length) abort
    " Right pad text with trailing spaces.
    "
    " Parameters
    " ----------
    " text : String
    "     The text to be padded.
    " length : Number
    "     The length to be padded to.
    "
    " Returns
    " -------
    " String
    "     The right padded text.
    return a:text . repeat(' ', a:length - len(a:text))
endfunction

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
    " current directory, based on whether the user has specified a
    " custom find tool, and if not, whether the current directory is a
    " Git repository and if fd is installed.
    "
    " Returns
    " -------
    " String
    "     Shell command to list files in the current directory.
    if exists('g:picker_custom_find_executable') &&
                \ executable(g:picker_custom_find_executable)
        return g:picker_custom_find_executable . ' ' . g:picker_custom_find_flags
    elseif executable('git') && s:InGitRepository()
        return 'git ls-files --cached --exclude-standard --others'
    elseif executable('fd')
        return 'fd --color never --type f'
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
    let l:bufnrs = range(1, bufnr('$'))

    " Filter out buffers which do not exist or are not listed, and the
    " current buffer.
    let l:bufnrs = filter(l:bufnrs, 'buflisted(v:val) && v:val != bufnr("%")')

    let l:bufnames = map(l:bufnrs, 'bufname(v:val)')
    return 'echo "' . join(l:bufnames, "\n"). '"'
endfunction

function! s:ListTagsCommand() abort
    " Return a shell command which will list known tags.
    "
    " Returns
    " -------
    " String
    "     Shell command to list known tags.
    return 'grep -vh "^!_TAG_" ' . join(tagfiles()) . ' | cut -f 1 | sort -u'
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

function! s:CloseWindowAndDeleteBuffer() abort
    " Close the current window, deleting buffers that are no longer displayed.
    set bufhidden=delete
    close!
endfunction

function! s:PickerTermopen(list_command, vim_command, callback) abort
    " Open a Neovim terminal emulator buffer in a new window using termopen,
    " execute list_command piping its output to the fuzzy selector, and call
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

    let l:directory = getcwd()
    if has_key(a:callback, 'cwd') && isdirectory(a:callback.cwd)
        let l:callback['cwd'] = a:callback.cwd
        let l:directory = a:callback.cwd
    endif

    function! l:callback.on_exit(job_id, data, event) abort
        call s:CloseWindowAndDeleteBuffer()
        call win_gotoid(l:self.window_id)
        if filereadable(l:self.filename)
            try
                call l:self.callback.on_select(readfile(l:self.filename)[0])
            catch /E684/
            endtry
            call delete(l:self.filename)
        endif
    endfunction

    execute g:picker_split g:picker_height . 'new'
    let l:term_command = a:list_command . '|' . g:picker_selector_executable .
                \ ' ' . g:picker_selector_flags . '>' . l:callback.filename
    let s:picker_job_id = termopen(l:term_command, l:callback)
    let b:picker_statusline = 'Picker [command: ' . a:vim_command .
                \ ', directory: ' . l:directory . ']'
    setlocal nonumber norelativenumber statusline=%{b:picker_statusline}
    setfiletype picker
    startinsert
endfunction

function! s:PickerTermStart(list_command, vim_command, callback) abort
    " Open a Vim terminal emulator buffer in a new window using term_start,
    " execute list_command piping its output to the fuzzy selector, and call
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

    let l:directory = getcwd()
    if has_key(a:callback, 'cwd') && isdirectory(a:callback.cwd)
        let l:callback['cwd'] = a:callback.cwd
        let l:directory = a:callback.cwd
    endif

    function! l:callback.exit_cb(...) abort
        close!
        call win_gotoid(l:self.window_id)
        if filereadable(l:self.filename)
            try
                call l:self.callback.on_select(readfile(l:self.filename)[0])
            catch /E684/
            endtry
            call delete(l:self.filename)
        endif
    endfunction

    let l:options = {
                \ 'curwin': 1,
                \ 'exit_cb': l:callback.exit_cb,
                \ }

    execute g:picker_split g:picker_height . 'new'
    let l:term_command = a:list_command . '|' . g:picker_selector_executable .
                \ ' ' . g:picker_selector_flags . '>' . l:callback.filename
    let s:picker_buf_num = term_start([&shell, &shellcmdflag, l:term_command],
                \ l:options)
    let b:picker_statusline = 'Picker [command: ' . a:vim_command .
                \ ', directory: ' . l:directory . ']'
    setlocal nonumber norelativenumber statusline=%{b:picker_statusline}
    setfiletype picker
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
    let l:directory = getcwd()
    if has_key(a:callback, 'cwd') && isdirectory(a:callback.cwd)
        let l:directory = a:callback.cwd
    endif

    let l:command = 'cd ' . fnameescape(l:directory) . ' && ' . a:list_command . '|' . g:picker_selector_executable . ' '
                \ . g:picker_selector_flags
    try
        call a:callback.on_select(systemlist(l:command)[0])
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
    if !executable(g:picker_selector_executable)
        echoerr 'vim-picker:' g:picker_selector_executable 'executable not found'
        return
    endif

    if exists('*termopen')
        call s:PickerTermopen(a:list_command, a:vim_command, a:callback)
    elseif exists('*term_start')
        call s:PickerTermStart(a:list_command, a:vim_command, a:callback)
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
        exec l:self.vim_command a:selection
    endfunction

    call s:Picker(a:list_command, a:vim_command, l:callback)
endfunction

function! s:PickFile(list_command, vim_command, ...) abort
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

    if a:0 > 0
        let l:callback['cwd'] = a:1
    endif

    function! l:callback.on_select(selection) abort
        if has_key(l:self, 'cwd')
            exec l:self.vim_command fnameescape(l:self.cwd . '/' . a:selection)
        else
            exec l:self.vim_command fnameescape(a:selection)
        endif
    endfunction

    call s:Picker(a:list_command, a:vim_command, l:callback)
endfunction

function! picker#String(...) abort
    " Expose s:PickString to users. See s:PickString for parameters.
    call call('s:PickString', a:000)
endfunction

function! picker#File(...) abort
    " Expose s:PickFile to users. See s:PickFile for parameters.
    call call('s:PickFile', a:000)
endfunction

function! s:GetDirectoryFromArgs(arglist) abort
    let l:directory = getcwd()
    if len(a:arglist) > 0
        if isdirectory(a:arglist[0])
            let l:directory = a:arglist[0]
        endif
    endif
    return l:directory
endfunction

function! picker#Edit(...) abort
    " Run fuzzy selector to choose a file and call edit on it.
    call s:PickFile(s:ListFilesCommand(), 'edit', s:GetDirectoryFromArgs(a:000))
endfunction

function! picker#Split(...) abort
    " Run fuzzy selector to choose a file and call split on it.
    call s:PickFile(s:ListFilesCommand(), 'split', s:GetDirectoryFromArgs(a:000))
endfunction

function! picker#Tabedit(...) abort
    " Run fuzzy selector to choose a file and call tabedit on it.
    call s:PickFile(s:ListFilesCommand(), 'tabedit', s:GetDirectoryFromArgs(a:000))
endfunction

function! picker#Vsplit(...) abort
    " Run fuzzy selector to choose a file and call vsplit on it.
    call s:PickFile(s:ListFilesCommand(), 'vsplit', s:GetDirectoryFromArgs(a:000))
endfunction

function! picker#Buffer() abort
    " Run fuzzy selector to choose a buffer and call buffer on it.
    call s:PickFile(s:ListBuffersCommand(), 'buffer')
endfunction

function! picker#Tag() abort
    " Run fuzzy selector to choose a tag and call tjump on it.
    call s:PickString(s:ListTagsCommand(), 'tjump')
endfunction

function! picker#Stag() abort
    " Run fuzzy selector to choose a tag and call stjump on it.
    call s:PickString(s:ListTagsCommand(), 'stjump')
endfunction

function! picker#BufferTag() abort
    " Run fuzzy selector to choose a tag from the current file and call
    " tjump on it.
    call s:PickString(s:ListBufferTagsCommand(expand('%:p')), 'tjump')
endfunction

function! picker#Help() abort
    " Run fuzzy selector to choose a help topic and call help on it.
    call s:PickString(s:ListHelpTagsCommand(), 'help')
endfunction

function! picker#Close() abort
    " Send SIGTERM to the currently running fuzzy selector process.
    if exists('*jobstop')
        call jobstop(s:picker_job_id)
    elseif exists('*job_stop')
        call job_stop(term_getjob(s:picker_buf_num))
    endif
endfunction

function! picker#Register(id, selection_type, vim_cmd, shell_cmd) abort
    " Register a new user-defined command.
    "
    " Parameters
    " ----------
    " id : String
    "     A unique name that identifies the user-defined command.
    " selection_type : 'file' or 'string'
    "     Whether vim-picker will match a string or filename. Special
    "     characters in filenames are escaped.
    " vim_cmd : String
    "     A Vim command that takes the user selected string as an argument,
    "     for example 'edit', 'tjump', or 'buffer'.
    " shell_cmd : String
    "     A shell command that provides a newline delimited list of strings
    "     to pass to the fuzzy selector.
    "
    " Returns
    " -------
    " Boolean
    "     v:true if registration succeeds, v:false otherwise.
    if has_key(s:user_command_registry, a:id)
        echoerr 'vim-picker: user command with ID "' . a:id . '" already registered'
        return v:false
    elseif index(['file', 'string'], a:selection_type) < 0
        echoerr 'vim-picker: argument "selection_type" of picker#Register()'
                    \ 'must be either "file" or "string"'
        return v:false
    elseif !s:IsString(a:shell_cmd)
        echoerr 'vim-picker: argument "shell_cmd" of picker#Register() must be a string'
        return v:false
    elseif !s:IsString(a:vim_cmd)
        echoerr 'vim-picker: argument "vim_cmd" of picker#Register() must be a string'
        return v:false
    endif

    let s:user_command_registry[a:id] = {
                \ 'selection_type': a:selection_type,
                \ 'shell_command': a:shell_cmd,
                \ 'vim_command': a:vim_cmd
                \ }

    return v:true
endfunction

function! picker#Execute(id) abort
    " Execute user-defined command specified by the given ID.
    "
    " Parameters
    " ----------
    " id : String
    "     A unique name that identifies the user-defined command.
    "
    " Returns
    " -------
    " Boolean
    "     v:true if user-defined command exists, v:false otherwise.
    if !has_key(s:user_command_registry, a:id)
        echoerr 'vim-picker: no command registered with ID "' . a:id . '"'
        return v:false
    endif

    let l:command = s:user_command_registry[a:id]

    if l:command['selection_type'] ==# 'file'
        call s:PickFile(l:command['shell_command'], l:command['vim_command'])
    else
        call s:PickString(l:command['shell_command'], l:command['vim_command'])
    endif

    return v:true
endfunction

function! picker#ListUserCommands() abort
    " List user-defined commands.
    echomsg ' ID         | SELECTION TYPE | VIM COMMAND | SHELL COMMAND'
    for item in items(s:user_command_registry)
        let l:id = s:RightPadText(item[0], 10)
        let l:selection_type = s:RightPadText(item[1]['selection_type'], 14)
        let l:vim_command = s:RightPadText(item[1]['vim_command'], 11)
        let l:shell_command = item[1]['shell_command']
        echomsg ' ' . l:id . ' | ' . l:selection_type . ' | ' . l:vim_command
                    \ . ' | ' . l:shell_command
    endfor
endfunction
