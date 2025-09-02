vim.keymap.set("n", "<leader>oo", function()
	vim.cmd("silent! update")

	local vault = "vault"

	local function urlencode(s)
		return s:gsub("\n", "\r\n"):gsub("([^%w%-_%.~])", function(c)
			return string.format("%%%02X", string.byte(c))
		end)
	end

	local function find_vault_root()
		local p = vim.fn.expand("%:p:h")
		while p and p ~= "/" do
			if vim.fn.fnamemodify(p, ":t") == vault then
				return p
			end
			p = vim.fn.fnamemodify(p, ":h")
		end
	end
	local root = find_vault_root()
	if not root then
		return print("Vault root not found")
	end

	local abs = vim.fn.expand("%:p")
	local rel = abs:sub(#root + 2)
	local line = vim.fn.line(".")
	local col = vim.fn.virtcol(".")

	local uri = ("obsidian://adv-uri?vault=%s&filepath=%s&line=%d&column=%d"):format(vault, urlencode(rel), line, col)

	vim.fn.jobstart({ "xdg-open", uri }, { detach = true })
end, { desc = "[O]pen [O]bsidian", noremap = true, silent = true })
