return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font, opts = { color_icons = false } },
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					if vim.fn.executable("make") ~= 1 then
						print("'make' not available cannot use fzf for telescope")
					end
					return vim.fn.executable("make") == 1
				end,
			},
		},
		config = function()
			local actions = require("telescope.actions")
			local telescope = require("telescope")

			telescope.setup({
				defaults = {
					mappings = {
						i = {
							["<C-u>"] = false,
							["<C-d>"] = false,
							["<C-j>"] = actions.move_selection_next,
							["<C-k>"] = actions.move_selection_previous,
							["<C-v>"] = actions.file_vsplit,
							["<C-x>"] = actions.file_split,
							["<C-q>"] = actions.smart_send_to_qflist,
							["<C-l>"] = actions.smart_add_to_qflist,
						},
					},
					winblend = 0,
					borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
				},
				pickers = {
					find_files = {
						hidden = true,
					},
					live_grep = {
						file_ignore_patterns = { "node_modules", ".git", ".angular", "dist", "target" },
						additional_args = function(_)
							return { "--hidden" }
						end,
					},
				},
				extensions = {
					["fzf"] = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			pcall(require("telescope").load_extension("fzf"))
			-- Highlighting
			vim.cmd([[
              highlight FloatBorder guifg=#808080 guibg=NONE
              highlight TelescopeBorder guifg=#808080
              highlight TelescopePromptBorder guifg=#808080
              highlight TelescopeResultsBorder guifg=#808080
              highlight TelescopePreviewBorder guifg=#808080
            ]])

			-- Function to center cursor after selection
			local telescope_and_center = function(telescope_func)
				return function()
					telescope_func()
					vim.cmd("normal! zz")
				end
			end

			-- Keymaps
			vim.keymap.set(
				"n",
				"<tab><tab>",
				telescope_and_center(function()
					require("telescope.builtin").git_files({ show_untracked = true })
				end),
				{ desc = "Search Git-tracked & Untracked Files" }
			)

			vim.keymap.set(
				"n",
				"<leader><leader>t",
				telescope_and_center(require("telescope.builtin").builtin),
				{ desc = "[T]elescope Builtins" }
			)
			vim.keymap.set(
				"n",
				"<leader>?",
				telescope_and_center(require("telescope.builtin").oldfiles),
				{ desc = "[?] Find recently opened files" }
			)
			vim.keymap.set(
				"n",
				"<leader>b",
				telescope_and_center(require("telescope.builtin").buffers),
				{ desc = "[ ] Find existing buffers" }
			)
			vim.keymap.set(
				"n",
				"<C-f>",
				telescope_and_center(require("telescope.builtin").current_buffer_fuzzy_find),
				{ desc = "[S]earch [B]uffer" }
			)
			vim.keymap.set(
				"n",
				"<leader>sf",
				telescope_and_center(require("telescope.builtin").find_files),
				{ desc = "[S]earch [F]iles" }
			)
			vim.keymap.set(
				"n",
				"<leader>sh",
				telescope_and_center(require("telescope.builtin").help_tags),
				{ desc = "[S]earch [H]elp" }
			)
			vim.keymap.set(
				"n",
				"<leader>sw",
				telescope_and_center(require("telescope.builtin").grep_string),
				{ desc = "[S]earch Current [W]ord" }
			)
			vim.keymap.set(
				"n",
				"<leader>sg",
				telescope_and_center(require("telescope.builtin").live_grep),
				{ desc = "[S]earch by [G]rep" }
			)
			vim.keymap.set(
				"n",
				"<leader>sd",
				telescope_and_center(require("telescope.builtin").diagnostics),
				{ desc = "[S]earch [D]iagnostics" }
			)
			vim.keymap.set(
				"n",
				"<leader>sk",
				telescope_and_center(require("telescope.builtin").keymaps),
				{ desc = "[S]earch [K]eymap" }
			)
			vim.keymap.set(
				"n",
				"<leader>gf",
				telescope_and_center(require("telescope.builtin").git_files),
				{ desc = "Search [G]it [F]iles" }
			)
			vim.keymap.set(
				"n",
				"<leader>gC",
				telescope_and_center(require("telescope.builtin").git_commits),
				{ desc = "[G]it [C]ommits All" }
			)
			vim.keymap.set(
				"n",
				"<leader>gc",
				telescope_and_center(require("telescope.builtin").git_bcommits),
				{ desc = "[G]it [C]ommits Buffer" }
			)
			vim.keymap.set(
				"n",
				"<leader>gb",
				telescope_and_center(require("telescope.builtin").git_branches),
				{ desc = "[G]it [B]ranches" }
			)
			vim.keymap.set(
				"n",
				"<leader>gs",
				telescope_and_center(require("telescope.builtin").git_status),
				{ desc = "[G]it [S]tatus" }
			)

			-- Custom TODO command
			vim.api.nvim_create_user_command("TODO", function()
				telescope_and_center(require("telescope.builtin").grep_string({
					prompt_title = "TODO",
					search = "TODO",
					use_regex = false,
					path_display = { "smart" },
				}))
			end, {})
		end,
	},
}
