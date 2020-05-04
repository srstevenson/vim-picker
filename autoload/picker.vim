" vim-picker: a fuzzy picker for Neovim and Vim
" Maintainer: Scott Stevenson <scott@stevenson.io>
" Source:     https://github.com/srstevenson/vim-picker

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

function! s:IsGitRepository(directory) abort
    " Determine if a directory is a Git repository.
    "
    " Parameters
    " ----------
    " directory : String
    "     Directory to check.
    "
    " Returns
    " -------
    " Number
    "     1 inside a Git repository, 0 otherwise.
    let l:_ = system('git -C ' . a:directory . ' rev-parse --is-inside-work-tree')
    return v:shell_error == 0
endfunction

function! s:ListFilesCommand(directory) abort
    " Return a shell command suitable for listing the files in a
    " directory, based on whether the user has specified a custom find
    " tool, and if not, whether the directory is a Git repository and if
    " fd is installed.
    "
    " Parameters
    " ----------
    " directory : String
    "     Directory to check.
    "
    " Returns
    " -------
    " String
    "     Shell command to list files in the directory.
    if exists('g:picker_custom_find_executable') &&
                \ executable(g:picker_custom_find_executable)
        return g:picker_custom_find_executable . ' ' . g:picker_custom_find_flags
    elseif executable('git') && s:IsGitRepository(a:directory)
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
    if has_key(a:callback, 'options')
                \ && has_key(a:callback.options, 'cwd')
                \ && isdirectory(a:callback.options.cwd)
        let l:callback['cwd'] = a:callback.options.cwd
        let l:directory = a:callback.options.cwd
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
    let l:term_command = a:list_command . '|'
                \ . g:picker_selector_executable .  ' '
                \ . g:picker_selector_flags .
                \ '>' . l:callback.filename
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
    if has_key(a:callback, 'options')
                \ && has_key(a:callback.options, 'cwd')
                \ && isdirectory(a:callback.options.cwd)
        let l:callback['cwd'] = a:callback.options.cwd
        let l:directory = a:callback.options.cwd
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

    if strlen(l:directory)
        let l:options.cwd = l:directory
    endif

    execute g:picker_split g:picker_height . 'new'
    let l:term_command = a:list_command . '|'
                \ . g:picker_selector_executable .  ' '
                \ . g:picker_selector_flags .
                \ '>' . l:callback.filename
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
    if has_key(a:callback, 'options')
                \ && has_key(a:callback.options, 'cwd')
                \ && isdirectory(a:callback.options.cwd)
        let l:directory = a:callback.options.cwd
    endif

    let l:command = 'cd ' . fnameescape(l:directory) . ' && '
                \ . a:list_command . '|'
                \ . g:picker_selector_executable . ' '
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
    " options : Dict
    "     A dictionary with following optional keys:
    "     - cwd: The current working directory. The selection will be prefixed
    "       with this string before being opened with vim.
    "     - line_handler: A handler function which takes a single argument,
    "       the selection of the user. The handler must return a dict with the
    "       keys (filename, line, column).
    let l:callback = {'vim_command': a:vim_command, 'options': {}}

    if a:0 > 0
        let l:callback['options'] = a:1
    endif

    function! l:callback.on_select(selection) abort
        let selection = a:selection

        " line and column can only be set by a line handler provided
        " by the caller for now.
        let line = -1
        let column = -1

        if has_key(l:self, 'options')
            let options = l:self.options

            if has_key(options, 'line_handler')
                let result = call(options.line_handler, [selection])
                let selection = result.filename
                if has_key(result, 'line')
                    let line = result.line
                endif
                if has_key(result, 'column')
                    let column = result.column
                endif
            endif

            if has_key(options, 'cwd') && strlen(options.cwd)
                let selection = simplify(fnamemodify(options.cwd . '/' . selection, ':p:~:.'))
            endif
        endif

        exec l:self.vim_command fnameescape(selection)

        " Go to the line and column if possible.
        try
            if line > -1
                exec line
            endif
            if column > -1
                exec 'normal!' column.'|'
            endif
            normal! zz
        catch
        endtry

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
    let l:dir = s:GetDirectoryFromArgs(a:000)
    call s:PickFile(s:ListFilesCommand(l:dir), 'edit', {'cwd': l:dir})
endfunction

function! picker#Split(...) abort
    " Run fuzzy selector to choose a file and call split on it.
    let l:dir = s:GetDirectoryFromArgs(a:000)
    call s:PickFile(s:ListFilesCommand(l:dir), 'split', {'cwd': l:dir})
endfunction

function! picker#Tabedit(...) abort
    " Run fuzzy selector to choose a file and call tabedit on it.
    let l:dir = s:GetDirectoryFromArgs(a:000)
    call s:PickFile(s:ListFilesCommand(l:dir), 'tabedit', {'cwd': l:dir})
endfunction

function! picker#Vsplit(...) abort
    " Run fuzzy selector to choose a file and call vsplit on it.
    let l:dir = s:GetDirectoryFromArgs(a:000)
    call s:PickFile(s:ListFilesCommand(l:dir), 'vsplit', {'cwd': l:dir})
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
    echoerr 'vim-picker: picker#Register() is deprecated; see'
          \ ':help picker#String() and :help picker#File() for alternatives'
endfunction

function! picker#Execute(id) abort
    echoerr 'vim-picker: picker#Execute() is deprecated; see'
          \ ':help picker#String() and :help picker#File() for alternatives'
endfunction

function! picker#ListUserCommands() abort
    echoerr 'vim-picker: picker#ListUserCommands() is deprecated; see'
          \ ':help picker#String() and :help picker#File() for alternatives'
endfunction
