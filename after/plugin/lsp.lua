-- Reserve a space in the gutter to avoid layout shifts
vim.opt.signcolumn = 'yes'

-- Create and store LSP capabilities once using cmp_nvim_lsp
local cmp_nvim_lsp = require('cmp_nvim_lsp')
local default_capabilities = cmp_nvim_lsp.default_capabilities()

-- Shared on_attach function to map LSP-related keybindings
local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr }
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
    vim.keymap.set({'n', 'x'}, '<F3>', function() vim.lsp.buf.format({ async = true }) end, opts)
    vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
end

-- Lazy-load LSP servers based on filetype via autocommands

-- clangd for C/C++ files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp", "h" },
    callback = function()
        require('lspconfig').clangd.setup({
            cmd = { "clangd", "--compile-commands-dir=/home/data/dm1948/source" },
            root_dir = function(fname)
                local util = require("lspconfig.util")
                return util.root_pattern("compile_commands.json", ".git")(fname) or util.path.dirname(fname)
            end,
            on_attach = on_attach,
            capabilities = default_capabilities,
        })
    end,
})

-- ts_ls for JavaScript/TypeScript
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "javascript", "typescript" },
    callback = function()
        require('lspconfig').ts_ls.setup({
            on_attach = on_attach,
            capabilities = default_capabilities,
        })
    end,
})

-- Common lazy_setup
local function lazy_setup(server_name, config, file_pattern)
  local lspconfig = require('lspconfig')
  vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    pattern = file_pattern,
    callback = function()
      if not lspconfig[server_name].manager then
        lspconfig[server_name].setup(config)
      end
    end,
  })
end

-- lua_ls for Lua files
lazy_setup("lua_ls", {
  on_attach = on_attach,
  capabilities = default_capabilities,
}, "*.lua")

-- cssls for CSS/SCSS files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "css", "scss" },
    callback = function()
        require('lspconfig').cssls.setup({
            on_attach = on_attach,
            capabilities = default_capabilities,
        })
    end,
})

-- pyright for Py files
lazy_setup("pyright", {
  on_attach = on_attach,
  capabilities = default_capabilities,
}, "*.py")

-- Setup nvim-cmp for autocompletion
local cmp = require('cmp')
cmp.setup({
    sources = {
        { name = 'nvim_lsp', max_item_count = 10 },
        { name = 'buffer',    max_item_count = 10 },
        { name = 'path',      max_item_count = 10 },
    },
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)  -- You need Neovim v0.10 to use vim.snippet
        end,
    },
    experimental = {
        ghost_text = true,
    },
    mapping = cmp.mapping.preset.insert({}),
})

