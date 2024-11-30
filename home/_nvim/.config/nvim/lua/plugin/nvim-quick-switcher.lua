-- Quick switching for angular
vim.keymap.set("n", "<leader>at", "<cmd>:lua require('nvim-quick-switcher').find('.component.ts')<CR>", { desc = '[A]ngular Component [T]S' })
vim.keymap.set("n", "<leader>as", "<cmd>:lua require('nvim-quick-switcher').find('.component.scss')<CR>", { desc = '[A]ngular Component [S]CSS' })
vim.keymap.set("n", "<leader>ah", "<cmd>:lua require('nvim-quick-switcher').find('.component.html')<CR>", { desc = '[A]ngular Component [H]TML' })
vim.keymap.set("n", "<leader>ak", "<cmd>:lua require('nvim-quick-switcher').find('.component.spec.ts')<CR>", { desc = '[A]ngular Component [K]arma' })

-- Quick switching for NgRx, Redux and Redux-like 
vim.keymap.set("n", "<leader>rs", "<cmd>:lua require('nvim-quick-switcher').find('*store.ts')<CR>", { desc = '[R]edux [S]tore' })
vim.keymap.set("n", "<leader>rf", "<cmd>:lua require('nvim-quick-switcher').find('*facade.ts')<CR>", { desc = '[R]edux [F]acade' })
