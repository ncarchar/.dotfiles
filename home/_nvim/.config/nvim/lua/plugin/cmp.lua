return { -- Autocompletion
	"saghen/blink.cmp",
	event = "VimEnter",
	version = "1.*",
	dependencies = {
		"folke/lazydev.nvim",
	},
	opts = {
		keymap = {
			preset = "default",
		},

		appearance = {
			nerd_font_variant = "mono",
		},

		completion = {
			documentation = { auto_show = false, auto_show_delay_ms = 500 },
		},
		sources = {
			default = { "lsp", "path", "lazydev" },
			providers = {
				lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
			},
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
		signature = { enabled = true },
	},
}
-- {
-- 	{
-- 		"hrsh7th/nvim-cmp",
-- 		event = "InsertEnter",
-- 		dependencies = {
-- 			"hrsh7th/cmp-nvim-lsp",
-- 			"hrsh7th/cmp-path",
-- 		},
-- 		config = function()
-- 			local cmp = require("cmp")
-- 			local lspkind = require("lspkind")
-- 			cmp.setup({
-- 				formatting = {
-- 					format = lspkind.cmp_format({
-- 						mode = "symbol_text",
-- 						maxwidth = 28,
-- 						ellipsis_char = "",
-- 					}),
-- 					expandable_indicator = true,
-- 					fields = { "abbr", "menu", "kind" },
-- 				},
-- 				completion = {
-- 					-- autocomplete = false,
-- 				},
-- 				mapping = cmp.mapping.preset.insert({
-- 					["<C-Down>"] = cmp.mapping.complete(),
-- 					["<CR>"] = cmp.mapping.confirm({
-- 						select = true,
-- 					}),
-- 					["<C-n>"] = cmp.mapping(function(fallback)
-- 						if cmp.visible() then
-- 							cmp.close()
-- 						else
-- 							fallback()
-- 						end
-- 					end, { "i", "s" }),
-- 				}),
-- 				sources = {
-- 					{ name = "nvim_lsp" },
-- 					{ name = "path" },
-- 				},
-- 			})
-- 		end,
-- 	},
-- }
