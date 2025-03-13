vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.8',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
}

use({
	'projekt0n/github-nvim-theme',
	config = function()
		require('github-theme').setup({
			-- ...
		})
		vim.cmd('colorscheme github_dark_high_contrast')
	end
})

use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
use('nvim-treesitter/playground')

use "nvim-lua/plenary.nvim"
use {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	requires = { {"nvim-lua/plenary.nvim"} }
}

use('mbbill/undotree')

use({'neovim/nvim-lspconfig'})
use({'hrsh7th/nvim-cmp'})
use({'hrsh7th/cmp-nvim-lsp'})

use {
	"akinsho/toggleterm.nvim",
	tag = 'v2.*',
	config = function()
		require("toggleterm").setup{
			size = 12,
			open_mapping = [[<F12>]],
			shade_terminals = true,
			shading_factor = 2,
			start_in_insert = true,
			direction = "horizontal",
			persist_size = true,
		}
	end
}

use {
	'kyazdani42/nvim-tree.lua',
	requires = 'kyazdani42/nvim-web-devicons', -- optional, for file icons
	config = function()
		require("nvim-tree").setup {
			view = {
				side = "left",
				width = 30,
			},
			filters = {
				dotfiles = true,
			},
			actions = {
				open_file = {
					quit_on_open = false,
				},
			},
		}
		vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
	end,
}

use('ojroques/nvim-osc52')

end)
