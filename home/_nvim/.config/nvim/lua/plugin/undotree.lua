vim.g.undotree_WindowLayout = 3
vim.g.undotree_DiffAutoOpen = 1
vim.g.undotree_SetFocusWhenToggle = 1
vim.keymap.set('n', '<leader>tu', vim.cmd.UndotreeToggle, { desc = '[T]oggle [U]ndotree' })
local function custom_undotree_mappings()
    -- Use `vim.api.nvim_buf_set_keymap` to set buffer-local mappings
    vim.api.nvim_buf_set_keymap(0, 'n', '<C-k>', '<plug>UndotreeNextState', {silent = true})
    vim.api.nvim_buf_set_keymap(0, 'n', '<C-j>', '<plug>UndotreePreviousState', {silent = true})
    vim.api.nvim_buf_set_keymap(0, 'n', '<esc>', '<plug>UndotreeClose', {silent = true})
end
-- Assign the Lua function to the Vim global variable
vim.api.nvim_set_var('Undotree_CustomMap', custom_undotree_mappings)
