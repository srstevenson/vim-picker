<p align="center"><img src="images/vim-picker.png" width=300></p>

:warning: _vim-picker is no longer actively maintained. It is implemented and
configured in Vimscript as it was developed before the addition of the Lua API
to Neovim, and predates Neovim features such as floating windows. If you're
looking for a modern fuzzy picker for Neovim, [Telescope][telescope] is a
popular choice_.

[vim-picker] is a fuzzy picker for [Neovim] and [Vim].

<p align="center">
  <img src="https://user-images.githubusercontent.com/5845679/50046422-d29d5280-009a-11e9-94a8-bfe57972cc5a.gif" width="600" />
</p>

vim-picker allows you to search for and select files, buffers, and tags using a
fuzzy selector such as [`fzy`][fzy], [`pick`][pick], or [`selecta`][selecta]. It
has advantages over plugins with a similar purpose such as [ctrlp.vim] and
[Command-T]:

- It uses the embedded terminal emulator when available (this requires
  [Neovim][nvim-terminal] or [Vim 8.1][vim-terminal]), so the fuzzy selector
  does not block the UI. Whilst selecting an item you can move to another
  buffer, edit that buffer, and return to the fuzzy selector to continue where
  you left off.
- It adheres to the Unix philosophy, and does not reimplement existing tools.
  File listing is achieved using the best tool for the job: `git` in Git
  repositories and [`fd`][fd] elsewhere, falling back to `find` if `fd` is not
  available. Fuzzy text selection is done with `fzy` by default: a fast, well
  behaved interactive filter.
- It doesn't define default key mappings, allowing you to define your own
  mappings that best fit your workflow and don't conflict with your other
  plugins.

## Installation

To use vim-picker you will first need a fuzzy selector such as [`fzy`][fzy]
(recommended), [`pick`][pick], or [`selecta`][selecta] installed. See their
respective homepages for installation instructions.

If you already use a plugin manager such as [vim-plug], [Dein.vim], or [Vundle],
install vim-picker in the normal manner. Otherwise, the recommended plugin
manager is [minpac]. Add the following to your vimrc (`$HOME/.vim/vimrc` for Vim
and `${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.vim` for Neovim), restart Vim,
and run `:call minpac#update()`:

```vim
call minpac#add('srstevenson/vim-picker')
```

If you have Vim 7.4.1840 or newer, you can use the [native package
support][packages] instead of a plugin manager by cloning vim-picker into a
directory under [`packpath`][packpath]. For Vim:

```sh
git clone https://github.com/srstevenson/vim-picker \
    ~/.vim/pack/plugins/start/vim-picker
```

For Neovim:

```sh
git clone https://github.com/srstevenson/vim-picker \
    ${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/pack/plugins/start/vim-picker
```

## Commands

vim-picker provides the following commands:

- `:PickerEdit`: Pick a file to edit in the current window. This takes a single
  optional argument, which is the directory in which to run the file listing
  tool. If not specified, this defaults to the current working directory.
- `:PickerSplit`: Pick a file to edit in a new horizontal split. This takes an
  optional directory argument in the same manner as `:PickerEdit`.
- `:PickerTabedit`: Pick a file to edit in a new tab. This takes an optional
  directory argument in the same manner as `:PickerEdit`.
- `:PickerTabdrop`: Pick a file to edit in a new tab if no tab already contains
  it or jump to the tab containing it. This takes an optional directory argument
  in the same manner as `:PickerEdit`.
- `:PickerVsplit`: Pick a file to edit in a new vertical split. This takes an
  optional directory argument in the same manner as `:PickerEdit`.
- `:PickerBuffer`: Pick a buffer to edit in the current window.
- `:PickerBufferSplit`: Pick a buffer to edit in a new horizontal split.
- `:PickerBufferVsplit`: Pick a buffer to edit in a new vertical split.
- `:PickerTag`: Pick a tag to jump to in the current window.
- `:PickerStag`: Pick a tag to jump to in a new horizontal split.
- `:PickerBufferTag`: Pick a tag from the current buffer to jump to.
- `:PickerHelp`: Pick a help tag to jump to in the current window.

