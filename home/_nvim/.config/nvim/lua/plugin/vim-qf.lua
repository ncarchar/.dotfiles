return {
    {
        'romainl/vim-qf',
        lazy = false,
        config = function()
            -- Keymaps for Quickfix navigation
            vim.keymap.set('n', '<C-q>', '<Plug>(qf_qf_toggle)', { noremap = false, silent = true })
            vim.keymap.set('n', '<C-s>', '<Plug>(qf_qf_toggle_stay)', { noremap = false, silent = true })
            vim.keymap.set('n', '<C-j>', '<Plug>(qf_qf_next)', { noremap = false, silent = true })
            vim.keymap.set('n', '<C-k>', '<Plug>(qf_qf_previous)', { noremap = false, silent = true })

            -- Quickfix settings
            vim.g.qf_shorten_path = 1
            vim.g.qf_auto_quit = 1
            vim.g.qf_auto_open_quickfix = 1
            vim.g.qf_auto_open_loclist = 1
        end
    }
}
