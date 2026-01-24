-- Tree-sitter configuration and keymaps
-- Additional tree-sitter setup that runs after plugins are loaded

-- Enable folding with tree-sitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false  -- Don't fold by default

-- Incremental selection keymaps
local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

-- Optional: configure text objects for better code navigation
-- These keymaps work with tree-sitter textobjects
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
