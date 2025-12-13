return {
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "nvim-treesitter/nvim-treesitter-refactor",
        },
        build = ":TSUpdate",
        config = function()
            local function disable(_, bufnr)
                local line_count = vim.api.nvim_buf_line_count(bufnr)
                if line_count > 50000 then
                    return true
                end

                return false
            end

            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "bash",
                    "c",
                    "cpp",
                    "css",
                    "html",
                    "java",
                    "javascript",
                    "json",
                    "lua",
                    "markdown",
                    "typescript",
                    "jsdoc",
                },
                sync_install = true,
                modules = {},
                ignore_install = {},
                auto_install = true,
                highlight = {
                    enable = true,
                    disable = disable,
                },
                injections = {
                    enable = true,
                },
                refactor = {
                    highlight_definitions = {
                        enable = true,
                        disable = disable,
                    },
                },
                indent = {
                    enable = true,
                    disable = disable,
                },
                incremental_selection = {
                    enable = true,
                    disable = disable,
                },
                textobjects = {
                    select = {
                        enable = true,
                        disable = disable,
                        lookahead = true,
                        keymaps = {
                            ["aa"] = "@parameter.outer",
                            ["ia"] = "@parameter.inner",
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                        },
                    },
                    move = {
                        enable = true,
                        disable = disable,
                        set_jumps = true,
                        goto_next_start = {
                            ["]m"] = "@function.outer",
                            ["]]"] = "@class.outer",
                        },
                        goto_next_end = {
                            ["]M"] = "@function.outer",
                            ["]["] = "@class.outer",
                        },
                        goto_previous_start = {
                            ["[m"] = "@function.outer",
                            ["[["] = "@class.outer",
                        },
                        goto_previous_end = {
                            ["[M"] = "@function.outer",
                            ["[]"] = "@class.outer",
                        },
                    },
                    swap = {
                        enable = true,
                        disable = disable,
                        swap_next = {
                            ["<leader>aa"] = "@parameter.inner",
                        },
                        swap_previous = {
                            ["<leader>aA"] = "@parameter.inner",
                        },
                    },
                },
            })
        end,
    },
}
