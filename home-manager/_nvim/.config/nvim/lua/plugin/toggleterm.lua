require("toggleterm").setup({
  direction = 'float',
  close_on_exit = true, -- close the terminal window when the process exits
  auto_scroll = true,   -- automatically scroll to the bottom on terminal output
  float_opts = {
    border = 'single',
    winblend = 0,
  },
})

-- ToggleTerm open Terminal
vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>:q!<CR>]], {noremap = true})
vim.keymap.set("n", "<leader>tt", ":ToggleTerm dir=%<CR>", { desc = '[T]oggle [T]erminal' })
vim.keymap.set("n", "<leader>ts", ":ToggleTerm dir=%<CR>tms<CR>", { desc = '[T]mux [S]essionizer' })
