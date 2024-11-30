require('no-neck-pain').setup {
  -- @type integer|"textwidth"|"colorcolumn"
  width = 200,
  -- Adds autocmd (@see `:h autocmd`) which aims at automatically enabling the plugin.
  autocmds = {
    enableOnVimEnter = false,
    enableOnTabEnter = false,
  },
  -- Creates mappings for you to easily interact with the exposed commands.
  mappings = {
    enabled = false,
  },
}

-- Toggle no neck pain
vim.keymap.set('n', '<leader>nn', require('no-neck-pain').toggle, { desc = '[N]o [N]eck Pain' })
