# nvim-picker

[nvim-picker] is a fuzzy file picker for [Neovim].

<p align="center">
  <img src="https://cloud.githubusercontent.com/assets/5845679/17085962/99273fde-51dd-11e6-98f6-fa5c9ffaf2a8.gif" />
</p>

nvim-picker allows you to search for and select files to edit using a fuzzy
selector such as [`pick`][pick] or [`selecta`][selecta]. It has advantages over
plugins with a similar purpose such as [ctrlp.vim] and [Command-T]:

* It uses [Neovim's embedded terminal emulator][nvim-terminal] so the fuzzy
  selector does not block the UI. Whilst selecting a file to edit, you can move
  to another buffer, edit that buffer, and then return to the fuzzy selector to
  continue where you left off.
* It adheres to the Unix philosophy, and does not reimplement existing tools.
  File listing is achieved using the best tool for the job: `git` in Git
  directories and `ag` elsewhere, falling back to `find` if `ag` is not found.
  Fuzzy text selection is done with `pick`: a fast, well behaved interactive
  filter.
* It doesn't define default key mappings, allowing you to define your own
  mappings that best fit your workflow and don't conflict with your other
  plugins.

nvim-picker uses Neovim's embedded terminal emulator and therefore does not
support Vim.

## Installation

To use nvim-picker you will first need a fuzzy selector such as `pick` or
`selecta` installed. See their respective homepages for installation
instructions.

To install nvim-picker using [vim-plug], add the following to your `init.vim`
file (at `${XDG_CONFIG_HOME:-~/.config}/nvim/init.vim`), restart Neovim, and
run `:PlugInstall`:

```viml
Plug 'srstevenson/nvim-picker'
```

Using [Dein.vim], add the following to your `init.vim` file, restart Neovim,
and run `:call dein#install()`:

```viml
call dein#add('srstevenson/nvim-picker')
```

Using [Vundle], add the following to your `init.vim` file, restart Neovim, and
run `:PluginInstall`:

```viml
Plugin 'srstevenson/nvim-picker'
```

## Commands

nvim-picker provides the following commands:

* `:PickerEdit`: Pick a file with fuzzy selection to edit in the current
  window.
* `:PickerSplit`: Pick a file with fuzzy selection to edit in a new horizontal
  split.
* `:PickerTabedit`: Pick a file with fuzzy selection to edit in a new tab.
* `:PickerVsplit`: Pick a file with fuzzy selection to edit in a new vertical
  split.

## Key mappings

nvim-picker does not define any key mappings, to allow you to choose those that
best fit your workflow and don't conflict with other plugins you use. However
if you have no preference, the following snippet provides mnemonic, single
character mappings for each of nvim-picker's commands:

```viml
nnoremap <leader>e :PickerEdit<cr>
nnoremap <leader>s :PickerSplit<cr>
nnoremap <leader>t :PickerTabedit<cr>
nnoremap <leader>v :PickerVsplit<cr>
```

## Configuration

`pick` is used as the default fuzzy selector. To use an alternative selector,
set `g:picker_selector` in your `init.vim` file. For example, set

```viml
let g:picker_selector = 'selecta'
```

to use `selecta`. nvim-picker has been tested with `pick` and `selecta`, but
any well behaved command line filter should work.

## Copyright

Copyright © 2016 [Scott Stevenson].

nvim-picker is distributed under the terms of the [ISC licence].

[Command-T]: https://github.com/wincent/command-t
[ctrlp.vim]: https://github.com/ctrlpvim/ctrlp.vim
[Dein.vim]: https://github.com/Shougo/dein.vim
[ISC licence]: https://opensource.org/licenses/ISC
[Neovim]: https://neovim.io/
[nvim-picker]: https://github.com/srstevenson/nvim-picker
[nvim-terminal]: https://neovim.io/doc/user/nvim_terminal_emulator.html
[pick]: https://github.com/thoughtbot/pick
[Scott Stevenson]: https://scott.stevenson.io
[selecta]: https://github.com/garybernhardt/selecta
[vim-plug]: https://github.com/junegunn/vim-plug
[Vundle]: https://github.com/VundleVim/Vundle.vim
