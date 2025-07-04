return {
	{
		"sbdchd/neoformat",
		lazy = true,
		event = "BufEnter",
		config = function()
			vim.g.neoformat_try_formatprg = 1

			-- Check if an LSP formatter is available
			local function lsp_formatter_available()
				local clients = vim.lsp.get_clients()
				for _, client in ipairs(clients) do
					if client.supports_method and client:supports_method("textDocument/formatting") then
						return true
					end
				end
				return false
			end

			local function format_buffer()
				local filetype = vim.bo.filetype
				local use_lsp = { java = true, xml = true, sh = true }
				local remap_filetype = { ["htmlangular"] = "html" }

				filetype = remap_filetype[filetype] or filetype

				if use_lsp[filetype] and lsp_formatter_available() then
					vim.lsp.buf.format()
				else
					vim.cmd("Neoformat! " .. filetype)
				end
			end

			vim.keymap.set("n", "<leader>fl", format_buffer, { noremap = true, desc = "Format buffer" })
			vim.keymap.set(
				"v",
				"<leader>fh",
				":'<,'>!prettier --stdin-filepath % --parser html<CR>",
				{ noremap = true, desc = "[F]ormat [H]TML" }
			)
		end,
	},
}
