-- UI and Visual Settings
vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.signcolumn = "yes"
vim.o.list = true
vim.opt.listchars:append("eol:↲")

-- Search Settings
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.wildmenu = true

-- Editor Behavior
vim.o.mouse = ""
vim.o.breakindent = true
vim.o.undofile = true
vim.o.updatetime = 100
vim.o.timeoutlen = 300
vim.o.ttimeoutlen = 50
vim.o.completeopt = "menuone,noselect"

-- Indentation and Spacing
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- Folding
vim.o.foldenable = false
vim.o.foldlevel = 1
vim.o.foldlevelstart = 1
vim.o.foldmethod = "indent"
vim.o.foldnestmax = 12
vim.o.foldminlines = 12

-- Clipboard
vim.o.clipboard = "unnamedplus"
-- Required to properly use system clipboard using WSL
if vim.fn.has("win32") == 0 and os.getenv("WSL_DISTRO_NAME") then
    local clip = "/mnt/c/Windows/System32/clip.exe"
    local powershell = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

    vim.g.clipboard = {
        name = "windows-clipboard",
        copy = {
            ["+"] = {
                "sh",
                "-c",
                "tr -d '\\r' | iconv -f UTF-8 -t UTF-16LE | " .. clip,
            },
            ["*"] = {
                "sh",
                "-c",
                "tr -d '\\r' | iconv -f UTF-8 -t UTF-16LE | " .. clip,
            },
        },
        paste = {
            ["+"] = {
                "sh",
                "-c",
                powershell
                    .. " -NoProfile -Command '[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new(); "
                    .. "Get-Clipboard -Raw' | tr -d '\\r'",
            },
            ["*"] = {
                "sh",
                "-c",
                powershell
                    .. " -NoProfile -Command '[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new(); "
                    .. "Get-Clipboard -Raw' | tr -d '\\r'",
            },
        },
        cache_enabled = 0,
    }
end

-- Key Mappings
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.cmd([[ let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro rnu' ]])
