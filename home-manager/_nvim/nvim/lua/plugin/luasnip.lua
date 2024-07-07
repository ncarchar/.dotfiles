local ls = require "luasnip"
local types = require "luasnip.util.types"

ls.config.set_config {
    history = true,
    updateevents = "TextChanged,TextChangedI",

    enable_autosnippets = true,
    ext_opts = {
        [types.choiceNode] = {
            active = {
                virt_text = { { "<- Choice", "Error" } }
            }
        }
    }
}

-- Will expand the current item or jump to the next item within the snippet
vim.keymap.set({ "i", "s" }, "<c-l>", function()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    end
end, { silent = true })

-- Will jump to the previous item within the snippet
vim.keymap.set({ "i", "s" }, "<c-h>", function()
    if ls.jumpable(-1) then
        ls.jump(-1)
    end
end, { silent = true })

-- Will list snip choices
vim.keymap.set("i", "<c-j>", function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end, { silent = true })

vim.keymap.set("i", "<c-k>", function()
    if ls.choice_active() then
        ls.change_choice(-1)
    end
end, { silent = true })
