local default_base = "main"

-- neo-tree skips recomputing the diff against the base whenever `git status` output is unchanged
-- (git/init.lua), so a base switch on a clean tree would never show. The cache is a private
-- upvalue with no invalidation API, hence the debug lookup.
local function forget_cached_status(worktree_root)
	local status = require("neo-tree.git").status
	for i = 1, 20 do
		local name, cache = debug.getupvalue(status, i)
		if not name then
			return
		end
		if name == "raw_status_text_cache" then
			cache[worktree_root] = nil
			return
		end
	end
end

-- Writes the base into neo-tree's state instead of going through its command, because the command
-- always opens the window. Marking the state dirty makes the next open re-read git, and an
-- already visible tree is re-rendered right away.
local function set_tree_base(base)
	local manager = require("neo-tree.sources.manager")
	local state = manager.get_state("git_status")
	local worktree_root = require("neo-tree.git").find_worktree_info(vim.fn.getcwd())
	if not worktree_root then
		return
	end
	state.git_base_by_worktree = state.git_base_by_worktree or {}
	state.git_base_by_worktree[worktree_root] = base
	forget_cached_status(worktree_root)
	state.dirty = true
	if state.path and require("neo-tree.ui.renderer").window_exists(state) then
		manager.navigate(state, state.path)
	end
end

-- gitsigns and neo-tree keep their base independently, so both have to be switched together
-- to avoid the signs and the tree disagreeing about what "changed" means.
local function set_base(base)
	require("gitsigns").change_base(base, true)
	set_tree_base(base or "HEAD")
	vim.notify("Git base: " .. (base or "index"))
end

local function pick_base()
	local refs = vim.fn.systemlist({
		"git",
		"for-each-ref",
		"--sort=-committerdate",
		"--format=%(refname:short)",
		"refs/heads",
		"refs/remotes",
	})
	if vim.v.shell_error ~= 0 then
		vim.notify("Not in a git repository", vim.log.levels.WARN)
		return
	end
	vim.ui.select(refs, { prompt = "Git base" }, function(choice)
		if choice then
			set_base(choice)
		end
	end)
end

return {
	{
		"lewis6991/gitsigns.nvim",
		keys = {
			{
				"<leader>gm",
				function()
					set_base(default_base)
				end,
				desc = "Git Base: " .. default_base,
			},
			{ "<leader>gM", pick_base, desc = "Git Base: Pick Branch" },
			{
				"<leader>gR",
				function()
					set_base(nil)
				end,
				desc = "Git Base: Reset",
			},
		},
	},
}
