return {
	{
		"sbdchd/neoformat",
		lazy = true,
		event = "BufEnter",
		config = function()
			vim.g.neoformat_run_all_formatters = 0

			-- Check if an LSP formatter is available
			local function lsp_formatter_available(server_name)
				local clients = vim.lsp.get_clients()
				for _, client in ipairs(clients) do
					if client.name == server_name and client:supports_method("textDocument/formatting") then
						return true
					end
				end
				return false
			end

			-- filetype = formatter/lsp
			local CONFIG = {
				java = "jdtls",
				xml = "lemminx",
				sh = "bashls",
				typescript = "biome",
				javascript = "biome",
				json = "biome",
				htmlangular = "prettier",
			}

			local function format_buffer()
				local filetype = vim.bo.filetype
				local fmt = CONFIG[filetype]

				if fmt and lsp_formatter_available(fmt) then
					vim.lsp.buf.format({
						bufnr,
						filter = function(client)
							return client.name == fmt
						end,
					})
				elseif fmt then
					vim.cmd("Neoformat " .. fmt)
				else
					vim.cmd("Neoformat! " .. filetype)
				end
			end

			vim.keymap.set("n", "<leader>fl", format_buffer, { noremap = true, desc = "Format buffer" })
		end,
	},
}
