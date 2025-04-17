local uv = vim.loop
local last_mtime = 0

local function get_file_path()
  local base_path = vim.env.HOME .. "/.config/nvim/nvim_current_dir/"
  local bufs = vim.api.nvim_list_bufs()
  for _, buf in ipairs(bufs) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local ft = vim.api.nvim_buf_get_option(buf, "filetype")
      if ft == "toggleterm" then
        local ok, job_id = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")
        if ok and job_id then
          local job_pid = vim.fn.jobpid(job_id)
          if job_pid then
            return base_path .. job_pid
          end
        end
      end
    end
  end
end

local function update_cwd_from_terminal()
    file_path = get_file_path()
    if not file_path then
      return
    end
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

    vim.cmd("cd " .. vim.fn.fnameescape(new_dir))
    print("Working directory updated to: " .. new_dir)

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "netrw" then
            vim.api.nvim_win_call(win, function()
                vim.cmd("Rexplore")
            end)
            print("Netrw refreshed in window " .. win)
        elseif vim.bo[buf].filetype == "NvimTree" then
            vim.api.nvim_win_call(win, function()
                vim.cmd("NvimTreeRefresh")
            end)
            print("NvimTree refreshed in window " .. win)
        end
    end
end

vim.api.nvim_create_user_command("AutoChDir", update_cwd_from_terminal, {})

vim.api.nvim_create_autocmd("TermLeave", {
    callback = function()
        update_cwd_from_terminal()
    end,
})

