vim.lsp.enable('lua_ls')

-- Keeping those two LSP around I want o migrate to expert but
-- It still have some bugs in neovim
vim.lsp.enable('elixir-ls')
-- vim.lsp.enable('expert')

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

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buf, desc = "Go to definition" })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = buf, desc = "Go to declaration" })
    vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { buffer = buf, desc = "Go to type definition" })
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
