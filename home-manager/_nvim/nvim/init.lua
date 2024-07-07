-- See `:help mapleader`
-- NOTE: Must happen before plugins are required (otherwise wrong leader will be used)

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- Install Lazy package manager
-- https://github.com/folke/lazy.nvim
--`:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup(
    {
        -- Git related plugins
        { 'tpope/vim-fugitive' },
        { 'tpope/vim-rhubarb' },
        -- Improves netrw
        { 'tpope/vim-vinegar' },
        -- { 'stevearc/oil.nvim' },
        -- Useful plugin to show you pending keybinds.
        { 'folke/which-key.nvim' },
        -- Set lualine as statusline
        { 'nvim-lualine/lualine.nvim' },
        -- NOTE: This is where your plugins related to LSP can be installed.
        {
            -- LSP Configuration & Plugins
            'neovim/nvim-lspconfig',
            dependencies = {
                -- Automatically install LSPs to stdpath for neovim
                { 'williamboman/mason.nvim', config = true },
                'williamboman/mason-lspconfig.nvim',
                -- Useful status updates for LSP
                -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
                { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },
                -- Additional lua configuration, makes nvim stuff amazing!
                'folke/neodev.nvim',
            },
        },
        {
            -- Autocompletion
            'hrsh7th/nvim-cmp',
            dependencies = {
                -- Snippet Engine & its associated nvim-cmp source
                'L3MON4D3/LuaSnip',
                'saadparwaiz1/cmp_luasnip',
                -- Adds LSP completion capabilities
                'hrsh7th/cmp-nvim-lsp'
            },
        },
        {
            -- Adds git releated signs to the gutter, as well as utilities for managing changes
            'lewis6991/gitsigns.nvim',
            opts = {
                signs = {
                    add = { text = '+' },
                    change = { text = '~' },
                    delete = { text = '_' },
                    topdelete = { text = '?' },
                    changedelete = { text = '~' },
                },
                on_attach = function(bufnr)
                    vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk,
                        { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
                    vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk,
                        { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
                end,
            },
        },
        {
            'navarasu/onedark.nvim',
            lazy = false,
            priority = 1000,
            config = function()
                vim.cmd.colorscheme 'onedark'
            end,
        },
        {
            'sainnhe/gruvbox-material',
            lazy = false,
            priority = 1000,
            -- config = function()
            --     vim.cmd.colorscheme 'gruvbox-material'
            -- end,
        },
        {
            'ellisonleao/gruvbox.nvim'
        },
        {
            -- Add indentation guides even on blank lines
            'lukas-reineke/indent-blankline.nvim',
        },
        -- Fuzzy Finder (files, lsp, etc)
        {
            'nvim-telescope/telescope.nvim',
            branch = '0.1.x',
            dependencies = {
                'nvim-lua/plenary.nvim' }
        },
        -- Quick file switcher
        { 'ThePrimeagen/harpoon',           dependencies = { 'nvim-lua/plenary.nvim' } },
        -- Fuzzy Finder Algorithm which requires local dependencies to be built.
        -- Only load if `make` is available. Make sure you have the system
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            -- NOTE: If you are having trouble with this installation,
            --       refer to the README for telescope-fzf-native for more instructions.
            build = 'make',
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },
        -- Highlight, edit, and navigate code
        {
            'nvim-treesitter/nvim-treesitter',
            dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects', 'nvim-treesitter/nvim-treesitter-refactor' },
            build = ':TSUpdate',
        },
        -- Autocloses tags
        {
            'windwp/nvim-ts-autotag',
            dependencies = 'nvim-treesitter/nvim-treesitter',
            event = 'InsertEnter'
        },
        {
            'windwp/nvim-autopairs',
            event = "InsertEnter",
        },
        -- Quick switcher for Angular
        { 'Everduin94/nvim-quick-switcher', lazy = true },
        -- Center code
        { 'shortcuts/no-neck-pain.nvim',    lazy = true },
        -- Adds symbols to LSP
        { 'onsails/lspkind.nvim' },
        -- Auto comment with `gc` and `gcc`
        { 'numToStr/Comment.nvim',          lazy = true },
        -- Quick window switcher
        { 's1n7ax/nvim-window-picker',      lazy = true },
        -- JDTLS advanced LSP
        { 'mfussenegger/nvim-jdtls',        ft = 'java' },
        -- Toggle terminal
        { 'akinsho/toggleterm.nvim',        lazy = true },
        -- Enables and visualizes undo branches
        { 'mbbill/undotree' },
        { 'sbdchd/neoformat' },
        -- { 'wakatime/vim-wakatime',          lazy = false },
        { 'romainl/vim-qf' },
        -- { 'kevinhwang91/nvim-bqf',          ft = 'qf' },
        {
            "epwalsh/obsidian.nvim",
            version = "*",
            lazy = true,
            ft = "markdown",
            dependencies = {
                "nvim-lua/plenary.nvim",
            },
            opts = {
                workspaces = {
                    {
                        name = "work",
                        path = "~/vault",
                    },
                },
                mappings = {
                    ["gf"] = {
                        action = function()
                            return require("obsidian").util.gf_passthrough()
                        end,
                        opts = { noremap = false, expr = true, buffer = true },
                    },
                    ["<leader>ch"] = {
                        action = function()
                            return require("obsidian").util.toggle_checkbox()
                        end,
                        opts = { buffer = true },
                    },
                    ["<tab><tab>"] = {
                        action = function()
                            vim.cmd("ObsidianQuickSwitch")
                        end,
                        opts = { buffer = true },
                    },
                    ["<leader>pi"] = {
                        action = function()
                            local filename = vim.fn.expand("%:t:r")
                            local timestamp = os.date("%Y%m%d%H%M%S")
                            vim.cmd("ObsidianPasteImg " .. filename .. "_" .. timestamp)
                        end,
                        opts = { buffer = true },
                    },
                },
            },
        }
    },
    {})
-- theme
require('onedark').setup {
    style = 'dark'
}
require('onedark').load()

-- Generics
require('generic.globals')
require('generic.vim-settings')
require('generic.netrw')
require('generic.powershell-clipboard')
require('generic.key-bindings')

-- Plugins
require('plugin.Comment')
require('plugin.harpoon')
require('plugin.indent-blankline')
require('plugin.mason')
require('plugin.lualine')
require('plugin.luasnip')
require('plugin.neoformat')
require('plugin.no-neck-pain')
require('plugin.nvim-autopairs')
require('plugin.nvim-cmp')
require('plugin.nvim-quick-switcher')
require('plugin.nvim-ts-autotag')
require('plugin.obsidian-nvim')
require('plugin.telescope')
require('plugin.toggleterm')
require('plugin.treesitter')
require('plugin.taskwarrior')
require('plugin.undotree')
require('plugin.which-key')
require('plugin.window-picker')

-- Snips
require('snips.all')
require('snips.html')
require('snips.javascript')
require('snips.java')
require('snips.typescript')
require('snips.template')
