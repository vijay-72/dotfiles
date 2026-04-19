-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- General setup
require("settings")
require("autocmds")
require("lsp")
require("keymaps").setup.regular()

require("lazy").setup({
	ui = { border = "rounded" },
	spec = {
		{ import = "plugins" },
	},
	change_detection = { notify = false },
	rocks = {
		enabled = false,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"netrwPlugin",
				"rplugin",
				"tarPlugin",
				"tohtml",
				"zipPlugin",
			},
		},
	},
})
