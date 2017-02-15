# vim-picker [![Build Status](https://travis-ci.org/srstevenson/vim-picker.svg?branch=master)](https://travis-ci.org/srstevenson/vim-picker)

[vim-picker] is a fuzzy picker for [Neovim] and [Vim].

<p align="center">
  <img src="https://cloud.githubusercontent.com/assets/5845679/19386835/60833856-920e-11e6-9082-dd6fa5e7a246.gif" />
</p>

vim-picker allows you to search for and select files, buffers, and tags using a
fuzzy selector such as [`fzy`][fzy], [`pick`][pick], or [`selecta`][selecta].
It has advantages over plugins with a similar purpose such as [ctrlp.vim] and
[Command-T]:

* It uses the [embedded terminal emulator][nvim-terminal] when used within
  Neovim, so the fuzzy selector does not block the UI. Whilst selecting an item
  you can move to another buffer, edit that buffer, and return to the fuzzy
  selector to continue where you left off.
* It adheres to the Unix philosophy, and does not reimplement existing tools.
  File listing is achieved using the best tool for the job: `git` in Git
  repositories and [`rg`][rg] elsewhere, falling back to `find` if `rg` is not
  available. Fuzzy text selection is done with `fzy` by default: a fast, well
  behaved interactive filter.
* It doesn't define default key mappings, allowing you to define your own
  mappings that best fit your workflow and don't conflict with your other
  plugins.

## Installation

To use vim-picker you will first need a fuzzy selector such as [`fzy`][fzy],
[`pick`][pick], or [`selecta`][selecta] installed. See their respective
homepages for installation instructions.

To install vim-picker using [vim-plug], add the following to your vimrc
(`$HOME/.vim/vimrc` for Vim and
`${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.vim` for Neovim), restart Vim, and
run `:PlugInstall`:

```viml
Plug 'srstevenson/vim-picker'
```

Using [Dein.vim], add the following to your vimrc, restart Vim, and run `:call
dein#install()`:

```viml
call dein#add('srstevenson/vim-picker')
```

Using [Vundle], add the following to your vimrc, restart Vim, and run
`:PluginInstall`:

```viml
Plugin 'srstevenson/vim-picker'
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

* `:PickerEdit`: Pick a file to edit in the current window.
* `:PickerSplit`: Pick a file to edit in a new horizontal split.
* `:PickerTabedit`: Pick a file to edit in a new tab.
* `:PickerVsplit`: Pick a file to edit in a new vertical split.
* `:PickerBuffer`: Pick a buffer to edit in the current window.
* `:PickerTag`: Pick a tag to jump to in the current window.
* `:PickerHelp`: Pick a help tag to jump to in the current window.

## Key mappings

vim-picker defines the following [`<Plug>`][plug-mappings] mappings:

* `<Plug>PickerEdit`: Execute `:PickerEdit`.
* `<Plug>PickerSplit`: Execute `:PickerSplit`.
* `<Plug>PickerTabedit`: Execute `:PickerTabedit`.
* `<Plug>PickerVsplit`: Execute `:PickerVsplit`.
* `<Plug>PickerBuffer`: Execute `:PickerBuffer`.
* `<Plug>PickerTag`: Execute `:PickerTag`.
* `<Plug>PickerHelp`: Execute `:PickerHelp`.

These are not mapped to key sequences, to allow you to choose those that best
fit your workflow and don't conflict with other plugins you use. However if you
have no preference, the following snippet maps each mapping to a mnemonic key
sequence:

```viml
nmap <unique> <leader>pe <Plug>PickerEdit
nmap <unique> <leader>ps <Plug>PickerSplit
nmap <unique> <leader>pt <Plug>PickerTabedit
nmap <unique> <leader>pv <Plug>PickerVsplit
nmap <unique> <leader>pb <Plug>PickerBuffer
nmap <unique> <leader>p] <Plug>PickerTag
nmap <unique> <leader>ph <Plug>PickerHelp
```

## Configuration

`fzy` is used as the default fuzzy selector. To use an alternative selector,
set `g:picker_selector` in your vimrc. For example, set

```viml
let g:picker_selector = 'pick'
```

to use `pick`. vim-picker has been tested with `fzy`, `pick`, and `selecta`,
but any well behaved command line filter should work.

To specify the height of the window in which the fuzzy selector is opened in
Neovim, set `g:picker_height` in your vimrc. The default is 10 lines:

```viml
let g:picker_height = 10
```

## Copyright

Copyright © 2016 [Scott Stevenson].

vim-picker is distributed under the terms of the [ISC licence].

[Command-T]: https://github.com/wincent/command-t
[ctrlp.vim]: https://github.com/ctrlpvim/ctrlp.vim
[Dein.vim]: https://github.com/Shougo/dein.vim
[fzy]: https://github.com/jhawthorn/fzy
[ISC licence]: https://opensource.org/licenses/ISC
[Neovim]: https://neovim.io/
[nvim-terminal]: https://neovim.io/doc/user/nvim_terminal_emulator.html
[packages]: https://vimhelp.appspot.com/repeat.txt.html#packages
[packpath]: https://vimhelp.appspot.com/options.txt.html#%27packpath%27
[pick]: https://github.com/calleerlandsson/pick
[plug-mappings]: https://vimhelp.appspot.com/map.txt.html#%3CPlug%3E
[rg]: https://github.com/BurntSushi/ripgrep
[Scott Stevenson]: https://scott.stevenson.io
[selecta]: https://github.com/garybernhardt/selecta
[vim-picker]: https://github.com/srstevenson/vim-picker
[vim-plug]: https://github.com/junegunn/vim-plug
[Vim]: http://www.vim.org/
[Vundle]: https://github.com/VundleVim/Vundle.vim
