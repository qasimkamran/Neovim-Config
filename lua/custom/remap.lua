vim.g.mapleader = " "

vim.keymap.set('n', '<leader>b', function() vim.cmd("Ex") end)
vim.keymap.set('n', '<leader>qa', function() vim.cmd("qa") end)

vim.api.nvim_set_keymap('n', '<RightMouse>', '<Nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<RightMouse>', '<Nop>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<RightMouse>', '<Nop>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, {expr = true})
vim.keymap.set('n', '<leader>cc', '<leader>c_', {remap = true})
vim.keymap.set('v', '<leader>c', require('osc52').copy_visual)

vim.keymap.set('n', '<C-o>', '<C-t>', { noremap = true, silent = true })

function SwitchContext(forward)
    local buf_type = vim.bo.filetype

    if forward then
        if buf_type ~= "NvimTree" then
            vim.cmd("NvimTreeFocus")
        end
    else
        if buf_type == "NvimTree" then
            vim.cmd("wincmd p")
        end
    end
end

vim.api.nvim_set_keymap('n', '<C-Up>', ':lua SwitchContext(true)<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Down>', ':lua SwitchContext(false)<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>hb', ':HgBlame<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>t', ':GotoDef<CR>', { noremap = true, silent = true })