## Key mappings

vim-picker defines the following [`<Plug>`][plug-mappings] mappings:

- `<Plug>(PickerEdit)`: Execute `:PickerEdit`.
- `<Plug>(PickerSplit)`: Execute `:PickerSplit`.
- `<Plug>(PickerTabedit)`: Execute `:PickerTabedit`.
- `<Plug>(PickerTabdrop)`: Execute `:PickerTabdrop`.
- `<Plug>(PickerVsplit)`: Execute `:PickerVsplit`.
- `<Plug>(PickerBuffer)`: Execute `:PickerBuffer`.
- `<Plug>(PickerBufferSplit)`: Execute `:PickerBufferSplit`.
- `<Plug>(PickerBufferVsplit)`: Execute `:PickerBufferVsplit`.
- `<Plug>(PickerTag)`: Execute `:PickerTag`.
- `<Plug>(PickerStag)`: Execute `:PickerStag`.
- `<Plug>(PickerBufferTag)`: Execute `:PickerBufferTag`.
- `<Plug>(PickerHelp)`: Execute `:PickerHelp`.

These are not mapped to key sequences, to allow you to choose those that best
fit your workflow and don't conflict with other plugins you use. However if you
have no preference, the following snippet maps the main mappings to mnemonic key
sequences:

```vim
nmap <unique> <leader>pe <Plug>(PickerEdit)
nmap <unique> <leader>ps <Plug>(PickerSplit)
nmap <unique> <leader>pt <Plug>(PickerTabedit)
nmap <unique> <leader>pd <Plug>(PickerTabdrop)
nmap <unique> <leader>pv <Plug>(PickerVsplit)
nmap <unique> <leader>pb <Plug>(PickerBuffer)
nmap <unique> <leader>p] <Plug>(PickerTag)
nmap <unique> <leader>pw <Plug>(PickerStag)
nmap <unique> <leader>po <Plug>(PickerBufferTag)
nmap <unique> <leader>ph <Plug>(PickerHelp)
```

## Configuration

By default, vim-picker uses Git to list files in Git repositories, and `fd`
outside of Git repositories, falling back to `find` if `fd` is not available. To
use an alternative method of listing files, for example because you want to
customise the flags passed to Git, because you use a different version control
system, or because you want to use an alternative to `fd` or `find`, a custom
file listing tool can be used.

To use a custom file listing tool, set `g:picker_custom_find_executable` and
`g:picker_custom_find_flags` in your vimrc. For example, to use
[`ripgrep`][ripgrep] set:

```vim
let g:picker_custom_find_executable = 'rg'
let g:picker_custom_find_flags = '--color never --files'
```

If `g:picker_custom_find_executable` is set, and the executable it references is
found, it will always be used in place of Git, `fd`, or `find`. Therefore you
may want to make `g:picker_custom_find_executable` a wrapper script that
implements your own checks and fallbacks: for example using `hg` in Mercurial
repositories, `ripgrep` elsewhere, and falling back to `find` if `ripgrep` is
not installed.

`fzy` is used as the default fuzzy selector. To use an alternative selector, set
`g:picker_selector_executable` and `g:picker_selector_flags` in your vimrc. For
example, to use [`pick`][pick] set:

```vim
let g:picker_selector_executable = 'pick'
let g:picker_selector_flags = ''
```

vim-picker has been tested with `fzy`, `pick`, and `selecta`, but any well
behaved command line filter should work. If your version of Vim does not contain
an embedded terminal emulator, but you run Vim within [tmux], setting
`g:picker_selector_executable` to the [`fzy-tmux`][fzy-tmux] script distributed
with `fzy` will open the fuzzy selector in a new tmux pane below Vim, providing
an interface similar to using the embedded terminal emulator of Neovim or Vim
8.1.

By default, when an embedded terminal emulator is available vim-picker will run
the fuzzy selector in a full width split at the bottom of the window, using
[`:botright`][botright]. You can change this by setting `g:picker_split` in your
vimrc. For example, to open a full width split at the top of the window, set:

```vim
let g:picker_split = 'topleft'
```

See [`opening-window`][opening-window] for other valid values.

