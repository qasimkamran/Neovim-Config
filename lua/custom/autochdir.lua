local uv = vim.loop
local file_path = vim.env.HOME .. "/.config/nvim/nvim_current_dir"
local last_mtime = 0

local function update_cwd_from_terminal()
    -- Check for file existence and modification time
    local stat = uv.fs_stat(file_path)
    if not stat or stat.mtime.sec <= last_mtime then
        return
    end
    last_mtime = stat.mtime.sec

    -- Open, read, and close the file using libuv
    local fd = uv.fs_open(file_path, "r", 438)  -- 438 == 0666 in octal
    if not fd then
        return
    end
    local data = uv.fs_read(fd, stat.size, 0)
    uv.fs_close(fd)
    if not data then
        return
    end

    local new_dir = vim.trim(data)
    if new_dir == "" then
        return
    end

    local current_cwd = vim.fn.getcwd()
    if new_dir == current_cwd then
        return
    end

    -- Change directory and refresh any netrw windows
    vim.cmd("cd " .. vim.fn.fnameescape(new_dir))
    print("Working directory updated to: " .. new_dir)

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "netrw" then
            vim.api.nvim_win_call(win, function()
                vim.cmd("Rexplore")
            end)
            print("Netrw refreshed in window " .. win)
        end
    end
end

local timer = uv.new_timer()
timer:start(0, 1000, vim.schedule_wrap(update_cwd_from_terminal))

