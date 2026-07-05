return {
	cmd = { "vtsls", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_dir = function(bufnr, cb)
		local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))

		local ts_root = vim.fs.find("tsconfig.json", { upward = true, path = fname })[1]
		local git_root = vim.fs.find(".git", { upward = true, path = fname })[1]

		if git_root then
			cb(vim.fn.fnamemodify(git_root, ":h"))
		elseif ts_root then
			cb(vim.fn.fnamemodify(ts_root, ":h"))
		end
	end,
	settings = {
		complete_function_calls = true,
		vtsls = {
			autoUseWorkspaceTsdk = true,
			-- Enables the "Move to file" refactor code action.
			enableMoveToFileCodeAction = true,
			experimental = {
				maxInlayHintLength = 30,
				-- For completion performance.
				completion = {
					enableServerSideFuzzyMatch = true,
				},
			},
		},
		typescript = {
			-- Rewrite import paths automatically when a file is moved/renamed.
			updateImportsOnFileMove = { enabled = "always" },
			suggest = { completeFunctionCalls = true },
			inlayHints = {
				enumMemberValues = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				parameterNames = { enabled = "literals" },
				parameterTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				variableTypes = { enabled = true }, -- `const x: T`; set false if too noisy
			},
		},
		javascript = {
			updateImportsOnFileMove = { enabled = "always" },
			inlayHints = {
				enumMemberValues = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				parameterNames = { enabled = "literals" },
				parameterTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				variableTypes = { enabled = true },
			},
		},
	},
}
