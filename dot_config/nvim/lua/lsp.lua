local servers = {}
local path = vim.fn.stdpath("config") .. "/lsp"
for name, _ in vim.fs.dir(path) do
	table.insert(servers, vim.fn.fnamemodify(name, ":r"))
end
vim.lsp.enable(servers)
