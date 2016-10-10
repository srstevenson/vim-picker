# vim-picker [![Build Status](https://travis-ci.org/srstevenson/vim-picker.svg?branch=master)](https://travis-ci.org/srstevenson/vim-picker)

[vim-picker] is a fuzzy file picker for [Neovim] and [Vim].

<p align="center">
  <img src="https://cloud.githubusercontent.com/assets/5845679/17085962/99273fde-51dd-11e6-98f6-fa5c9ffaf2a8.gif" />
</p>

vim-picker allows you to search for and select files to edit using a fuzzy
selector such as [`fzy`][fzy], [`pick`][pick], or [`selecta`][selecta]. It has
advantages over plugins with a similar purpose such as [ctrlp.vim] and
[Command-T]:

* It uses the [embedded terminal emulator][nvim-terminal] when used within
  Neovim, so the fuzzy selector does not block the UI. Whilst selecting a file
  to edit, you can move to another buffer, edit that buffer, and return to the
  fuzzy selector to continue where you left off.
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

## Commands

vim-picker provides the following commands:

* `:PickerEdit`: Pick a file with fuzzy selection to edit in the current
  window.
* `:PickerSplit`: Pick a file with fuzzy selection to edit in a new horizontal
  split.
* `:PickerTabedit`: Pick a file with fuzzy selection to edit in a new tab.
* `:PickerVsplit`: Pick a file with fuzzy selection to edit in a new vertical
  split.

## Key mappings

vim-picker does not define any key mappings, to allow you to choose those that
best fit your workflow and don't conflict with other plugins you use. However
if you have no preference, the following snippet provides mnemonic, single
character mappings for each of vim-picker's commands:

```viml
nnoremap <unique> <leader>e :PickerEdit<cr>
nnoremap <unique> <leader>s :PickerSplit<cr>
nnoremap <unique> <leader>t :PickerTabedit<cr>
nnoremap <unique> <leader>v :PickerVsplit<cr>
```

## Configuration

`fzy` is used as the default fuzzy selector. To use an alternative selector,
set `g:picker_selector` in your vimrc. For example, set

```viml
let g:picker_selector = 'pick'
```

to use `pick`. vim-picker has been tested with `fzy`, `pick`, and `selecta`,
but any well behaved command line filter should work.

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
[pick]: https://github.com/calleerlandsson/pick
[rg]: https://github.com/BurntSushi/ripgrep
[Scott Stevenson]: https://scott.stevenson.io
[selecta]: https://github.com/garybernhardt/selecta
[vim-picker]: https://github.com/srstevenson/vim-picker
[vim-plug]: https://github.com/junegunn/vim-plug
[Vim]: http://www.vim.org/
[Vundle]: https://github.com/VundleVim/Vundle.vim
