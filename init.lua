print("Warnning: you are on the edge version")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

-- Map leader to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
  -- TokyoNight theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- load colorscheme
      -- options are: 'tokyonight-night', 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme("tokyonight-night")
      -- You can configure highlights by doing something like
      vim.cmd.hi("Comment gui=none")
    end,
  },
  -- Telescope is for searching for example, useful with <C-p>
  {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  -- Git integration.
  "tpope/vim-fugitive",

  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {}
    end,
  }
})

-- map telescope
-- this should go to after/plugins eventually

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
  builtin.grep_string({ search = vim.fn.input("Grep >") })
end)
vim.keymap.set('n', '<leader>pt', vim.cmd.NvimTreeToggle)

vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
