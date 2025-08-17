-- Key map for new tab git fugitive
vim.keymap.set("n", "<leader><leader>g", ":tab Git<CR>", { noremap = true, silent = true, desc = "[G]it Fugitive Tab" })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>d", function()
	vim.diagnostic.open_float()
end, { noremap = true, silent = true, desc = "Show diagnostics" })

-- Move line
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Replace Remap
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Keeps current row at the center of the screen as you navigate
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
vim.keymap.set("n", "n", "nzz", { noremap = true, silent = true })
vim.keymap.set("n", "N", "Nzz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-o>", "<C-o>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { noremap = true, silent = true })

-- See `:help vim.keymap.set()`
-- Use space for leader
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Find and replace current word
vim.keymap.set(
	"n",
	"<leader>rt",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "[R]ename [T]ext", noremap = true }
)
vim.keymap.set(
	"n",
	"<leader>rl",
	[[:s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "[R]ename [L]ine", noremap = true }
)

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

vim.keymap.set("n", "<leader>%", function()
	vim.cmd(":w")
	vim.cmd("source %")
end, { desc = "[S]ource [%]" })

local function run_command()
	local cwd = vim.fn.getcwd()
	local run_sh_path = cwd .. "/run.sh"
	if vim.fn.filereadable(run_sh_path) == 1 then
		vim.cmd("!echo && bash " .. run_sh_path)
	else
		print("No .run.sh found in the current directory.")
	end
end

vim.keymap.set("n", "<leader><leader>r", run_command, { noremap = true, silent = true })

vim.api.nvim_create_user_command("WA", "wa", {})
vim.api.nvim_create_user_command("Wa", "wa", {})
vim.api.nvim_create_user_command("Q", "q", {})

vim.keymap.set("n", "<leader>td", ":edit ~/.todo/TODO.md<CR>", { desc = "Edit TODO.md", noremap = true, silent = true })
-- Make executable
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "sh", "zsh" },
	callback = function()
		vim.keymap.set(
			"n",
			"<leader>x",
			"<cmd>!chmod +x %<CR>",
			{ desc = "Make executable", noremap = true, silent = true }
		)
	end,
})

vim.api.nvim_create_user_command("JdtlsClean", function()
	local workspace_root = vim.fn.stdpath("data") .. "/site/java/workspace-root/"
	if vim.fn.isdirectory(workspace_root) == 1 then
		os.execute("rm -rf " .. workspace_root .. "*")
		print("All JDT LS workspaces removed from " .. workspace_root)
	else
		print("Workspace root not found.")
	end
end, {})
