return {
    {
        "obsidian-nvim/obsidian.nvim",
        version = "*",
        cond = function()
            local cwd = vim.fn.getcwd()
            local vault = vim.fn.expand("~/vault")
            return cwd == vault or cwd:sub(1, #vault + 1) == vault .. "/"
        end,
        opts = {
            legacy_commands = false,
            ui = { enable = false },
            checkbox = {
                enabled = false,
                create_new = true,
                order = { " ", "~", "!", ">", "x" },
            },
            workspaces = {
                {
                    name = "vault",
                    path = "~/vault",
                },
            },
        },
        init = function()
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = vim.fn.expand("~/vault") .. "/*.md",
                callback = function()
                    vim.opt_local.conceallevel = 2
                end,
            })
        end,
    },
}
