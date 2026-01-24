-- Tree-sitter configuration and keymaps
-- Additional tree-sitter setup that runs after plugins are loaded

-- Enable folding with tree-sitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false  -- Don't fold by default
