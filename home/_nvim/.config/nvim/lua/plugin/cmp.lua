return {
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
        },
        config = function()
            local cmp = require 'cmp'
            local lspkind = require('lspkind')
            cmp.setup {
                formatting = {
                    format = lspkind.cmp_format({
                        mode = 'symbol_text',
                        maxwidth = 28,
                        ellipsis_char = ''
                    }),
                    expandable_indicator = true,
                    fields = { "abbr", "menu", "kind" }
                },
                completion = {
                    -- autocomplete = false,
                },
                mapping = cmp.mapping.preset.insert {
                    ['<C-Down>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm {
                        select = true,
                    },
                    ['<C-n>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.close()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                },
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'path' }
                },
                -- sorting = {
                --     comparators = {
                --         cmp.config.compare.exact,
                --         cmp.config.compare.score,
                --         cmp.config.compare.order,
                --     }
                -- }
            }
        end
    },
}
