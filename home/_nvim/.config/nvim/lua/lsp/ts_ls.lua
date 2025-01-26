local nmap = require('lsp.nmap')

local M = {}

M.setup = function(_on_attach, _capabilities)
    local function organize_imports()
        vim.lsp.buf.code_action({
            apply = true,
            context = {
                only = { "source.addMissingImports.ts" },
                diagnostics = {}
            },
        })
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

    local on_attach = function(_, bufnr)
        _on_attach(_, bufnr)
        nmap("<leader>oi", organize_imports, "[O]rganize [I]mports", bufnr)
        nmap("<leader>ru", remove_unused, "[R]emove [U]nused", bufnr)
    end

    require('lspconfig').ts_ls.setup {
        on_attach = on_attach,
        capabilities = _capabilities,
        commands = {
            LspOrganizeImports = {
                organize_imports
            },
            RemoveUnsed = {
                remove_unused
            },
        },
        settings = {},
    }
end

return M
