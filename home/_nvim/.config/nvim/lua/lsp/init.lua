return {
    require("lsp.cmp"),
    require("lsp.neoformat"),
    require("lsp.lspconfig"),
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
}
