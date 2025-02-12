vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup(
    {
        {
            'neovim/nvim-lspconfig',
            dependencies = {
                { 'williamboman/mason.nvim',          config = true },
                { 'williamboman/mason-lspconfig.nvim' },
                { 'j-hui/fidget.nvim',                tag = 'legacy', opts = {} },
                { 'folke/neodev.nvim' },
                { 'hrsh7th/cmp-nvim-lsp' }
            },
        },
        {
            'hrsh7th/nvim-cmp',
            event = 'InsertEnter',
            dependencies = {
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/cmp-path',
            },
        },
        {
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
                    vim.keymap.set('n', '<leader>gp', function() require('gitsigns').nav_hunk('next') end,
                        { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
                    vim.keymap.set('n', '<leader>gn', function() require('gitsigns').nav_hunk('next') end,
                        { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
                end,
            },
        },
        {
            'navarasu/onedark.nvim',
            priority = 1000,
            config = function()
                vim.cmd.colorscheme 'onedark'
            end
        },
        {
            'nvim-telescope/telescope.nvim',
            branch = '0.1.x',
            dependencies = { 'nvim-lua/plenary.nvim' }
        },
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },
        {
            'nvim-treesitter/nvim-treesitter',
            dependencies = {
                'nvim-treesitter/nvim-treesitter-textobjects',
                'nvim-treesitter/nvim-treesitter-refactor'
            },
            build = ':TSUpdate',
        },
        {
            "letieu/harpoon-lualine",
            dependencies = { { "ThePrimeagen/harpoon", branch = "harpoon2", } },
        },
        { 'tpope/vim-fugitive' },
        { 'tpope/vim-rhubarb' },
        { 'tpope/vim-vinegar' },
        { 'nvim-lualine/lualine.nvim' },
        { 'folke/which-key.nvim',                opts = {} },
        { 'windwp/nvim-ts-autotag',              lazy = true, event = 'InsertEnter' },
        { 'windwp/nvim-autopairs',               lazy = true, event = 'InsertEnter' },
        { 'Everduin94/nvim-quick-switcher',      lazy = true },
        { 's1n7ax/nvim-window-picker',           lazy = true },
        { 'mfussenegger/nvim-jdtls',             lazy = true, ft = 'java' },
        { 'akinsho/toggleterm.nvim',             lazy = true },
        { 'mbbill/undotree',                     lazy = true, event = 'BufEnter' },
        { 'numToStr/Comment.nvim',               lazy = true, event = 'BufEnter' },
        { 'lukas-reineke/indent-blankline.nvim', lazy = true, event = 'BufEnter' },
        { 'onsails/lspkind.nvim',                lazy = true, event = "BufEnter" },
        { 'sbdchd/neoformat',                    lazy = true, event = 'BufEnter' },
        { 'romainl/vim-qf',                      lazy = false },
        { 'wakatime/vim-wakatime',               lazy = false }
    },
    {})

-- Generics
require('generic.globals')
require('generic.key-bindings')
require('generic.netrw')
require('generic.powershell-clipboard')
require('generic.vim-settings')

-- LSP
require('lsp.mason')

-- Plugins
require('plugin.harpoon')
require('plugin.indent-blankline')
require('plugin.lualine')
require('plugin.neoformat')
require('plugin.nvim-autopairs')
require('plugin.nvim-cmp')
require('plugin.nvim-quick-switcher')
require('plugin.nvim-ts-autotag')
require('plugin.telescope')
require('plugin.toggleterm')
require('plugin.treesitter')
require('plugin.undotree')
require('plugin.vim-qf')
require('plugin.window-picker')
