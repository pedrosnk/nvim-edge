vim.keymap.set('n', '<leader>pt', '<cmd>NvimTreeToggle<cr>', {})
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeFocus<cr>', {})

-- Open nvim-tree when opening a directory
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    local is_directory = vim.fn.isdirectory(data.file) == 1
    if is_directory then
      vim.cmd.cd(data.file)
      require("nvim-tree.api").tree.open()
    end
  end,
})
