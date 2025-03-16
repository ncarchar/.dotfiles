return {
    {
        'mbbill/undotree',
        lazy = true,
        event = 'BufEnter',
        config = function()
            vim.g.undotree_WindowLayout = 3
            vim.g.undotree_DiffAutoOpen = 1
            vim.g.undotree_SetFocusWhenToggle = 1

            -- Keymap to toggle Undotree
            vim.keymap.set('n', '<leader>tu', vim.cmd.UndotreeToggle, { desc = '[T]oggle [U]ndotree' })

            -- Custom mappings for Undotree buffer
            local function custom_undotree_mappings()
                vim.api.nvim_buf_set_keymap(0, 'n', '<C-k>', '<plug>UndotreeNextState', { silent = true })
                vim.api.nvim_buf_set_keymap(0, 'n', '<C-j>', '<plug>UndotreePreviousState', { silent = true })
                vim.api.nvim_buf_set_keymap(0, 'n', '<esc>', '<plug>UndotreeClose', { silent = true })
            end
            vim.api.nvim_set_var('Undotree_CustomMap', custom_undotree_mappings)
        end
    }
}
