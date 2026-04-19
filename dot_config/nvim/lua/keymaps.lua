local M = {}

local function map(keymaps, default_opts, lazy)
	default_opts = default_opts or {}
	lazy = lazy or false
	local lazy_mappings = {}
	for modes, mappings in pairs(keymaps) do
		for _, mapping in pairs(mappings) do
			local key, action, options = unpack(mapping)

			-- Combine default options with mapping options
			local combined_opts = vim.tbl_extend("force", default_opts, options or {})

			if lazy then
				table.insert(lazy_mappings, vim.tbl_extend("force", { key, action, mode = modes }, combined_opts))
				-- lazy_mappings[#lazy_mappings + 1] = {
				-- 	key,
				-- 	action,
				-- 	mode = modes,
				-- 	combined_opts,
				-- }
			else
				vim.keymap.set(modes, key, action, combined_opts)
			end
		end
	end
	return lazy_mappings
end

M.setup = {
	regular = function()
		local autoindent = function(key)
			return function()
				return not vim.api.nvim_get_current_line():match("%g") and "cc" or key
			end
		end

		map({
			[{ "n" }] = {

				--To get indent when going from normal to insert on blank line also
				{ "I", autoindent("I"), { expr = true } },
				{ "i", autoindent("i"), { expr = true } },
				{ "a", autoindent("a"), { expr = true } },
				{ "A", autoindent("A"), { expr = true } },

				--Window movements
				{ "<C-j>", "<C-w><C-j>" },
				{ "<C-k>", "<C-w><C-k>" },
				{ "<C-l>", "<C-w><C-l>" },
				{ "<C-h>", "<C-w><C-h>" },
				{ "<leader>Y", [["+Y]] },
			},

			[{ "n", "v" }] = {
				--System clipboard yank
				{ "<leader>y", [["+y]] },
			},

			[{ "v" }] = {
				{ "J", ":m '>+1<CR>gv=gv" },
				{ "K", ":m '<-2<CR>gv=gv" },
			},
		}, { silent = true })
	end,

	conform = function(opts)
		return map({
			[{ "n" }] = {
				{
					"<leader>f",
					function()
						require("conform").format({ async = true, lsp_fallback = true })
					end,
				},
			},
		}, {}, opts)
	end,

	fzf = function(opts)
		return map({
      -- stylua: ignore
			[{ "n" }] = {
				{ "<leader><CR>", function() require("fzf-lua").builtin() end, { desc = "(FZF) Builtin", remap = false } },
				{ "<leader><leader>", function() require("fzf-lua").buffers() end, { desc = "(FZF) Buffers" } },
				{ "<leader>ff", function() require("fzf-lua").files() end, { desc = "(FZF) [F]ind [F]iles" } },
				{ "<leader>f/", function() require("fzf-lua").current_buffer_fuzzy_find() end, { desc = "(FZF) Fuzzy find in buffer" } },
				{ "<leader>fh", function() require("fzf-lua").help_tags() end, { desc = "(FZF) [F]ind in [H]elp" } },
				{ "<leader>fg", function() require("fzf-lua").live_grep() end, { desc = "(FZF) [F]ind with live [G]rep" } },
				{ "<leader>f?", function() require("fzf-lua").oldfiles() end, { desc = "(FZF) Oldfiles" } },
				{ "<leader>fr", function() require("fzf-lua").resume() end, { desc = "(FZF) Resume last command" } },
			},
		}, {}, opts)
	end,

	lsp = function(client, bufnr)
		local lsp = vim.lsp.buf
		local fzf = require("fzf-lua")
		local opts = { remap = false, silent = true, buffer = bufnr }
    -- stylua: ignore
    map({ [{ "n" }] = {
        { "gD",        fzf.lsp_declarations,                             { desc = "(LSP) Declaration" } },
        { "gd",        function() fzf.lsp_definitions({ jump1=true }) end, { desc = "(LSP) Definition" } },
        { "K",         lsp.hover,                                         { desc = "(LSP) Hover" } },
        { "gi",        fzf.lsp_implementations,                           { desc = "(LSP) Implementation" } },
        { "gk",        lsp.signature_help,                                { desc = "(LSP) Signature help" } },
        { "gr",        fzf.lsp_references,                                { desc = "(LSP) References" } },
        { "<leader>ca", lsp.code_action,                                  { desc = "(LSP) Code action" } },
    }}, opts)
	end,
}

M.treesitter = {
	incremental_selection = {
		keymaps = {
			init_selection = "<leader>ss",
			node_incremental = "<leader>si",
			scope_incremental = "<leader>sc",
			node_decremental = "<leader>sd",
		},
	},

	textsubjects = {
		keymaps = {
			["."] = "textsubjects-smart",
			["a."] = "textsubjects-container-outer",
			["i."] = "textsubjects-container-inner",
		},
	},
	textobjects = {
		keymaps = {
			-- You can use the capture groups defined in textobjects.scm
			["af"] = "@function.outer",
			["if"] = "@function.inner",
			["ac"] = "@class.outer",
			["ic"] = "@class.inner",
		},
	},
	swap = {
		swap_next = {
			["<leader>a"] = "@parameter.inner",
		},
		swap_previous = {
			["<leader>A"] = "@parameter.inner",
		},
	},
	move = {
		goto_next_start = {
			["]m"] = "@function.outer",
			["]]"] = "@class.outer",
		},
		goto_next_end = {
			["]M"] = "@function.outer",
			["]["] = "@class.outer",
		},
		goto_previous_start = {
			["[m"] = "@function.outer",
			["[["] = "@class.outer",
		},
		goto_previous_end = {
			["[M"] = "@function.outer",
			["[]"] = "@class.outer",
		},
	},
}

return M
