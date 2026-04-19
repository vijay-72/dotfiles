return {
	"ibhagwan/fzf-lua",
	keys = require("keymaps").setup.fzf({ lazy = true }),
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")

		fzf.setup({
			fzf_opts = {
				["--layout"] = "reverse",
			},

			winopts = {
				preview = {
					default = "bat",
				},
			},
		})
	end,
}
