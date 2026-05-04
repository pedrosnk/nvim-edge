require('pedrosnk.vim_opt')
require('pedrosnk.lsp')

vim.api.nvim_create_autocmd('FileType', {
  pattern = { '<filetype>' },
  callback = function() vim.treesitter.start() end,
})
