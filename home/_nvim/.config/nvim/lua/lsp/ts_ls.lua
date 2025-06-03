local nmap = require('lsp.nmap')

local M = {}

M.setup = function(_on_attach, _capabilities)
    local function add_missing()
        vim.lsp.buf.code_action({
            apply = true,
            context = {
                only = { "source.addMissingImports.ts" },
                diagnostics = {}
            },
        })
    end

    local function organize_imports()
        local params = {
            command = "_typescript.organizeImports",
            arguments = { vim.api.nvim_buf_get_name(0) },
            title = ""
        }
        vim.lsp.buf.execute_command(params)
    end

    local function remove_unused()
        vim.lsp.buf.code_action({
            apply = true,
            context = {
                only = { "source.removeUnused.ts" },
                diagnostics = {}
            },
        })
    end

    local on_attach = function(client, bufnr)
        _on_attach(client, bufnr)
        nmap("<leader>oi", organize_imports, "[O]rganize [I]mports", bufnr)
        nmap("<leader>cr", remove_unused, "[R]emove Unused", bufnr)
        nmap("<leader>ci", add_missing, "[I]mport", bufnr)
    end

    require('lspconfig').ts_ls.setup {
        on_attach = on_attach,
        capabilities = _capabilities,
        inlay_hits = false,
        filetypes = { "javascript", "typescript", "html" },
        commands = {
            LspOrganizeImports = {
                organize_imports
            },
            AddMissingImports = {
                add_missing
            },
            RemoveUnused = {
                remove_unused
            },
        },
        settings = {
            implicitProjectConfiguration = {
                checkJs = true
            },
            displayPartsForJSDoc = true,
            includeCompletionsWithSnippetText = true,
            typescript = {
                tsserver = {
                    useSyntaxServer = false,
                },
                inlayHints = {
                    includeInlayParameterNameHints = "none",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = false,
                    includeInlayFunctionLikeReturnTypeHints = false,
                },
            },
        },
    }
end

return M
