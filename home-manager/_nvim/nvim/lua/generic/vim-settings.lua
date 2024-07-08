-- See `:help vim.o`
vim.o.termguicolors = true

vim.o.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.list = true
vim.opt.listchars:append("eol:↲")

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 100
vim.o.timeoutlen = 300
vim.o.ttimeoutlen = 50


-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Adds line highlight to current line
vim.wo.cursorline = true

-- Adds relative line numbers
vim.wo.relativenumber = true

vim.opt.tabstop = 4      -- number of visual spaces per TAB
vim.opt.softtabstop = 4  -- number of spaces in tab when editing
vim.opt.shiftwidth = 4   -- number of spaces to use for autoindent/>> and <<
vim.opt.expandtab = true -- use spaces instead of tabs

-- TODO: tab width for ts files gets reset at file enter from:
-- /usr/share/nvim/runtime/indent/typescript.vim
vim.api.nvim_create_autocmd("FileType", {
    pattern = "typescript",
    callback = function()
        vim.defer_fn(function()
            vim.opt.tabstop = 4
            vim.opt.softtabstop = 4
            vim.opt.shiftwidth = 4
            vim.opt.expandtab = true
            vim.opt.autoindent = true
            vim.opt.smartindent = true
        end, 100)
    end
})

vim.opt.foldenable = false
vim.opt.foldlevel = 1
vim.opt.foldlevelstart = 1
vim.opt.foldmethod = "indent"
vim.opt.foldnestmax = 12
vim.opt.foldminlines = 12
