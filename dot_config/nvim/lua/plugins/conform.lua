return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	opts = {
		notify_on_error = false,
		notify_no_formatters = false,
		formatters_by_ft = {
			cpp = { "clang-format" },
			javascript = { "prettierd" },
			typescript = { "prettierd" },
			javascriptreact = { "prettierd" },
			typescriptreact = { "prettierd" },
			css = { "prettierd" },
			html = { "prettierd" },
			json = { "prettierd" },
			yaml = { "prettierd" },
			markdown = { "prettierd" },
			lua = { "stylua" },
			bash = { "shfmt" },
			-- filetypes without a formatter
			["_"] = { "trim_whitespace", "trim_newlines" },
		},
		format_on_save = function(bufnr)
			local disable_filetypes = { c = true, cpp = true }
			return {
				timeout_ms = 500,
				lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
			}
		end,
	},
}
