vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	require("plugin.telescope"),
	require("plugin.harpoon"),
	{ "tpope/vim-vinegar" },
	{ "folke/which-key.nvim", opts = {} },
}, {})

require("generic.key-bindings")
require("generic.netrw")
require("generic.powershell-clipboard")
require("generic.vim-settings")
