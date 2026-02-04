return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			local tn = require("tokyonight")

			local profiles = {
				opaque = {
					style = "night",
					transparent = false,
					styles = {
						sidebars = "dark",
						floats = "dark",
					},
				},
				transparent = {
					style = "night",
					transparent = true,
					styles = {
						sidebars = "transparent",
						floats = "transparent",
					},
				},
			}

			-- Track current profile
			vim.g.tokyonight_profile = vim.g.tokyonight_profile or "opaque"

			local function apply(profile_name)
				vim.g.tokyonight_profile = profile_name
				tn.setup(profiles[profile_name])
				vim.cmd.colorscheme("tokyonight")
			end

			-- Apply initial profile on startup
			apply(vim.g.tokyonight_profile)

			-- User commands
			vim.api.nvim_create_user_command("TokyoNightOpaque", function()
				apply("opaque")
			end, {})

			vim.api.nvim_create_user_command("TokyoNightTransparent", function()
				apply("transparent")
			end, {})

			vim.api.nvim_create_user_command("TokyoNightToggleTransparent", function()
				if vim.g.tokyonight_profile == "transparent" then
					apply("opaque")
				else
					apply("transparent")
				end
			end, {})

			-- Optional keymap (pick whatever you like)
			vim.keymap.set(
				"n",
				"<leader>uB",
				"<cmd>TokyoNightToggleTransparent<cr>",
				{ desc = "Toggle TokyoNight transparency" }
			)
		end,
	},
}
