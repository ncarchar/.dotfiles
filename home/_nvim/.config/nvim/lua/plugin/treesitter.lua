local function disable_treesitter_for_large_files(bufnr)
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    return line_count > 50000
end

require('nvim-treesitter.configs').setup({
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'bash', 'c', 'cmake', 'cpp', 'css', 'csv', 'git_config', 'git_rebase', 'gitattributes', 'gitcommit', 'gitignore', 'go', 'html', 'http', 'java', 'javascript', 'jq', 'jsdoc', 'json', 'json5', 'kotlin', 'lua', 'make', 'markdown', 'nginx', 'ocaml', 'regex', 'sql', 'tmux', 'tsv', 'tsx', 'typescript', 'vim', 'xml', 'zig' },
    sync_install = {},
    modules = {},
    ignore_install = {},
    auto_install = true,
    highlight = {
        enable = true,
        disable = function(lang, bufnr)
            return disable_treesitter_for_large_files(bufnr)
        end,
    },
    refactor = {
        highlight_definitions = {
            enable = true,
            disable = function(lang, bufnr)
                return disable_treesitter_for_large_files(bufnr)
            end,
        },
    },
    indent = {
        enable = true,
    },
    incremental_selection = {
        enable = true,
        disable = function(lang, bufnr)
            return disable_treesitter_for_large_files(bufnr)
        end,
        keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<M-space>',
        },
    },
    textobjects = {
        select = {
            enable = true,
            disable = function(lang, bufnr)
                return disable_treesitter_for_large_files(bufnr)
            end,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
            },
        },
        move = {
            enable = true,
            disable = function(lang, bufnr)
                return disable_treesitter_for_large_files(bufnr)
            end,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                [']m'] = '@function.outer',
                [']]'] = '@class.outer',
            },
            goto_next_end = {
                [']M'] = '@function.outer',
                [']['] = '@class.outer',
            },
            goto_previous_start = {
                ['[m'] = '@function.outer',
                ['[['] = '@class.outer',
            },
            goto_previous_end = {
                ['[M'] = '@function.outer',
                ['[]'] = '@class.outer',
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ['<leader>aa'] = '@parameter.inner',
            },
            swap_previous = {
                ['<leader>aA'] = '@parameter.inner',
            },
        },
    },
})
