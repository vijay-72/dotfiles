return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	build = ":TSUpdate",
	event = { "BufNewFile", "BufReadPost" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},

	config = function()
		local treesitter = require("nvim-treesitter.configs")

		treesitter.setup({
			ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
			auto_install = true,
			highlight = {
				enable = true,
			},
		})

		vim.filetype.add({
			pattern = {
				[".*/waybar/config"] = "jsonc",
				[".*/dunst/dunstrc"] = "dosini",
				[".*/kitty/.+%.conf"] = "bash",
				[".*/hypr/.+%.conf"] = "hyprlang",
				["%.env%.[%w_.-]+"] = "sh",
			},
		})
	end,
}
