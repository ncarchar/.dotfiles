-- Harpoon mark file
vim.keymap.set("n", "<leader>hf", "<cmd>:lua require('harpoon.mark').toggle_file()<CR>", { desc = '[H]arpoon [F]ile' })
-- Harpoon open GUI
vim.keymap.set("n", "<leader>hh", "<cmd>:lua require('harpoon.ui').toggle_quick_menu()<CR>", { desc = '[H]arpoon GUI' })
-- Harpoon goto marked file
vim.keymap.set("n", "1", "<cmd>:lua require('harpoon.ui').nav_file(1)<CR>", { desc = '[H]arpoon Nav[1]', noremap = true })
vim.keymap.set("n", "2", "<cmd>:lua require('harpoon.ui').nav_file(2)<CR>", { desc = '[H]arpoon Nav[2]', noremap = true })
vim.keymap.set("n", "3", "<cmd>:lua require('harpoon.ui').nav_file(3)<CR>", { desc = '[H]arpoon Nav[3]', noremap = true })
vim.keymap.set("n", "4", "<cmd>:lua require('harpoon.ui').nav_file(4)<CR>", { desc = '[H]arpoon Nav[4]', noremap = true })
vim.keymap.set("n", "5", "<cmd>:lua require('harpoon.ui').nav_file(5)<CR>", { desc = '[H]arpoon Nav[5]', noremap = true })
vim.keymap.set("n", "6", "<cmd>:lua require('harpoon.ui').nav_file(6)<CR>", { desc = '[H]arpoon Nav[6]', noremap = true })
vim.keymap.set("n", "7", "<cmd>:lua require('harpoon.ui').nav_file(7)<CR>", { desc = '[H]arpoon Nav[7]', noremap = true })
vim.keymap.set("n", "8", "<cmd>:lua require('harpoon.ui').nav_file(8)<CR>", { desc = '[H]arpoon Nav[8]', noremap = true })
vim.keymap.set("n", "9", "<cmd>:lua require('harpoon.ui').nav_file(9)<CR>", { desc = '[H]arpoon Nav[9]', noremap = true })
