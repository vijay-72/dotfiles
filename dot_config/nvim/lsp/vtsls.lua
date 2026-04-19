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
		vtsls = {
			autoUseWorkspaceTsdk = true,
			experimental = {
				maxInlayHintLength = 30,
				-- For completion performance.
				completion = {
					enableServerSideFuzzyMatch = true,
				},
			},
		},
	},
}
