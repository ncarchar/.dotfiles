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
        require('plugin.theme'),
        require('plugin.gitsigns'),
        require('plugin.telescope'),
        require('plugin.treesitter'),
        require('plugin.harpoon'),
        require('plugin.lualine'),
        require('plugin.neoformat'),
        require('plugin.undotree'),
        require('plugin.vim-qf'),
        require('plugin.nvim-cmp'),
        require('plugin.nvim-quick-switcher'),
        require('plugin.toggleterm'),
        { 'tpope/vim-fugitive' },
        { 'tpope/vim-rhubarb' },
        { 'tpope/vim-vinegar' },
        { 'tpope/vim-surround' },
        { 'lukas-reineke/indent-blankline.nvim', opts = {},   main = "ibl" },
        { 'folke/which-key.nvim',                opts = {} },
        { 'mfussenegger/nvim-jdtls',             lazy = true, ft = 'java' },
        { 'numToStr/Comment.nvim',               lazy = true, event = 'BufEnter' },
        { 'onsails/lspkind.nvim',                lazy = true, event = "BufEnter" },
        { 'wakatime/vim-wakatime',               lazy = false }
    },
    {})

-- Generics
require('generic.globals')
require('generic.key-bindings')
require('generic.netrw')
require('generic.powershell-clipboard')
require('generic.vim-settings')
require('lsp.mason')
