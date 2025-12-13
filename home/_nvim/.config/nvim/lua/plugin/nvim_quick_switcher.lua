return {
    {
        "Everduin94/nvim-quick-switcher",
        config = function()
            local function find(file_regex, opts)
                return function()
                    require("nvim-quick-switcher").find(file_regex, opts)
                end
            end

            local function find_by_fn(fn, opts)
                return function()
                    require("nvim-quick-switcher").find_by_fn(fn, opts)
                end
            end

            local function map(buf, lhs, rhs, desc)
                vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
            end

            -- Angular
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "typescript", "htmlangular", "html", "css", "scss" },
                callback = function(args)
                    map(args.buf, "<leader>at", find(".component.ts"), "Component [T]S")
                    map(
                        args.buf,
                        "<leader>as",
                        find(".+css|.+scss", { regex = true, prefix = "full" }),
                        "[A]ngular Component [S]CSS"
                    )
                    map(
                        args.buf,
                        "<leader>ah",
                        find(".+html", { regex = true, prefix = "full" }),
                        "Component [H]TML"
                    )
                    map(args.buf, "<leader>au", find(".component.spec.ts"), "Tests")
                end,
            })
        end,
    },
}
