-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- git mergetool exports these paths; using them avoids labelling unrelated `nvim -d` sessions
local function label_mergetool_windows()
  local labels = {
    LOCAL = "LOCAL (ours)",
    BASE = "BASE (common ancestor)",
    REMOTE = "REMOTE (theirs)",
    MERGED = "MERGED (edit this one)",
  }
  if not (vim.env.LOCAL and vim.env.BASE and vim.env.REMOTE and vim.env.MERGED) then
    return
  end

  for key, label in pairs(labels) do
    -- buffer names are symlink-resolved (e.g. /tmp -> /private/tmp on macOS)
    local target = vim.uv.fs_realpath(vim.env[key])
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local name = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)))
      if name and name == target then
        vim.wo[win].winbar = "%#Title# " .. label
      end
    end
  end
end

label_mergetool_windows()

-- 50/72 convention: subject line fits one-line log views, body stays readable in 80-col terminals
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("commit_message_ruler", { clear = true }),
  pattern = { "gitcommit", "jjdescription" },
  callback = function()
    vim.opt_local.number = true
    vim.opt_local.ruler = true
    vim.opt_local.colorcolumn = { 50, 72 }
    vim.opt_local.textwidth = 72
  end,
})
