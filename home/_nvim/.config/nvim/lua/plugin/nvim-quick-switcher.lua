local function find(file_regex, opts)
    return function() require('nvim-quick-switcher').find(file_regex, opts) end
end

return {
    {
        'Everduin94/nvim-quick-switcher',
        config = function()
            -- Angular Components
            vim.keymap.set("n", "<leader>at", find('.component.ts'), { desc = '[A]ngular Component [T]S' })
            vim.keymap.set("n", "<leader>as", find('.+css|.+scss|.+sass', { regex = true, prefix = 'full' }),
                { desc = '[A]ngular Component [S]CSS' })
            vim.keymap.set("n", "<leader>ah", find('.component.html'), { desc = '[A]ngular Component [H]TML' })
            vim.keymap.set("n", "<leader>ak", find('.component.spec.ts'), { desc = '[A]ngular Component [K]arma' })

            -- Redux/NgRx
            vim.keymap.set("n", "<leader>ra", find('.actions.ts'), { desc = '[R]edux [A]ctions' })
            vim.keymap.set("n", "<leader>re", find('.effects.ts'), { desc = '[R]edux [E]ffects' })
            vim.keymap.set("n", "<leader>rf", find('.facade.ts'), { desc = '[R]edux [F]acade' })
            vim.keymap.set("n", "<leader>rw", find('.store.ts'), { desc = '[R]edux [S]tore' })
            vim.keymap.set("n", "<leader>rr", find('.reducer.ts'), { desc = '[R]edux [R]educer' })
            vim.keymap.set("n", "<leader>rs", find('.selectors.ts'), { desc = '[R]edux [S]electors' })
        end
    }
}
