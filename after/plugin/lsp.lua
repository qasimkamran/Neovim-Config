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

-- lua_ls for Lua files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "lua" },
    callback = function()
        require('lspconfig').lua_ls.setup({
            on_attach = on_attach,
            capabilities = default_capabilities,
        })
    end,
})

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

--- pyright helper code

local util = require 'lspconfig.util'

local root_files = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    'pyrightconfig.json',
    '.git',
}

local function organize_imports()
    local params = {
        command = 'pyright.organizeimports',
        arguments = { vim.uri_from_bufnr(0) },
    }

    local clients = util.get_lsp_clients {
        bufnr = vim.api.nvim_get_current_buf(),
        name = 'pyright',
    }
    for _, client in ipairs(clients) do
        client.request('workspace/executeCommand', params, nil, 0)
    end
end

local function set_python_path(path)
    local clients = util.get_lsp_clients {
        bufnr = vim.api.nvim_get_current_buf(),
        name = 'pyright',
    }
    for _, client in ipairs(clients) do
        if client.settings then
            client.settings.python = vim.tbl_deep_extend('force', client.settings.python, { pythonPath = path })
        else
            client.config.settings = vim.tbl_deep_extend('force', client.config.settings, { python = { pythonPath = path } })
        end
        client.notify('workspace/didChangeConfiguration', { settings = nil })
    end
end

local function get_python_path(workspace)
    local venv_names = { 'venv', '.venv', 'env', '.env' }
    for _, venv in ipairs(venv_names) do
        local venv_path = util.path.join(workspace, venv)
        if util.path.exists(venv_path) then
            local python_path = util.path.join(venv_path, 'bin', 'python3')
            if util.path.exists(python_path) then
                print(python_path)
                return python_path
            end
        end
    end
end

-- pyright for Py files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python" },
    callback = function()
        require('lspconfig').pyright.setup({
            cmd = { 'pyright-langserver', '--stdio' },
            root_dir = function(fname)
                return util.root_pattern(
                'pyproject.toml',
                'setup.py',
                'setup.cfg',
                'requirements.txt',
                'Pipfile',
                'pyrightconfig.json',
                '.git'
                )(fname)
                or util.find_git_ancestor(fname)
                or vim.loop.cwd()
            end,
            single_file_support = true,
            settings = {
                python = {
                    pythonPath = get_python_path(vim.fn.getcwd()),
                    analysis = {
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        diagnosticMode = 'openFilesOnly',
                    },
                },
            },
            commands = {
                PyrightOrganizeImports = {
                    organize_imports,
                    description = 'Organize Imports',
                },
                PyrightSetPythonPath = {
                    set_python_path,
                    description = 'Reconfigure pyright with the provided python path',
                    nargs = 1,
                    complete = 'file',
                },
            },
        })
    end,
})

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

