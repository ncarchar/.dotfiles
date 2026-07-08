return {
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({
                install_dir = vim.fn.stdpath("data") .. "/site",
            })

            local pre_installed = {
                "bash",
                "c",
                "cpp",
                "css",
                "html",
                "java",
                "javascript",
                "jsdoc",
                "json",
                "lua",
                "markdown",
                "markdown_inline",
                "sql",
                "typescript",
            }
            require("nvim-treesitter").install(pre_installed)

            vim.api.nvim_create_autocmd("FileType", {
                pattern = {
                    "bash",
                    "c",
                    "cpp",
                    "css",
                    "html",
                    "java",
                    "javascript",
                    "lua",
                    "markdown",
                    "sql",
                    "typescript",
                },
                callback = function(ev)
                    local bufnr = ev.buf
                    local line_count = vim.api.nvim_buf_line_count(bufnr)
                    if line_count > 50000 then
                        return
                    end

                    vim.treesitter.start()
                    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    vim.wo.foldmethod = "expr"
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })

            vim.api.nvim_create_autocmd("FileType", {
                group = config_augroup,
                callback = function(args)
                    local treesitter = require("nvim-treesitter")
                    local lang = vim.treesitter.language.get_lang(args.match)
                    if vim.list_contains(treesitter.get_available(), lang) then
                        if
                            not vim.list_contains(treesitter.get_installed(), lang)
                            and not vim.list_contains(pre_installed, lang)
                        then
                            treesitter.install(lang):wait()
                        end
                        vim.treesitter.start(args.buf)
                    end
                end,
                desc = "Enable nvim-treesitter and install parser if not installed",
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        lazy = false,
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = {
                    enable = true,
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
                    swap_next = { ["<leader>aa"] = "@parameter.inner" },
                    swap_previous = { ["<leader>aA"] = "@parameter.inner" },
                },
            })
        end,
    },
}
