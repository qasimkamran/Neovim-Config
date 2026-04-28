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
    vim.keymap.set({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end, opts)
    vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
end

local function configure(server, overrides)
    overrides = overrides or {}
    overrides.on_attach = overrides.on_attach or on_attach
    overrides.capabilities = overrides.capabilities or default_capabilities
    vim.lsp.config(server, overrides)
    vim.lsp.enable(server)
end

-- clangd for C/C++ files
configure('clangd', {
    cmd = { 'clangd' },
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local root = vim.fs.root(fname, { 'compile_commands.json', '.git' })
        on_dir(root or vim.fn.fnamemodify(fname, ':h'))
    end,
})

-- ts_ls for JavaScript/TypeScript
configure('ts_ls')

-- lua_ls for Lua files
configure('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false,
            },
            completion = {
                callSnippet = 'Replace',
            },
            telemetry = { enable = false },
        },
    },
})

-- cssls for CSS/SCSS files
configure('cssls')

local venv_python = vim.fn.getcwd() .. '/.venv/bin/python'
local python_path

if vim.fn.filereadable(venv_python) == 1 then
    python_path = venv_python
else
    python_path = '/usr/bin/python3'
end

-- pyright for Py files
configure('pyright', {
    settings = {
        python = {
            pythonPath = python_path,
        },
    },
})

-- Setup nvim-cmp for autocompletion
local cmp = require('cmp')
cmp.setup({
    sources = {
        { name = 'nvim_lsp', max_item_count = 10 },
        { name = 'buffer', max_item_count = 10 },
        { name = 'path', max_item_count = 10 },
    },
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
    experimental = {
        ghost_text = true,
    },
    mapping = cmp.mapping.preset.insert({
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.confirm({ select = true })
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
})

vim.diagnostic.config({
    virtual_text = {
        prefix = '●',
        spacing = 2,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
})
