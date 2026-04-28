local ok, ts = pcall(require, 'nvim-treesitter.config')
if not ok then
  ok, ts = pcall(require, 'nvim-treesitter.configs')
end

if not ok then
  vim.schedule(function()
    vim.notify('nvim-treesitter config module not available', vim.log.levels.WARN)
  end)
  return
end

ts.setup({
  ensure_installed = {
    'javascript',
    'typescript',
    'python',
    'c',
    'lua',
    'vim',
    'vimdoc',
    'query',
    'markdown',
    'markdown_inline',
  },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})
