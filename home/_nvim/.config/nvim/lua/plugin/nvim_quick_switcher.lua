return {
    {
        "Everduin94/nvim-quick-switcher",
        config = function()
            local nmap = require("utils").NMAP

            local function find(file_regex, opts)
                return function()
                    require("nvim-quick-switcher").find(file_regex, opts)
                end
            end

            -- Angular
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "typescript", "htmlangular", "html", "css", "scss" },
                callback = function(args)
                    nmap(
                        args.buf,
                        "<leader>at",
                        find(
                            "^(?!.*\\.spec\\.ts$).+\\.ts$",
                            { regex = true, prefix = "full", regex_type = "P" }
                        ),
                        "Component [T]S"
                    )
                    nmap(
                        args.buf,
                        "<leader>as",
                        find(".+css|.+scss", { regex = true, prefix = "full" }),
                        "[A]ngular Component [S]CSS"
                    )
                    nmap(
                        args.buf,
                        "<leader>ah",
                        find(".+html", { regex = true, prefix = "full" }),
                        "Component [H]TML"
                    )
                    nmap(args.buf, "<leader>au", find(".component.spec.ts"), "Tests")
                end,
            })
        end,
    },
}
