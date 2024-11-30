-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
-- require('luasnip.loaders.from_vscode').lazy_load()
local lspkind = require('lspkind')

cmp.setup {
    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol_text',
            maxwidth = 32,
            ellipsis_char = '...',
        })
    },
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
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
        { name = 'luasnip' },
        { name = 'nvim_lsp' },
        { name = 'path' }
    },
    sorting = {
        comparators = {
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.order,
        }
    }
}
