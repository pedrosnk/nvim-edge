vim.lsp.enable('lua_ls')

vim.opt.completeopt = { 'menuone', 'noinsert', 'popup', 'fuzzy' }

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end

    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, {
        autotrigger = true,
      })
    end
  end,
})

-- For floating diagnostics uncomment this and comment virtual lines
--- vim.api.nvim_create_autocmd('CursorHold', {
---   callback = function()
---     vim.diagnostic.open_float()
---   end,
--- })

vim.diagnostic.config({
  -- float = { border = 'rounded' },
  virtual_text = false,
  virtual_lines = {
    current_line = true,
  },
})
