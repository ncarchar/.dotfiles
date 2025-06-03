return {
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {},
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
            'WhoIsSethDaniel/mason-tool-installer.nvim',
            'folke/neodev.nvim',
        },
        config = function()
            local ts_ls = require('lsp.ts_ls')
            local nmap = require('lsp.nmap')
            --  This function gets run when an LSP connects to a particular buffer.
            local on_attach = function(_, bufnr)
                nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame', bufnr)
                nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', bufnr)
                nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition', bufnr)
                nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation', bufnr)
                nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition', bufnr)
                nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
                nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols,
                    '[W]orkspace [S]ymbols')
                -- See `:help K` for why this keymap
                nmap('K', vim.lsp.buf.hover, 'Hover Documentation', bufnr)
                nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration', bufnr)
                nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder', bufnr)
                nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder', bufnr)
                nmap('<leader>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, '[W]orkspace [L]ist Folders', bufnr)
            end
            local path = vim.fn.stdpath 'config' .. '/spell/en.utf-8.add'
            local words = {}
            for word in io.open(path, 'r'):lines() do
                table.insert(words, word)
            end
            local servers = {
                angularls = {},
                bashls = {},
                cssls = {},
                jdtls = {},
                jsonls = {},
                lua_ls = {},
                marksman = {},
                nil_ls = {},
                ts_ls = {},
            }
            -- Setup neovim lua configuration
            require('neodev').setup()
            -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            if pcall(require, 'cmp') and pcall(require, 'cmp_nvim_lsp') then
                capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
            end
            -- Ensure the servers above are installed
            local ensure_installed = vim.tbl_keys(servers or {})
              vim.list_extend(ensure_installed, {
                'prettier', -- Used to format Lua code
              })
            require('mason-tool-installer').setup { ensure_installed = ensure_installed }
            require('mason-lspconfig').setup {
                -- ensure_installed = vim.tbl_keys(servers),
                ensure_installed = {},
                automatic_installation = false,
                setup_handlers = {
                    function(server_name)
                        if server_name == "jdtls" then
                            -- Use ftplug java
                        elseif server_name == "ts_ls" then
                            ts_ls.setup(on_attach, capabilities)
                        else
                            require('lspconfig')[server_name].setup {
                                capabilities = capabilities,
                                on_attach = on_attach,
                                settings = servers[server_name],
                            }
                        end
                    end,
                }
            }
        end
    }
}
