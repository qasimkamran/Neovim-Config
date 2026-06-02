-- Stub the legacy playground module so an outdated start plugin does not crash
-- startup against newer nvim-treesitter releases.
package.preload['nvim-treesitter-playground'] = function()
  return {
    init = function() end,
  }
end

-- Restore parsers.ft_to_lang for plugins that still expect the legacy
-- nvim-treesitter API, such as older telescope previewer code.
do
  local ok, parsers = pcall(require, 'nvim-treesitter.parsers')
  if ok and type(parsers.ft_to_lang) ~= 'function' then
    parsers.ft_to_lang = function(filetype)
      if not filetype or filetype == '' then
        return nil
      end

      if vim.treesitter and vim.treesitter.language and vim.treesitter.language.get_lang then
        return vim.treesitter.language.get_lang(filetype)
      end

      return filetype
    end
  end
end
