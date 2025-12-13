vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("bootstrap")

require("config")

require("lazy").setup({
    require("plugin"),
    require("lsp"),
})
