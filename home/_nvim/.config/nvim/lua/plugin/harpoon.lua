return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        config = function()
            local harpoon = require("harpoon")

            local settings = {
                save_on_toggle = true,
                sync_on_ui_close = true
            }

            harpoon:setup({ settings = settings })

            vim.keymap.set("n", "<leader>hf", function() harpoon:list():add() end, { desc = "[H]arpoon [F]ile" })
            vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
                { desc = "[H]arpoon Menu" })

            -- Harpoon goto marked
            for i = 1, 9 do
                vim.keymap.set("n", "<leader>" .. i, function() harpoon:list():select(i) end, { desc = "Harpoon [" .. i .. "]", noremap = true, silent = true })
            end
        end
    },
    {
        "letieu/harpoon-lualine",
        dependencies = { "ThePrimeagen/harpoon" }
    }
}
