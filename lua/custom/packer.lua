vim.cmd [[packadd packer.nvim]]

local has_nvim_010 = vim.fn.has('nvim-0.10') == 1

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

use({
	'nvim-treesitter/nvim-treesitter',
	branch = 'main',
	run = ':TSUpdate',
})

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

-- use('~/Projects/Live-TPL/sharebuf_shm')

use({
    'MeanderingProgrammer/render-markdown.nvim',
    cond = has_nvim_010,
    after = { 'nvim-treesitter' },
    requires = {
        { 'nvim-mini/mini.nvim', opt = true },      -- if you use the mini.nvim suite
        { 'nvim-mini/mini.icons', opt = true },     -- if you use standalone mini plugins
    },
    -- requires = { 'nvim-tree/nvim-web-devicons', opt = true }, -- if you prefer nvim-web-devicons
    config = function()
        if not has_nvim_010 then
            return
        end

        require('render-markdown').setup({
            render_modes = { 'n', 'i', 'c', 't' },
            heading = {
                enabled = true,
                render_modes = false,
                sign = true,
                icons = { '# ', '## ', '### ', '#### ', '##### ', '###### ' },
                signs = { '> ' },
                width = 'full',
                border = false,
                border_virtual = true,
                border_prefix = false,
                above = '-',
                below = '-',
                backgrounds = {
                    'RenderMarkdownH1Bg',
                    'RenderMarkdownH2Bg',
                    'RenderMarkdownH3Bg',
                    'RenderMarkdownH4Bg',
                    'RenderMarkdownH5Bg',
                    'RenderMarkdownH6Bg',
                },
                foregrounds = {
                    'RenderMarkdownH1',
                    'RenderMarkdownH2',
                    'RenderMarkdownH3',
                    'RenderMarkdownH4',
                    'RenderMarkdownH5',
                    'RenderMarkdownH6',
                },
            },
            code = {
                enabled = true,
                render_modes = false,
                sign = true,
                style = 'full',
            },
            dash = { enabled = true },
            bullet = { enabled = true },
            checkbox = { enabled = true },
            quote = { enabled = true },
            link = { enabled = true },
        })

        vim.api.nvim_create_autocmd('FileType', {
            pattern = 'markdown',
            callback = function()
                require('render-markdown').buf_enable()
            end,
        })

        local function set_markdown_highlights()
            local set = vim.api.nvim_set_hl

            -- Headings: varied styles to simulate "size" hierarchy.
            set(0, 'RenderMarkdownH1', { bold = true, underline = true })
            set(0, 'RenderMarkdownH2', { bold = true })
            set(0, 'RenderMarkdownH3', { bold = true, italic = true })
            set(0, 'RenderMarkdownH4', { italic = true })
            set(0, 'RenderMarkdownH5', { italic = true, undercurl = true })
            set(0, 'RenderMarkdownH6', { italic = true })

            -- Background accents for heading rows.
            set(0, 'RenderMarkdownH1Bg', { link = 'DiffText' })
            set(0, 'RenderMarkdownH2Bg', { link = 'DiffAdd' })
            set(0, 'RenderMarkdownH3Bg', { link = 'DiffChange' })
            set(0, 'RenderMarkdownH4Bg', { link = 'DiffDelete' })
            set(0, 'RenderMarkdownH5Bg', { link = 'Visual' })
            set(0, 'RenderMarkdownH6Bg', { link = 'CursorColumn' })

            -- Inline styles.
            set(0, '@markup.strong', { bold = true })
            set(0, '@markup.emphasis', { italic = true })
            set(0, '@markup.strikethrough', { strikethrough = true })

            -- Code highlights.
            set(0, 'RenderMarkdownCode', { link = 'ColorColumn' })
            set(0, 'RenderMarkdownCodeInline', { link = 'Visual' })
        end

        set_markdown_highlights()
        vim.api.nvim_create_autocmd('ColorScheme', {
            callback = set_markdown_highlights,
        })
    end,
})

end)
