return {
	{
		"sbdchd/neoformat",
		lazy = true,
		event = "BufEnter",
		config = function()
			vim.g.neoformat_run_all_formatters = 0

			local BIOME_ROOT_MARKERS = { "biome.json", "biome.jsonc" }
			local FORMATTER_CONFIG = {
				typescript = {
					{ name = "biome", root_markers = BIOME_ROOT_MARKERS },
					{ name = "prettier" },
				},
				javascript = {
					{ name = "biome", root_markers = BIOME_ROOT_MARKERS },
					{ name = "prettier" },
				},
				json = {
					{ name = "biome", root_markers = BIOME_ROOT_MARKERS },
					{ name = "prettier" },
				},
				java = {
					{ name = "jdtls" },
				},
				xml = {
					{ name = "lemminx" },
				},
				sh = {
					{ name = "bashls" },
				},
				htmlangular = {
					{ name = "prettier" },
				},
			}

			local function has_root_file(server_name, filenames)
				if not filenames or #filenames == 0 then
					return true
				end

				local clients = vim.lsp.get_clients({ bufnr = 0 })
				for _, client in ipairs(clients) do
					local root_dir = client.config.root_dir or client.root_dir
					if root_dir and client.name == server_name then
						for _, filename in ipairs(filenames) do
							if vim.loop.fs_stat(root_dir .. "/" .. filename) then
								return true
							end
						end
					end
				end

				local found = vim.fs.find(filenames, {
					path = vim.fn.expand("%:p:h"),
					upward = true,
					stop = vim.env.HOME,
				})
				return #found > 0
			end

			local function lsp_formatter_available(server_name)
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				for _, client in ipairs(clients) do
					if client.name == server_name and client:supports_method("textDocument/formatting") then
						return true
					end
				end
				return false
			end

			local function resolve_formatter(filetype)
				local candidates = FORMATTER_CONFIG[filetype]
				if not candidates then
					return nil
				end

				for _, candidate in ipairs(candidates) do
					if has_root_file(candidate.name, candidate.root_markers) then
						return candidate.name
					end
				end
				return nil
			end

			local function format_buffer()
				local filetype = vim.bo.filetype
				local fmt_name = resolve_formatter(filetype)

				if not fmt_name then
					print("No applicable formatter found for " .. filetype)
					return
				end

				if lsp_formatter_available(fmt_name) then
					vim.lsp.buf.format({
						bufnr = vim.api.nvim_get_current_buf(),
						filter = function(client)
							return client.name == fmt_name
						end,
					})
				else
					vim.cmd("Neoformat " .. fmt_name)
				end
			end

			vim.keymap.set("n", "<leader>fl", format_buffer, { noremap = true, desc = "Format buffer" })
		end,
	},
}
