local function toggle_hg_blame()
  local buf = vim.api.nvim_get_current_buf()
  local ns = vim.api.nvim_create_namespace("hg_blame")

  vim.api.nvim_set_hl(0, "BlameColor", { fg = "#D2B816" })

  local extmarks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
  if #extmarks > 0 then
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    print("hg blame cleared")
    return
  end

  local file = vim.fn.expand('%:p')
  if file == '' then
    print("No file loaded")
    return
  end

  local cmd = "hg blame " .. vim.fn.shellescape(file)
  local blame_lines = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    print("Error running hg blame")
    return
  end

  for i, line in ipairs(blame_lines) do
    local header = line:match("^(.-):")
    if header then
      vim.api.nvim_buf_set_extmark(buf, ns, i - 1, -1, {
        virt_text = { { header, "BlameColor" } },
        virt_text_pos = "eol",
        hl_mode = "combine",
      })
    end
  end

  print("hg blame applied")
end

vim.api.nvim_create_user_command("HgBlame", toggle_hg_blame, {})

