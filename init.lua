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
  -- TreeSitter for better syntax hilight
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function () 
      local configs = require('nvim-treesitter.configs')

      configs.setup({
          ensure_installed = {
            'c',
            'elixir',
            'erlang',
            'heex',
            'html',
            'javascript',
            'lua',
            'query',
            'ruby',
            'vim',
            'vimdoc',
            'vue',
          },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },  
        })
    end
  },
  -- Git integration.
  'tpope/vim-fugitive',
  {
    'nvim-tree/nvim-tree.lua',
    version = "*",
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('nvim-tree').setup {}
    end,
  }
})

-- before continue go and set ts sw tst and number
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true


-- setup lsp
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function(ev)
    vim.lsp.start({
      name = 'luals',
      cmd = {'lua-language-server'},
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT'
          },
          diagnostics = {
            globals =
              { 'vim', 'require' }
          },
          workspace = {
            library = {
              [vim.fn.expand('$VIMRUNTIME/lua')] = true,
              [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
            }
          }
        }
      }
    })
  end,
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
