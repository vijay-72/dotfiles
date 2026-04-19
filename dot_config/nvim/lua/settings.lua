vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.signcolumn = "yes"
vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode

vim.opt.splitbelow = true
vim.opt.splitright = true

-- tells how tabs will be rendered (no of columns), no effect on the text itself
vim.opt.tabstop = 2
-- this actually replaces tab with spaces in insert mode, no more tabs
vim.opt.expandtab = true
vim.opt.shiftwidth = 2 -- when we use indent (>>) and de-dent(<<) use 4 spaces, used by smartindent

vim.opt.wrap = false
vim.opt.scrolloff = 999

vim.opt.termguicolors = true

vim.opt.inccommand = "split"

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.hlsearch = true -- clear hl on esc

vim.opt.conceallevel = 1

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.undofile = true

vim.o.winborder = "rounded"

-- Disable health checks for these providers.
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
