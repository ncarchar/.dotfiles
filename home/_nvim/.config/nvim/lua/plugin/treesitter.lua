local function disable(_, bufnr)
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    return line_count > 20000
end

require('nvim-treesitter.configs').setup({
    ensure_installed = { 'bash', 'c', 'cpp', 'css', 'csv', 'git_config', 'gitattributes', 'gitcommit', 'gitignore', 'html', 'http', 'java', 'javascript', 'json', 'lua', 'markdown', 'regex', 'sql', 'tmux', 'tsv', 'typescript', 'vim', 'xml', 'zig' },
    sync_install = true,
    modules = {},
    ignore_install = {},
    auto_install = true,
    highlight = {
        enable = true,
        disable = disable
    },
    refactor = {
        highlight_definitions = {
            enable = true,
            disable = disable
        },
    },
    indent = {
        enable = true,
        disable = disable
    },
    incremental_selection = {
        enable = true,
        disable = disable,
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
            disable = disable,
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
            disable = disable,
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
            disable = disable,
            swap_next = {
                ['<leader>aa'] = '@parameter.inner',
            },
            swap_previous = {
                ['<leader>aA'] = '@parameter.inner',
            },
        },
    },
})
