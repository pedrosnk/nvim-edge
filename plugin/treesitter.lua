vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
})

require('nvim-treesitter').install({
  'rust',
  'javascript',
  'typescript',
  'lua',
  'zig',
  'elixir',
  'ruby',
}):wait(300000)

vim.api.nvim_create_autocmd('FileType', {
  callback = function (ev)
    local ignored_files = { 'checkhealth', 'help' }
    if vim.tbl_contains(ignored_files, ev.match) then
      return
    end

    local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
    if not vim.treesitter.language.add(lang) then
      return
    end

    -- starting treesitter highlighting and identation
    local ok = pcall(vim.treesitter.start, ev.buf)
    if ok then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end
})
