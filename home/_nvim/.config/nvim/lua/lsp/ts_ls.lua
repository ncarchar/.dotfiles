local function add_missing()
	vim.lsp.buf.code_action({
		apply = true,
		context = {
			only = { "source.addMissingImports.ts" },
			diagnostics = {},
		},
	})
end

local function organize_imports(client)
	local params = {
		command = "_typescript.organizeImports",
		arguments = { vim.api.nvim_buf_get_name(0) },
		title = "",
	}
	client:exec_cmd(params)
end

return {
	filetypes = { "javascript", "typescript" },
	commands = {
		["<leader>oi"] = {
			function(client)
				return function()
					organize_imports(client)
				end
			end,
		},
		["<leader>ci"] = {
			function(_)
				return function()
					add_missing()
				end
			end,
		},
	},
	settings = {
		implicitProjectConfiguration = {
			checkJs = true,
		},
		displayPartsForJSDoc = true,
		includeCompletionsWithSnippetText = true,
		typescript = {
			tsserver = {
				useSyntaxServer = true,
			},
		},
	},
}
