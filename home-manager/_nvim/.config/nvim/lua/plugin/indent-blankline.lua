-- Modifiying colors to prevent invisible cursor issue
vim.opt.termguicolors = true
vim.cmd [[highlight IndentBlanklineIndent1 guifg=#3d434f gui=nocombine]]
require("ibl").setup { scope = { highlight = highlight } }
