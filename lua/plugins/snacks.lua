return {
	"snacks.nvim",
	opts = {
		dashboard = {
			preset = {
				header = [[
                                           __                   
                                          |  \                  
      _______   ______   ______  __     __ \▓▓______ ____       
     |       \ /      \ /      \|  \   /  \  \      \    \      
     | ▓▓▓▓▓▓▓\  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\\▓▓\ /  ▓▓ ▓▓ ▓▓▓▓▓▓\▓▓▓▓\     
     | ▓▓  | ▓▓ ▓▓    ▓▓ ▓▓  | ▓▓ \▓▓\  ▓▓| ▓▓ ▓▓ | ▓▓ | ▓▓     
     | ▓▓  | ▓▓ ▓▓▓▓▓▓▓▓ ▓▓__/ ▓▓  \▓▓ ▓▓ | ▓▓ ▓▓ | ▓▓ | ▓▓     
     | ▓▓  | ▓▓\▓▓     \\▓▓    ▓▓   \▓▓▓  | ▓▓ ▓▓ | ▓▓ | ▓▓     
      \▓▓   \▓▓ \▓▓▓▓▓▓▓ \▓▓▓▓▓▓     \▓    \▓▓\▓▓  \▓▓  \▓▓     
        ]],
			},
			sections = {
				{ section = "header" },
				{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 2 },
				{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 2 },
				{ icon = " ", title = "Bookmarks", section = "keys", padding = 1 },
				{
					icon = " ",
					desc = "Browse Repo",
					padding = 1,
					key = "b",
					action = function()
						Snacks.gitbrowse()
					end,
					enabled = function()
						return Snacks.git.get_root() ~= nil
					end,
				},
				{ section = "startup" },
			},
		},
	},
}
