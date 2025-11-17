return {
	{
		"vitalk/vim-simple-todo",
		ft = "markdown",
		init = function()
			vim.g.simple_todo_map_keys = 0
		end,
		config = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					local opts = { buffer = true, silent = true }
					vim.keymap.set("n", "<leader>i", "<Plug>(simple-todo-new-start-of-line)", opts)
					vim.keymap.set("n", "<leader>o", "<Plug>(simple-todo-below)", opts)
					vim.keymap.set("n", "<leader>x", "<Plug>(simple-todo-mark-switch)", opts)
				end,
			})
		end,
	},
}
