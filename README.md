# Neovim Dot files edge 24-11

This is the new interaction I'm working on to configure my neovim doftfils.
As a early effort I'm again trying to replace neovim configuration by pushing new changes
and maybe even introdcing a better LSP

## Usage

To use this with your current neovim configuration. Create a new folder under ~/.config/{your name}

```fish
mkdir -p ~/.config/nvim-edge
```

Then, add the alias on your init fish file
```lua
alias nvim-edge='NVIM_APPNAME=nvim-edge nvim'
```

