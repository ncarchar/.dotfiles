return {
	"lewis6991/gitsigns.nvim",
	opts = {
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "?" },
			changedelete = { text = "~" },
		},
		on_attach = function(bufnr)
			vim.keymap.set("n", "<leader>gp", function()
				require("gitsigns").nav_hunk("next")
			end, { buffer = bufnr, desc = "[G]o to [P]revious Hunk" })
			vim.keymap.set("n", "<leader>gn", function()
				require("gitsigns").nav_hunk("next")
			end, { buffer = bufnr, desc = "[G]o to [N]ext Hunk" })
		end,
	},
}
