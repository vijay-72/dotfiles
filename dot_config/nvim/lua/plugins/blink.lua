return {
	"saghen/blink.cmp",
	version = "1.*",
	event = { "InsertEnter", "CmdwinEnter" },
	opts = {
		keymap = { preset = "default" },
		completion = {
			menu = {
				scrollbar = false,
				draw = {
					columns = {
						{ "kind_icon", "kind", gap = 1 },
						{ "label", "label_description", gap = 1 },
					},
				},
			},
			documentation = { auto_show = true },
		},

		sources = {
			default = { "lsp", "path", "buffer" },
		},

		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
}
