M = {}

function M.setup(event)
    local generics = require("utils.generics")

    local map = function(keys, func, desc, mode)
        generics.NMAP(event.buf, keys, func, desc, mode)
    end

    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
    map("gad", vim.lsp.buf.definition, "[G]oto [A]ll [D]efinition")
    map("gd", function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        local client = clients[1]
        if not client then
            print("No LSP client attached")
            return
        end

        local enc = client.offset_encoding or "utf-16"
        local params = vim.lsp.util.make_position_params(0, enc)

        vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
            if err then
                print(vim.inspect(err))
                return
            end
            if result and (vim.isarray(result) and #result > 0 or not vim.isarray(result)) then
                vim.lsp.util.show_document(result[1] or result, enc, { focus = true })
                return
            end
            print("No definition found")
        end)
    end, "[G]oto [D]efinition")

    map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
    map("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
    map("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
    map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
    map(
        "<leader>ws",
        require("telescope.builtin").lsp_dynamic_workspace_symbols,
        "[W]orkspace [S]ymbols"
    )
    -- See `:help K` for why this keymap
    map("K", vim.lsp.buf.hover, "Hover Documentation")
    map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    map("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
    map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
    map("<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "[W]orkspace [L]ist Folders")
end

return M
