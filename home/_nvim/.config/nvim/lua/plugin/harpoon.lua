local harpoon = require('harpoon')

local settings = {
    save_on_toggle = true,
    sync_on_ui_close = true
}
harpoon:setup({ settings = settings })

-- Harpoon mark file
vim.keymap.set("n", "<leader>hf", function() harpoon:list():add() end, { desc = '[H]arpoon [F]ile' })
-- Harpoon open GUI
vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = '[H]arpoon GUI' })
-- Harpoon goto marked file
vim.keymap.set("n", "1", function() harpoon:list():select(1) end)
vim.keymap.set("n", "2", function() harpoon:list():select(2) end)
vim.keymap.set("n", "3", function() harpoon:list():select(3) end)
vim.keymap.set("n", "4", function() harpoon:list():select(4) end)
vim.keymap.set("n", "5", function() harpoon:list():select(5) end)
vim.keymap.set("n", "6", function() harpoon:list():select(6) end)
vim.keymap.set("n", "7", function() harpoon:list():select(7) end)
vim.keymap.set("n", "8", function() harpoon:list():select(8) end)
vim.keymap.set("n", "9", function() harpoon:list():select(9) end)
