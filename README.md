# Neovim Dot files

This is a complete redo of my Neovim configuration.

## Usage

To use this with your current neovim configuration. Create a new folder under ~/.config/{your name}

```fish
mkdir -p ~/.config/nvim-edge
```

Clone this repository into that folder

Then, add the alias on your init fish file
```lua
alias nvim-edge='NVIM_APPNAME=nvim-edge nvim'
```

