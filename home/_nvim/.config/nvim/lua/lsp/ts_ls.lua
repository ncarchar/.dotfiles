local M = {}

local function add_missing()
    vim.lsp.buf.code_action({
        apply = true,
        context = {
            only = { "source.addMissingImports.ts" },
            diagnostics = {},
        },
    })
end

local function organize_import_cmd(client)
    local params = {
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
        title = "",
    }
    client:exec_cmd(params)
end

local function organize_imports(client)
    return function()
        add_missing()
        organize_import_cmd(client)
    end
end

function M.setup()
    return {
        filetypes = { "javascript", "typescript" },
        settings = {
            implicitProjectConfiguration = {
                checkJs = true,
            },
            displayPartsForJSDoc = true,
            includeCompletionsWithSnippetText = true,
            typescript = {
                tsserver = {
                    useSyntaxServer = true,
                },
            },
        },
        on_attach = function(client, bufnr)
            local nmap = require("utils.generics").NMAP
            nmap(bufnr, "<leader>oi", organize_imports(client), "[O]ranize [I]mports")
        end,
    }
end

return M
