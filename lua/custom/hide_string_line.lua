local hidden,removed = false, {}

function toggle_hide_string_line()
    if not hidden then
        local pattern = vim.fn.input('Enter string: ')
        if pattern == '' then return end
        removed = {}
        for i = vim.api.nvim_buf_line_count(0), 1, -1 do
            local line = vim.api.nvim_buf_get_lines(0, i-1, i, false)[1]
            if line:find(pattern, 1, true) then
                local prev = (i > 1)
                and vim.api.nvim_buf_get_lines(0, i-2, i-1, false)[1]
                or nil

                local after = (i < 1)
                and vim.api.nvim_buf_get_lines(0, i, i+1, false)[1]
                or nil

                local function is_blank(str)
                    return not str or str:match('^%s*$')
                end

                if is_blank(prev) and is_blank(after) then
                    table.insert(removed, {i-1, prev})
                    table.insert(removed, {i,   line})
                    vim.api.nvim_buf_set_lines(0, i-2, i, false, {})
                else
                    table.insert(removed, {i, line})
                    vim.api.nvim_buf_set_lines(0, i-1, i, false, {})
                end
            end
        end
        hidden = true
    else
        table.sort(removed, function(a,b) return a[1] < b[1] end)
        for _, entry in ipairs(removed) do
            vim.api.nvim_buf_set_lines(0, entry[1]-1, entry[1]-1, false, {entry[2]})
        end
        hidden = false
    end
end

vim.api.nvim_create_user_command("HideStringLine", toggle_hide_string_line, {})

