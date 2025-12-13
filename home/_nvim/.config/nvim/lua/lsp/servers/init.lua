return {
    angularls = {
        root_markers = { "angular.json" },
        workspace_required = true,
    },
    bashls = {},
    biome = {
        root_markers = { "biome.json", "biome.jsonc" },
        workspace_required = true,
    },
    cssls = {},
    jdtls = require("lsp.servers.jdtls").setup(),
    lua_ls = {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim" },
                },
            },
        },
    },
    marksman = {
        cmd = { "marksman", "server" },
    },
    nil_ls = {},
    ts_ls = require("lsp.servers.jdtls").setup(),
}
