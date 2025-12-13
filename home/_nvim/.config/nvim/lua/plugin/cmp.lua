return { -- Autocompletion
    "hrsh7th/nvim-cmp",
    event = "VimEnter",
    dependencies = {
        "folke/lazydev.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
    },
    opts = function(_, opts)
        opts.sources = opts.sources or {}
        table.insert(opts.sources, {
            name = "lazydev",
            group_index = 0,
        })
    end,
    config = function()
        local cmp = require("cmp")
        local lspkind = require("lspkind")
        cmp.setup({
            formatting = {
                format = lspkind.cmp_format({
                    mode = "symbol_text",
                    maxwidth = 28,
                    ellipsis_char = "",
                }),
                expandable_indicator = true,
                fields = { "abbr", "menu", "kind" },
            },
            completion = {
                -- autocomplete = false,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-Down>"] = cmp.mapping.complete(),
                ["<CR>"] = cmp.mapping.confirm({
                    select = true,
                }),
                ["<C-n>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.close()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            sources = {
                { name = "nvim_lsp" },
                { name = "path" },
            },
        })
    end,
}