To specify the height of the window in which the fuzzy selector is opened, set
`g:picker_height` in your vimrc. The default is 10 lines:

```vim
let g:picker_height = 10
```

## Custom commands

For use cases not covered by the builtin functions, vim-picker also exposes
lower level functions that allow you to specify any shell command to generate
selection candidates with, combined with any Vim command to run on the output.
These are `picker#String()` and `picker#File()`:

```vim
call picker#String({shell_command}, {vim_command})
call picker#File({shell_command}, {vim_command}, ...)
```

These take the following arguments:

1. A shell command that generates a newline-separated list of candidates to pass
   to the fuzzy selector. The shell command can utilise pipes to chain commands
   together.
2. A Vim command, such as `edit` or `tjump`. The item selected in the fuzzy
   selector is passed to this Vim command as a single argument.

The two functions are equivalent, except that `picker#File()` escapes the user's
selection for use as a filename (for passing to Vim commands such as `:edit`)
whereas `picker#String()` does not.

For example, to edit a Markdown file stored in `~/notes` in a new tab, use:

```vim
call picker#File('find ~/notes -name "*.md"', 'tabe')
```

In addition to `shell_command` and `vim_command`, `picker#File` accepts a third
argument which is a dictionary controlling its behaviour.

It may contain the following keys:

- `cwd` controls where `shell_command` is run.
- `line_handler` must be the name of a function taking a single argument, and
  must return a dictionary. This function will be called for every user
  selection and allows the user to do some preprocessing, for example to strip
  extra information or to extract line and column information. The returned
  dictionary can have the following keys:
  - `filename`: the name of the file to open (mandatory).
  - `line`: the line to go to in the file (optional).
  - `column`: the column to go to in the line (optional).

For example, to use `ripgrep` to search for a pattern in files:

```vim
function! PickerRgLineHandler(selection) abort
    let parts = split(a:selection, ':')
    return {'filename': parts[0], 'line': parts[1], 'column': parts[2]}
endfunction

command! -nargs=? PickerRg
    \ call picker#File('rg --color never --line-number --column '.shellescape(<q-args>), "edit", {'line_handler': 'PickerRgLineHandler'})
```

Using `:PickerRg <pattern>` will search for the specified pattern and when a
match is selected the file will be opened at the line and column of the match.

## Copyright

Copyright © 2016-2023 [Scott Stevenson].

vim-picker is distributed under the terms of the [ISC licence].

[botright]: https://neovim.io/doc/user/windows.html#:botright
[command-t]: https://github.com/wincent/command-t
[ctrlp.vim]: https://github.com/ctrlpvim/ctrlp.vim
[dein.vim]: https://github.com/Shougo/dein.vim
[fd]: https://github.com/sharkdp/fd
[fzy-tmux]: https://github.com/jhawthorn/fzy/blob/master/contrib/fzy-tmux
[fzy]: https://github.com/jhawthorn/fzy
[isc licence]: https://opensource.org/licenses/ISC
[minpac]: https://github.com/k-takata/minpac
[neovim]: https://neovim.io/
[nvim-terminal]: https://neovim.io/doc/user/nvim_terminal_emulator.html
[opening-window]: https://neovim.io/doc/user/windows.html#opening-window
[packages]: https://neovim.io/doc/user/repeat.html#packages
[packpath]: https://neovim.io/doc/user/options.html#'packpath'
[pick]: https://github.com/mptre/pick
[plug-mappings]: https://neovim.io/doc/user/map.html#%3CPlug%3E
[ripgrep]: https://github.com/BurntSushi/ripgrep
[scott stevenson]: https://scott.stevenson.io
[selecta]: https://github.com/garybernhardt/selecta
[telescope]: https://github.com/nvim-telescope/telescope.nvim
[tmux]: https://tmux.github.io/
[vim-picker]: https://github.com/srstevenson/vim-picker
[vim-plug]: https://github.com/junegunn/vim-plug
[vim-terminal]: https://vimhelp.org/terminal.txt.html
[vim]: http://www.vim.org/
[vundle]: https://github.com/VundleVim/Vundle.vim
