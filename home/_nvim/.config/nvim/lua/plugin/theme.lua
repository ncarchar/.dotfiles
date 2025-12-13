return {
    {
        "navarasu/onedark.nvim",
        tag = "v0.1.0",
        -- Pin to legacy version
        priority = 1000,
        config = function()
            require("onedark").setup({
                style = "dark",
            })
            require("onedark").load()
        end,
    }
}
