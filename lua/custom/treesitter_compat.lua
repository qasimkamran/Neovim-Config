-- Stub the legacy playground module so an outdated start plugin does not crash
-- startup against newer nvim-treesitter releases.
package.preload['nvim-treesitter-playground'] = function()
  return {
    init = function() end,
  }
end
