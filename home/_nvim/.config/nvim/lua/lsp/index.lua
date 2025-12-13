return {
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "mason-org/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            local generics = require("utils.generics")

            local servers = {
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
                jdtls = require("lsp.jdtls").setup(),
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
                ts_ls = require("lsp.ts_ls").setup(),
            }

            -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            if pcall(require, "cmp") and pcall(require, "cmp_nvim_lsp") then
                capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
            end

            for server_name, server in pairs(servers) do
                if type(server) ~= "table" then
                    server = {}
                end
                server.capabilities =
                    vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                vim.lsp.config(server_name, server)
            end

            require("mason-lspconfig").setup({
                ensure_installed = generics.TBL_KEYS(servers),
                automatic_installation = false,
                automatic_enable = true,
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("n-lsp-attach", { clear = true }),
                callback = function(event)
                    -- bind lsp specific keys
                    require("lsp.key_bindings").setup(event)

                    -- highlight references under cursor
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if
                        client
                        and client:supports_method(
                            vim.lsp.protocol.Methods.textDocument_documentHighlight,
                            event.buf
                        )
                    then
                        local highlight_augroup =
                            vim.api.nvim_create_augroup("n-lsp-highlight", { clear = false })
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd("LspDetach", {
                            group = vim.api.nvim_create_augroup("n-lsp-detach", { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds({
                                    group = "n-lsp-highlight",
                                    buffer = event2.buf,
                                })
                            end,
                        })
                    end
                end,
            })

            vim.diagnostic.config({
                severity_sort = true,
                underline = false,
                signs = true,
                virtual_text = {
                    source = "if_many",
                    spacing = 2,
                    format = function(diagnostic)
                        local diagnostic_message = {
                            [vim.diagnostic.severity.ERROR] = diagnostic.message,
                            [vim.diagnostic.severity.WARN] = diagnostic.message,
                            [vim.diagnostic.severity.INFO] = diagnostic.message,
                        }
                        return diagnostic_message[diagnostic.severity]
                    end,
                },
            })
        end,
    },
}
