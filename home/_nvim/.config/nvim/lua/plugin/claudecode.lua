return {
    "coder/claudecode.nvim",
    cmd = {
        "ClaudeCode",
        "ClaudeCodeFocus",
        "ClaudeCodeSelectModel",
        "ClaudeCodeAdd",
        "ClaudeCodeSend",
        "ClaudeCodeTreeAdd",
        "ClaudeCodeStatus",
        "ClaudeCodeStart",
        "ClaudeCodeStop",
        "ClaudeCodeOpen",
        "ClaudeCodeClose",
        "ClaudeCodeDiffAccept",
        "ClaudeCodeDiffDeny",
        "ClaudeCodeCloseAllDiffs",
    },
    keys = {
        { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "[C]laude Toggle" },
        { "<leader>cf", "<cmd>ClaudeCodeOpen<cr>", desc = "[C]laude [F]ocus" },
        {
            "<A-c>",
            function()
                if vim.bo.buftype == "terminal" then
                    vim.cmd("wincmd p")
                else
                    vim.cmd("ClaudeCodeOpen")
                end
            end,
            mode = "n",
            desc = "Claude Toggle Focus",
        },
        { "<A-c>", "<C-\\><C-n><C-w>p", mode = "t", desc = "Claude Toggle Focus" },
        { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "[C]laude [R]esume" },
        { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "[C]laude [C]ontinue" },
        { "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "[C]laude Select [M]odel" },
        { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "[C]laude Add [B]uffer" },
        { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "[C]laude [S]end Selection" },
        { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "[C]laude [A]ccept Diff" },
        { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "[C]laude [D]eny Diff" },
    },
    config = function()
        require("claudecode").setup({
            terminal_provider = "native",
        })
    end,
}
