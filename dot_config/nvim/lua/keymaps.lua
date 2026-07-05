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
        { "gd",        function() fzf.lsp_definitions({ jump1=true }) end,  { desc = "(LSP) Definition" } },
        { "gD",        function() fzf.lsp_definitions({ jump1=false }) end, { desc = "(LSP) Peek definition" } },
        { "gy",        fzf.lsp_typedefs,                                  { desc = "(LSP) Type definition" } },
        { "K",         lsp.hover,                                         { desc = "(LSP) Hover" } },
        { "gi",        fzf.lsp_implementations,                           { desc = "(LSP) Implementation" } },
        { "gk",        lsp.signature_help,                                { desc = "(LSP) Signature help" } },
        { "gr",        fzf.lsp_references,                                { desc = "(LSP) References" } },
        { "<leader>ca", lsp.code_action,                                  { desc = "(LSP) Code action" } },
    }}, opts)

		-- Inlay hints: show in normal mode, auto-hide while typing (insert mode),
		-- for any server that supports them. Master switch is vim.g.inlay_hints;
		-- <leader>th flips it. (Generic, not TS-only.)
		if client:supports_method("textDocument/inlayHint") then
			if vim.g.inlay_hints == nil then
				vim.g.inlay_hints = true
			end
			local function refresh()
				local insert = vim.startswith(vim.api.nvim_get_mode().mode, "i")
				vim.lsp.inlay_hint.enable(vim.g.inlay_hints and not insert, { bufnr = bufnr })
			end
			-- Slight delay: hints sometimes don't render on the very first attach.
			vim.defer_fn(function()
				if vim.api.nvim_buf_is_valid(bufnr) then
					refresh()
				end
			end, 200)

			vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
				group = vim.api.nvim_create_augroup("user_inlay_hints", { clear = false }),
				buffer = bufnr,
				desc = "Hide inlay hints while typing",
				callback = refresh,
			})

			vim.keymap.set("n", "<leader>th", function()
				vim.g.inlay_hints = not vim.g.inlay_hints
				vim.lsp.inlay_hint.enable(vim.g.inlay_hints, { bufnr = bufnr })
			end, { buffer = bufnr, silent = true, desc = "(LSP) Toggle inlay hints" })
		end

		-- TypeScript/JavaScript-specific (vtsls) bindings. These only attach to
		-- JS/TS buffers and override a few generic maps (e.g. gd -> source
		-- definition) where vtsls has a smarter, language-aware command.
		if client.name == "vtsls" then
			local function exec(command, arguments, on_result)
				client:exec_cmd({ command = command, arguments = arguments }, { bufnr = bufnr }, on_result)
			end

			-- gd: jump straight to the real source, skipping `.d.ts` type stubs.
			-- Falls back to the normal definition when no source definition exists.
			local function goto_source_definition()
				local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
				exec("typescript.goToSourceDefinition", { params.textDocument.uri, params.position }, function(err, result)
					if err or type(result) ~= "table" or vim.tbl_isempty(result) then
						require("fzf-lua").lsp_definitions({ jump1 = true })
						return
					end
					vim.lsp.util.show_document(result[1], client.offset_encoding, { focus = true })
				end)
			end

			-- gR: every file that imports THIS file -> quickfix list.
			local function file_references()
				exec("typescript.findAllFileReferences", { vim.uri_from_bufnr(bufnr) }, function(err, result)
					if err or type(result) ~= "table" or vim.tbl_isempty(result) then
						vim.notify("vtsls: no file references found", vim.log.levels.WARN)
						return
					end
					local items = vim.lsp.util.locations_to_items(result, client.offset_encoding)
					vim.fn.setqflist({}, " ", { title = "TS File References", items = items })
					vim.cmd("botright copen")
				end)
			end

			-- Run a single named code-action source directly, skipping the menu.
			local function code_action(kind)
				return function()
					vim.lsp.buf.code_action({ context = { only = { kind }, diagnostics = {} }, apply = true })
				end
			end

      -- stylua: ignore
      map({ [{ "n" }] = {
          { "gd",         goto_source_definition,                       { desc = "(TS) Goto source definition" } },
          { "gR",         file_references,                              { desc = "(TS) File references -> quickfix" } },
          { "<leader>co", code_action("source.organizeImports"),        { desc = "(TS) Organize imports" } },
          { "<leader>cM", code_action("source.addMissingImports.ts"),   { desc = "(TS) Add missing imports" } },
          { "<leader>cu", code_action("source.removeUnused.ts"),        { desc = "(TS) Remove unused" } },
          { "<leader>cF", code_action("source.fixAll.ts"),              { desc = "(TS) Fix all" } },
          { "<leader>cV", function() exec("typescript.selectTypeScriptVersion", nil) end, { desc = "(TS) Select TS version" } },
      }}, opts)
		end
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
