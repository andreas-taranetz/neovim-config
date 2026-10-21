-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "X", function() Snacks.bufdelete() end, { desc = "Delete Buffer" })

local test_markers = { "test", "spec" }

-- An implementation can have either a .test. or a .spec. sibling, so we return all candidates
-- and let the caller pick whichever exists.
local function counterpart_candidates(file)
	for _, marker in ipairs(test_markers) do
		local base, ext = file:match("^(.*)%." .. marker .. "%.([^./]+)$")
		if base then
			return { base .. "." .. ext }
		end
	end
	local base, ext = file:match("^(.*)%.([^./]+)$")
	if not base then
		return {}
	end
	return vim.tbl_map(function(marker)
		return base .. "." .. marker .. "." .. ext
	end, test_markers)
end

vim.keymap.set("n", "<leader>tf", function()
	local candidates = counterpart_candidates(vim.fn.expand("%:p"))
	local target = vim.iter(candidates):find(function(path)
		return vim.uv.fs_stat(path) ~= nil
	end)
	if target then
		vim.cmd.edit(target)
	else
		local names = vim.tbl_map(function(path)
			return vim.fn.fnamemodify(path, ":t")
		end, candidates)
		vim.notify("No counterpart found: " .. table.concat(names, ", "), vim.log.levels.WARN)
	end
end, { desc = "Switch implementation <-> test file" })
